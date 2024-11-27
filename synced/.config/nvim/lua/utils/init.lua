local M = {}

-- returns a function which calls `call` `vim.v.count1` times
function M.keymap_each_count(call)
    return function()
        for _ = 1, vim.v.count1 do
            call()
        end
    end
end

return M
