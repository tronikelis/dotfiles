---@param pattern string
---@param line1 integer
---@param line2 integer
---@param count integer
local function get_matches(pattern, line1, line2, count)
    local matches = {}
    for i = line1, line2 do
        local col = vim.fn.match(vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1], pattern, 0, count + 1)
        if col ~= -1 then
            table.insert(matches, {
                col = col,
                line = i,
            })
        end
    end

    return matches
end

---@param fargs string[]
---@return string|nil, integer
local function get_pattern_n_count(fargs)
    local pattern = fargs[1]
    if not pattern or #pattern == 0 then
        return nil, 0
    end

    ---@type integer|string|nil
    local count = fargs[2]
    if count == nil or #count == 0 then
        count = 0
    end
    return pattern, tonumber(count)--[[@as integer]]
end

---@param ev table
---@param ns integer
---@param buf integer
---@return integer
---@diagnostic disable-next-line: unused-local
local function preview(ev, ns, buf)
    local pattern, count = get_pattern_n_count(ev.fargs)
    if not pattern then
        return 1
    end

    local matches = get_matches(pattern, ev.line1, ev.line2, count)
    for _, v in ipairs(matches) do
        local hl_start = { v.line - 1, v.col }
        vim.hl.range(0, ns, "Substitute", hl_start, hl_start)
    end

    return 1
end

vim.api.nvim_create_user_command("AlignPattern", function(ev)
    local pattern, count = get_pattern_n_count(ev.fargs)
    if not pattern then
        return
    end

    local matches = get_matches(pattern, ev.line1, ev.line2, count)

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
    nargs = "+",
    preview = preview,
})
