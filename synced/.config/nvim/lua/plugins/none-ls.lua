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
            sources = {
                cspell.diagnostics.with({
                    method = none_ls.methods.DIAGNOSTICS_ON_SAVE, -- cspell is slow as hell
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
