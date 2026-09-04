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

    local LINES_SIZE = 500
    local MAX_ITER = 100

    local tabs_stat = 0
    local spaces_stat = {}
    local i = -1

    while tabs_stat == 0 and #vim.tbl_keys(spaces_stat) == 0 do
        if i == MAX_ITER then
            break
        end
        i = i + 1

        local lines = vim.api.nvim_buf_get_lines(0, i * LINES_SIZE, (i + 1) * LINES_SIZE, false)
        if #lines == 0 then
            break
        end

        for _, line in ipairs(lines) do
            local spaces = line:match("^([ ]+)%S")
            local tabs = line:match("^([\t]+)%S")
            if spaces ~= nil then
                spaces_stat[#spaces] = (spaces_stat[#spaces] or 0) + 1
            elseif tabs ~= nil then
                tabs_stat = (tabs_stat or 0) + 1
            end
        end
    end

    if tabs_stat == 0 and #vim.tbl_keys(spaces_stat) == 0 then
        if print then
            vim.notify("Buffer does not have indentation")
        end
        return
    end

    local spaces_priority = {}
    for spacesi, counti in pairs(spaces_stat) do
        local priority = counti

        for spacesj, countj in pairs(spaces_stat) do
            if spacesj ~= spacesi and spacesj % spacesi == 0 then
                priority = priority + countj
            end
        end

        spaces_priority[spacesi] = priority
    end

    local spaces_count = 0
    local picked_spaces = 0
    for spaces, count in pairs(spaces_priority) do
        if count > spaces_count then
            spaces_count = count
            picked_spaces = spaces
        end
    end

    if spaces_count == 0 then
        set_tabs(print)
        return
    end

    if spaces_count > tabs_stat then
        set_spaces(print, picked_spaces)
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
