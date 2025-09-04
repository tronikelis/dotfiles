-- unpack is deprecated in favor of table.unpack,
-- but nvim still uses older lua that does not support it, so fallback
table.unpack = table.unpack or unpack

require("core")

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
    { import = "plugins.comments" },
    { import = "plugins.conflict-marker" },
    { import = "plugins.formatter" },
    { import = "plugins.gitsigns" },
    { import = "plugins.lsp" },
    { import = "plugins.lualine" },
    { import = "plugins.oil" },
    { import = "plugins.sstash" },
    { import = "plugins.telescope" },
    { import = "plugins.theme" },
    { import = "plugins.tree-sitter" },
    { import = "plugins.xylene" },

    -- small plugins that don't need config
    {
        -- i don't think this should be lazy loaded
        "NMAC427/guess-indent.nvim",
        config = function()
            local guess_indent = require("guess-indent")
            guess_indent.setup({
                on_tab_options = {
                    ["expandtab"] = false,
                },
                on_space_options = {
                    ["expandtab"] = true,
                    ["shiftwidth"] = "detected",
                },
            })

            vim.api.nvim_create_autocmd("BufWritePost", {
                callback = function(args)
                    guess_indent.set_from_buffer(args.buf, true, true)
                end,
            })
        end,
    },
    {
        "tronikelis/caser.nvim",
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
}, {
    change_detection = {
        enabled = false,
    },
    -- lowering this fixes "could not resolve github.com",
    -- seems like they have some sort of rate limiting thing
    concurrency = 8,
})
