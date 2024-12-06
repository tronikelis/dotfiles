vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        -- bolds null / undefined / nil
        require("utils").extend_global_theme("@constant.builtin", { bold = true })
    end,
})

return {
    "catppuccin/nvim",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            no_italic = true,
        })

        vim.cmd.colorscheme("catppuccin")
    end,
}
