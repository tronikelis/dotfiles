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
    return vim.iter(tbl):flatten(math.huge):totable()
end

---@param ev table
---@param ns integer
---@param buf integer
---@param whitelist string[]
---@return integer
function M.inc_command_diff_preview(ev, ns, buf, whitelist)
    local old_lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

    local command = vim.api.nvim_parse_cmd(ev.args, {})
    if not vim.tbl_contains(whitelist, command.cmd) then
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { string.format('"%s" not in whitelist', command.cmd) })
        return 2
    end
    vim.api.nvim_cmd(command, {})

    local new_lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

    local diff = vim.text.diff(table.concat(old_lines, "\n"), table.concat(new_lines, "\n"))
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, vim.split(diff, "\n"))

    return 2
end

---@param bool any
---@param msg any
---@param level integer?
---@return boolean
function M.assert_notify(bool, msg, level)
    if not bool then
        vim.schedule(function()
            vim.notify(tostring(msg), level or vim.log.levels.ERROR)
        end)
    end
    return not not bool
end

return M
