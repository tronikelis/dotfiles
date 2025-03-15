local M = {}

function M.setup()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not vim.uv.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        })
    end

    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
        { import = "plugins.theme" },
        { import = "plugins.telescope" },
        { import = "plugins.tree-sitter" },
        { import = "plugins.lsp" },
        { import = "plugins.formatter" },
        { import = "plugins.gitsigns" },
        { import = "plugins.lualine" },
        { import = "plugins.oil" },
        { import = "plugins.comments" },
        { import = "plugins.xylene" },
        { import = "plugins.conflict-marker" },
        { import = "plugins.sstash" },

        -- small plugins that don't need config
        {
            -- i don't think this should be lazy loaded
            "NMAC427/guess-indent.nvim",
            opts = {},
        },
        {
            "arthurxavierx/vim-caser",
            event = "VeryLazy",
        },
        {
            "stevearc/dressing.nvim",
            dependencies = "nvim-telescope/telescope.nvim",
            event = "VeryLazy",
            opts = {},
        },
        {
            "tronikelis/debdiag.nvim",
            event = "VeryLazy",
            opts = { ms = 1000 },
        },
        {
            "kylechui/nvim-surround",
            version = "*",
            event = "VeryLazy",
            opts = {},
        },
        {
            "mbbill/undotree",
            event = "VeryLazy",
        },
        {
            "tronikelis/gitdive.nvim",
            event = "VeryLazy",
            opts = {
                get_absolute_file = function()
                    if vim.bo.filetype == "oil" then
                        return require("oil").get_current_dir()
                    end

                    return vim.fn.expand("%:p")
                end,
            },
        },
        {
            "folke/lazydev.nvim",
            ft = "lua",
            opts = {
                library = {
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
        {
            "tronikelis/ts-autotag.nvim",
            event = "VeryLazy",
            opts = {},
        },
        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            event = "VeryLazy",
            opts = {
                scope = {
                    show_start = false,
                    show_end = false,
                },
            },
        },
    }, {
        change_detection = {
            enabled = false,
        },
    })
end

return M
