---@param key string
local function map(key)
    local ikey = "i" .. key
    local akey = "a" .. key

    vim.keymap.set("x", ikey, require("indent-textobject").select_inner)
    vim.keymap.set("x", akey, require("indent-textobject").select_around)

    vim.keymap.set("o", "i" .. key, string.format("<cmd>normal v%s<cr>", ikey))
    vim.keymap.set("o", "a" .. key, string.format("<cmd>normal v%s<cr>", akey))

    vim.keymap.set({ "n", "x" }, "[" .. key, require("indent-textobject").goto_inner_top)
    vim.keymap.set({ "n", "x" }, "]" .. key, require("indent-textobject").goto_inner_bot)

    vim.keymap.set({ "n", "x" }, "[" .. string.upper(key), require("indent-textobject").goto_around_top)
    vim.keymap.set({ "n", "x" }, "]" .. string.upper(key), require("indent-textobject").goto_around_bot)
end

map("i")
