---@param key string
local function map(key)
    local ikey = "i" .. key
    local akey = "a" .. key

    vim.keymap.set("x", ikey, "<plug>(IndentTextobjectSelectInner)")
    vim.keymap.set("x", akey, "<plug>(IndentTextobjectSelectAround)")

    vim.keymap.set("o", ikey, string.format("<cmd>normal v%s<cr>", ikey))
    vim.keymap.set("o", akey, string.format("<cmd>normal v%s<cr>", akey))

    vim.keymap.set({ "n", "x" }, "[" .. key, "<plug>(IndentTextobjectGotoInnerTop)")
    vim.keymap.set({ "n", "x" }, "]" .. key, "<plug>(IndentTextobjectGotoInnerBot)")

    vim.keymap.set({ "n", "x" }, "[" .. string.upper(key), "<plug>(IndentTextobjectGotoAroundTop)")
    vim.keymap.set({ "n", "x" }, "]" .. string.upper(key), "<plug>(IndentTextobjectGotoAroundBot)")
end

map("i")
