local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
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
    { import = "plugins.none-ls" },

    -- small plugins that don't need config
    {
        "Darazaki/indent-o-matic",
        event = "VeryLazy",
        opts = {},
    },
    {
        "arthurxavierx/vim-caser",
        event = "VeryLazy",
    },
    {
        "windwp/nvim-autopairs",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "InsertEnter",
        opts = { check_ts = true },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        main = "ibl",
        opts = {
            scope = {
                show_start = false,
                show_end = false,
            },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        opts = {},
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
        opts = {},
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
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {},
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
        "tronikelis/lsp-gc.nvim",
        event = "VeryLazy",
        dependencies = { "neovim/nvim-lspconfig" },
        opts = {},
    },
}, {
    change_detection = {
        enabled = false,
    },
})
