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
    require("plugins.theme"),
    require("plugins.telescope"),
    require("plugins.tree-sitter"),
    require("plugins.lsp"),
    require("plugins.formatter"),
    require("plugins.gitsigns"),
    require("plugins.lualine"),
    require("plugins.oil"),
    require("plugins.comments"),
    require("plugins.grapple"),
    require("plugins.xylene"),
    require("plugins.conflict-marker"),
    require("plugins.mason_tools"),

    -- small plugins that don't need config
    "tpope/vim-sleuth",
    {
        "windwp/nvim-autopairs",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
            })
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup({
                scope = {
                    show_start = false,
                    show_end = false,
                },
            })
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-ts-autotag").setup()
        end,
        event = "VeryLazy",
    },
    {
        "stevearc/dressing.nvim",
        config = function()
            require("dressing").setup({})
        end,
    },
    {
        "Tronikelis/debdiag.nvim",
        config = function()
            require("debdiag").setup({
                ms = 400,
            })
        end,
    },
    "tpope/vim-surround",
    "mbbill/undotree",
})
