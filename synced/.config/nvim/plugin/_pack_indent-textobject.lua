---@param key string
local function map(key)
    vim.keymap.set("v", "i" .. key, require("indent-textobject").select_inner)
    vim.keymap.set("v", "a" .. key, require("indent-textobject").select_around)

    vim.keymap.set("o", "i" .. key, "<cmd>normal vii<cr>")
    vim.keymap.set("o", "a" .. key, "<cmd>normal vai<cr>")

    vim.keymap.set({ "n", "v" }, "[" .. key, require("indent-textobject").goto_inner_top)
    vim.keymap.set({ "n", "v" }, "]" .. key, require("indent-textobject").goto_inner_bot)

    vim.keymap.set({ "n", "v" }, "[" .. string.upper(key), require("indent-textobject").goto_around_top)
    vim.keymap.set({ "n", "v" }, "]" .. string.upper(key), require("indent-textobject").goto_around_bot)
end

map("i")
