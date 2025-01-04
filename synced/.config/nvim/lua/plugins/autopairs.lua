return {
    "windwp/nvim-autopairs",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
        local autopairs = require("nvim-autopairs")

        local Rule = require("nvim-autopairs.rule")
        local ts_conds = require("nvim-autopairs.ts-conds")
        local conds = require("nvim-autopairs.conds")

        autopairs.setup({ check_ts = true })

        autopairs.add_rule(Rule("<", ">", { "-html" })
            :with_pair(
                -- regex will make it so that it will auto-pair on
                -- `a<` but not `a <`
                -- The `:?:?` part makes it also
                -- work on Rust generics like `some_func::<T>()`
                conds.before_regex("%a+:?:?$", 3)
            )
            -- skip pairing in html elements
            :with_pair(
                ts_conds.is_not_ts_node({ "jsx_element", "element" })
            )
            :with_move(function(opts)
                return opts.char == ">"
            end))
    end,
}
