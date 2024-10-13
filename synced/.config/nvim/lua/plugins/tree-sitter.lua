return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        {
            "nvim-treesitter/nvim-treesitter-context",
            opts = {
                enable = true,
                max_lines = 3,
                multiline_threshold = 1,
                min_window_height = 25,
            },
        },
    },
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
    },
}
