local augroup = vim.api.nvim_create_augroup("plugin/guess_indent.lua", {})

---@param print boolean?
local function set_tabs(print)
    vim.bo.expandtab = false
    if print then
        vim.notify("Set tabs")
    end
end

---@param print boolean?
---@param spaces integer
local function set_spaces(print, spaces)
    vim.bo.expandtab = true
    vim.bo.shiftwidth = spaces
    if print then
        vim.notify(string.format("Set %d spaces", vim.bo.shiftwidth))
    end
end

---@param print boolean?
local function guess_indent(print)
    if vim.bo.buftype ~= "" then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, 400, false)

    local tabs_stat = 0
    local spaces_stat = {}
    for _, line in ipairs(lines) do
        local spaces = line:match("^([ ]+)%S")
        local tabs = line:match("^([\t]+)%S")
        if spaces ~= nil then
            spaces_stat[#spaces] = (spaces_stat[#spaces] or 0) + 1
        elseif tabs ~= nil then
            tabs_stat = (tabs_stat or 0) + 1
        end
    end

    local smallest_spaces = 1073741824
    local spaces_count = 0
    for spaces, count in pairs(spaces_stat) do
        if spaces < smallest_spaces then
            smallest_spaces = spaces
            spaces_count = count
        end
    end

    if spaces_count == 0 then
        set_tabs(print)
        return
    end

    if spaces_count > tabs_stat then
        set_spaces(print, smallest_spaces)
        return
    elseif tabs_stat > spaces_count then
        set_tabs(print)
        return
    end

    if print then
        vim.notify("Did not figure out indentation")
    end
end

vim.api.nvim_create_user_command("GuessIndent", function()
    guess_indent(true)
end, {})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
        guess_indent()
    end,
})
