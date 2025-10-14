---@param fun function
local function while_same_file(fun)
    local current = vim.fn.expand("%:p")
    local i = 0
    while current == vim.fn.expand("%:p") and i < 100 do
        fun()
        i = i + 1
    end
end

vim.keymap.set("n", "<c-b>", function()
    while_same_file(function()
        local ok, err = pcall(function()
            vim.cmd.execute([["normal! \<c-o>"]])
        end)
        if not ok then
            vim.notify(tostring(err), vim.log.levels.ERROR)
        end
    end)
end)

vim.keymap.set("n", "<c-f>", function()
    while_same_file(function()
        local ok, err = pcall(function()
            vim.cmd.execute([["normal! \<c-i>"]])
        end)
        if not ok then
            vim.notify(tostring(err), vim.log.levels.ERROR)
        end
    end)
end)
