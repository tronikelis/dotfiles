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
    { import = "plugins.grapple" },
    { import = "plugins.xylene" },
    { import = "plugins.conflict-marker" },

    -- small plugins that don't need config
    "tpope/vim-sleuth",
    {
        "windwp/nvim-autopairs",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "InsertEnter",
        opts = { check_ts = true },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
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
        opts = {},
        event = "VeryLazy",
    },
    {
        "stevearc/dressing.nvim",
        opts = {},
    },
    {
        "Tronikelis/debdiag.nvim",
        event = "VeryLazy",
        opts = { ms = 400 },
    },
    "tpope/vim-surround",
    "mbbill/undotree",
})
