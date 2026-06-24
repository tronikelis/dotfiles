require("gitsigns").setup({
    preview_config = {
        border = "rounded",
    },
    current_line_blame = true,
    current_line_blame_opts = {
        -- will be drawn the last always
        virt_text_priority = (2 ^ 16) - 1,
    },
    on_attach = function(bufnr)
        local opts = { buffer = bufnr }

        vim.keymap.set("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<cr>", opts)
        vim.keymap.set("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<cr>", opts)
        vim.keymap.set("n", "[h", "<cmd>Gitsigns nav_hunk prev<cr>", opts)
        vim.keymap.set("n", "]h", "<cmd>Gitsigns nav_hunk next<cr>", opts)
    end,
})
