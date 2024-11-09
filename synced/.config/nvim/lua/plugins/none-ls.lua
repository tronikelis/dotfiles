return {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "davidmh/cspell.nvim",
    },
    config = function()
        local none_ls = require("null-ls")
        local cspell = require("cspell")

        none_ls.setup({
            sources = {
                cspell.diagnostics.with({
                    diagnostics_postprocess = function(diagnostic)
                        diagnostic.severity = vim.diagnostic.severity.INFO
                    end,
                }),
                cspell.code_actions,
            },
        })
    end,
}
