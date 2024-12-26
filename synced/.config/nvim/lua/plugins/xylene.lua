return {
    "tronikelis/xylene.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope.nvim",
        "stevearc/oil.nvim",
    },
    opts = {
        get_cwd = function()
            if vim.bo.filetype == "oil" then
                return require("oil").get_current_dir()
            end
            return vim.fn.getcwd()
        end,
        get_current_file_dir = function()
            if vim.bo.filetype == "oil" then
                return require("oil").get_current_dir()
            end
            return vim.fn.expand("%:p")
        end,
        on_attach = function(renderer)
            vim.keymap.set("n", "<cr>", function()
                renderer:toggle(vim.api.nvim_win_get_cursor(0)[1])
            end, { buffer = renderer.buf })

            vim.keymap.set("n", "!", function()
                renderer:toggle_all(vim.api.nvim_win_get_cursor(0)[1])
            end, { buffer = renderer.buf })
        end,
    },
}
