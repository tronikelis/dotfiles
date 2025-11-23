local augroup = vim.api.nvim_create_augroup("plugin/_pack_oil.lua", {})

local oil = require("oil")

oil.setup({
    use_default_keymaps = false,
    view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
            return name == ".."
        end,
    },
    watch_for_changes = true,
})

local actions = require("oil.actions")

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "oil",
    callback = function(ev)
        local opts = {
            buffer = ev.buf,
        }

        vim.keymap.set("n", "<Cr>", actions.select.callback, opts)
        vim.keymap.set("n", "-", actions.parent.callback, opts)
        vim.keymap.set("n", "<esc>", actions.close.callback, opts)
    end,
})

vim.keymap.set("n", "-", oil.open)
vim.keymap.set("n", "<leader>-", function()
    oil.open(vim.fn.getcwd())
end)
