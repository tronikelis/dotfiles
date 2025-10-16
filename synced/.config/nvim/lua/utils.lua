local M = {}

---@param str string
---@param startsWith string
---@return boolean
function M.string_starts_with(str, startsWith)
    return str:sub(1, #startsWith) == startsWith
end

---@param query string
---@param list table
---@return table
function M.prefix_filter(query, list)
    if not query or query == "" then
        return list
    end

    return vim.iter(list)
        :filter(function(x)
            return M.string_starts_with(x, query)
        end)
        :totable()
end

function M.flatten(tbl)
    return vim.iter(tbl):flatten():totable()
end

---@param ev table
---@param ns integer
---@param buf integer
---@return integer
function M.inc_command_diff_preview(ev, ns, buf)
    local old_lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    vim.cmd(ev.args)
    local new_lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

    local diff = vim.diff(table.concat(old_lines, "\n"), table.concat(new_lines, "\n"))
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(diff, "\n"))

    pcall(function()
        if not vim.treesitter.get_parser(buf, nil, { error = false }) then
            vim.treesitter.start(buf, "diff")
        end
    end)

    return 2
end

return M
