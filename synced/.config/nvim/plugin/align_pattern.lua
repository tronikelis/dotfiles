---@param pattern string
---@param line1 integer
---@param line2 integer
local function get_matches(pattern, line1, line2)
    local matches = {}
    for i = line1, line2 do
        local col = vim.fn.match(vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1], pattern)
        if col ~= -1 then
            table.insert(matches, {
                col = col,
                line = i,
            })
        end
    end

    return matches
end

---@param ev table
---@param ns integer
---@param buf integer
---@return integer
local function preview(ev, ns, buf)
    local pattern = ev.args
    if #pattern == 0 then
        return 0
    end

    local matches = get_matches(pattern, ev.line1, ev.line2)
    for _, v in ipairs(matches) do
        local hl_start = { v.line - 1, v.col }
        vim.hl.range(0, ns, "Substitute", hl_start, hl_start)
    end

    return 1
end

vim.api.nvim_create_user_command("AlignPattern", function(ev)
    local pattern = ev.fargs[1]
    local matches = get_matches(pattern, ev.line1, ev.line2)

    local col_max = 0
    for _, v in ipairs(matches) do
        if v.col > col_max then
            col_max = v.col
        end
    end

    for _, v in ipairs(matches) do
        local delta = col_max - v.col
        vim.api.nvim_buf_set_text(0, v.line - 1, v.col, v.line - 1, v.col, { string.rep(" ", delta) })
    end
end, {
    range = true,
    nargs = 1,
    preview = preview,
})
