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
            cspell_config_dirs = { "~/.config/" },
            on_add_to_json = function(payload)
                local c = payload.cspell_config_path
                os.execute(string.format("jq -S '.words |= sort' %s > %s.tmp && mv %s.tmp %s", c, c, c, c))
            end,
        }

        none_ls.setup({
            debounce = 1000,
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
