---@param line integer
---@return integer?
local function get_line_indent(line)
    local data = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
    if data:match("^([ \t]*)$") then
        return
    end

    local indent = data:match("^([ \t]*).*$")
    return #assert(indent)
end

---@param step integer
---@param limit integer
local function find_indent(limit, step)
    local i = vim.api.nvim_win_get_cursor(0)[1]
    local prev_indent
    local prev_valid_indent

    for i = i, limit, step do
        local indent = get_line_indent(i)

        if not prev_indent then
            prev_indent = indent
        else
            if indent and indent < prev_indent then
                return prev_valid_indent or i
            end
        end

        if indent and indent >= prev_indent then
            prev_valid_indent = i
        end
    end
end

local function move_cursor_to_first_indent()
    local i = vim.api.nvim_win_get_cursor(0)[1]
    for i = i, vim.api.nvim_buf_line_count(0) do
        local indent = get_line_indent(i)
        if indent and indent > 0 then
            vim.api.nvim_win_set_cursor(0, { i, 0 })
            return
        end
    end
end

---@param offset integer
local function select_indent(offset)
    move_cursor_to_first_indent()

    local top = find_indent(1, -1)
    local bot = find_indent(vim.api.nvim_buf_line_count(0), 1)
    if not top then
        top = "normal! gg"
    else
        top = top + offset
    end
    if not bot then
        bot = "normal! G"
    else
        bot = bot - offset
    end

    vim.cmd(tostring(top))
    vim.cmd("normal! _")
    vim.cmd("normal! o")
    vim.cmd(tostring(bot))
    vim.cmd("normal! g_")
end

vim.keymap.set("v", "ii", function()
    select_indent(0)
end)

vim.keymap.set("v", "ai", function()
    select_indent(-1)
end)

vim.keymap.set("o", "ii", "<cmd>normal vii<cr>")
vim.keymap.set("o", "ai", "<cmd>normal vai<cr>")

vim.keymap.set("n", "[i", function()
    vim.cmd("normal! v")
    select_indent(0)
    vim.cmd("normal! o")
    vim.cmd("normal! v")
end)

vim.keymap.set("n", "]i", function()
    vim.cmd("normal! v")
    select_indent(0)
    vim.cmd("normal! v")
end)

vim.keymap.set("n", "[I", function()
    vim.cmd("normal! v")
    select_indent(-1)
    vim.cmd("normal! o")
    vim.cmd("normal! v")
end)

vim.keymap.set("n", "]I", function()
    vim.cmd("normal! v")
    select_indent(-1)
    vim.cmd("normal! v")
end)
