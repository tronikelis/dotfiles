local M = {}

function M.clamp(target, a, b)
    if target <= a then
        return a
    end
    if target >= b then
        return b
    end
    return target
end

function M.clamp_linecount(target)
    local count = vim.api.nvim_buf_line_count(0)
    return M.clamp(target, 1, count)
end

-- returns a function which calls `call` `vim.v.count1` times
function M.keymap_each_count(call)
    return function()
        for _ = 1, vim.v.count1 do
            call()
        end
    end
end

-- returns a function which prepends `<cmd>[vim.v.count1]` to `cmd`
function M.with_count(cmd)
    return function()
        return "<cmd>" .. vim.v.count1 .. cmd
    end
end

function M.extend_global_theme(name, val)
    local hl = vim.api.nvim_get_hl(0, { name = name })
    if not hl then
        error(string.format("can't find %s", name))
    end

    vim.api.nvim_set_hl(0, name, vim.tbl_deep_extend("force", hl, val))
end

return M
