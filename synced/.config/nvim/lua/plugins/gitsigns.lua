return {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
        preview_config = {
            border = "rounded",
        },
        current_line_blame = true,
        on_attach = function(bufnr)
            local gitsigns = require("gitsigns")
            local opts = { buffer = bufnr }

            vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, opts)
            vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, opts)

            vim.keymap.set("n", "<leader>hb", function()
                gitsigns.blame_line()
            end, opts)
            vim.keymap.set("n", "<leader>hB", function()
                gitsigns.blame_line({ full = true })
            end, opts)

            vim.keymap.set("n", "[h", function()
                gitsigns.nav_hunk("prev", { target = "all", count = vim.v.count1, wrap = false })
            end, opts)

            vim.keymap.set("n", "]h", function()
                gitsigns.nav_hunk("next", { target = "all", count = vim.v.count1, wrap = false })
            end, opts)
        end,
    },
}
