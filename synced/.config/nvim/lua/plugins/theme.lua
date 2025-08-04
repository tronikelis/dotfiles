return {
    "catppuccin/nvim",
    version = "1",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            no_italic = true,
        })

        vim.cmd.colorscheme("catppuccin")
    end,
}
