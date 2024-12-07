return {
    "windwp/nvim-autopairs",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    config = function()
        local autopairs = require("nvim-autopairs")

        local Rule = require("nvim-autopairs.rule")
        local ts_conds = require("nvim-autopairs.ts-conds")
        local conds = require("nvim-autopairs.conds")

        autopairs.setup({ check_ts = true })

        autopairs.add_rule(Rule("<", ">")
            -- only pair if previous char is not whitespace
            :with_pair(conds.not_before_regex("%s$", 1))
            -- skip pairing in html elements
            :with_pair(
                ts_conds.is_not_ts_node({ "jsx_element", "element" })
            )
            :with_move(function(opts)
                return opts.char == ">"
            end))
    end,
}
