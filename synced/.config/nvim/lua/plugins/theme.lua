return {
    "catppuccin/nvim",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            no_italic = true,
            custom_highlights = function()
                return {
                    ["@constant.builtin"] = { bold = true },
                }
            end,
        })

        vim.cmd.colorscheme("catppuccin")
    end,
}
