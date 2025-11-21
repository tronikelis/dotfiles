-- inspired by https://github.com/TheNoeTrevino/no-go.nvim
local ns = vim.api.nvim_create_namespace("goerr/conceal")

local err_pattern = "^(err|error)$"
local virtual_text = "{{ERR}} 󱞿 "
local highlight = "NonText"

local function get_query_string(pattern)
    return [[(
        (if_statement
            condition: (binary_expression
                left: (identifier) @err
                right: (nil))
            consequence: (block .
                (statement_list .
                    (return_statement
                ))))
        (#match? @err "]] .. pattern .. [[")
  )]]
end

local function conceal_iferr_node(win, bufnr, iferr_node, err_node)
    local start_row, start_col, end_row, _ = iferr_node:range()

    -- check if cursor in the iferr node
    local cursor = vim.api.nvim_win_get_cursor(win)
    local cursor_row = cursor[1] - 1
    if cursor_row >= start_row and cursor_row <= end_row then
        return
    end

    if start_row == end_row then
        return
    end

    vim.api.nvim_buf_set_extmark(bufnr, ns, start_row + 1, 0, {
        end_row = end_row,
        end_col = 0,
        conceal_lines = "",
    })

    -- virtual text
    local err_text = vim.treesitter.get_node_text(err_node, bufnr)
    local virt_text = virtual_text:gsub("{{ERR}}", err_text)
    vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, 0, {
        virt_text = { { virt_text, highlight } },
        priority = 0,
    })
end

local function on_win(_, win, buf, top, bottom)
    vim.api.nvim_buf_clear_namespace(buf, ns, top, bottom + 1)

    if not vim.b[buf].goerr then
        return false
    end

    local filetype = vim.bo[buf].filetype
    if filetype ~= "go" then
        return false
    end

    vim.wo[win][0].conceallevel = 2
    vim.wo[win][0].concealcursor = "nvic"

    local ok, parser = pcall(function()
        return vim.treesitter.get_parser(buf, filetype)
    end)
    if not ok or not parser then
        return false
    end

    local parsed = parser:parse({ top, bottom + 1 })
    if not parsed then
        return false
    end

    local query = vim.treesitter.query.parse(filetype, get_query_string(err_pattern))

    for _, node in pairs(parsed) do
        for _, match, _ in query:iter_matches(node:root(), buf, top, bottom + 1) do
            for id, nodes in pairs(match) do
                local capture_name = query.captures[id]
                if capture_name == "err" then
                    local err_node = nodes[1]
                    local if_node = err_node:parent()
                    while if_node and if_node:type() ~= "if_statement" do
                        if_node = if_node:parent()
                    end
                    if if_node then
                        conceal_iferr_node(win, buf, if_node, err_node)
                    end
                end
            end
        end
    end
end

vim.api.nvim_set_decoration_provider(ns, { on_win = on_win })

vim.api.nvim_create_user_command("GoErr", function()
    if vim.b.goerr == nil then
        vim.b.goerr = true
        return
    end

    vim.b.goerr = not vim.b.goerr
end, {})
