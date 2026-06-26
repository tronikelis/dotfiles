require("oil").setup({
    use_default_keymaps = false,
    keymaps = {
        ["<cr>"] = { "actions.select", mode = "n" },
        ["-"] = { "actions.parent", mode = "n" },
        ["<c-c>"] = { "actions.close", mode = "n" },
    },
    view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
            return name == ".."
        end,
    },
    watch_for_changes = true,
})

vim.keymap.set("n", "-", function()
    require("oil").open()
end)
vim.keymap.set("n", "<leader>-", function()
    require("oil").open(vim.fn.getcwd())
end)
