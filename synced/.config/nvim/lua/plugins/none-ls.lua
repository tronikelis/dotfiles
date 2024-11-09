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

        local config = {
            cspell_config_dirs = { "~/.config/nvim/" },
        }

        none_ls.setup({
            sources = {
                cspell.diagnostics.with({
                    diagnostics_postprocess = function(diagnostic)
                        diagnostic.severity = vim.diagnostic.severity.INFO
                    end,
                    config = config,
                }),
                cspell.code_actions.with({
                    config = config,
                }),
            },
        })
    end,
}
