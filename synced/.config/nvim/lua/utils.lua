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

    local old_lines_str = table.concat(old_lines, "\n")
    local new_lines_str = table.concat(new_lines, "\n")

    local diff_indices = vim.text.diff(old_lines_str, new_lines_str, { result_type = "indices" })
    for _, indices in ipairs(diff_indices) do
        vim.hl.range(0, ns, "Substitute", { indices[3] - 1, 0 }, { indices[3] + indices[4] - 1, 0 })
    end

    local diff = vim.text.diff(old_lines_str, new_lines_str)
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

---@param regex string
---@param max_results? integer
---@param opts vim.SystemOpts
---@return vim.SystemObj
function M.system_find(regex, max_results, opts)
    local cmd = { "find", ".", "-type", "f", "-regextype", "egrep", "-regex", string.format(".*%s.*", regex) }
    if vim.fn.has("macunix") == 1 then
        cmd = { "find", "-E", ".", "-type", "f", "-regex", string.format(".*%s.*", regex) }
    end
    if max_results then
        local find_escaped = vim.iter(cmd)
            :map(function(v)
                return vim.fn.shellescape(v)
            end)
            :join(" ")
        cmd = {
            "bash",
            "-c",
            string.format("%s | head -n 100", find_escaped),
        }
    end

    if vim.fn.executable("fd") == 1 then
        cmd = { "fd", "--type", "f", "--hidden", "--full-path" }
        if max_results then
            table.insert(cmd, "--max-results")
            table.insert(cmd, max_results)
        end
        table.insert(cmd, regex)
    end

    return vim.system(cmd, vim.tbl_extend("force", { text = true }, opts))
end

---@param key string
---@return uv.uv_timer_t
function M.timer_keyed(key)
    key = string.format("__timer_keyed%s", key)
    local timer = _G[key] or assert(vim.uv.new_timer())
    _G[key] = timer
    return timer
end

return M
