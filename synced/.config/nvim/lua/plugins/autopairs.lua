return {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
        mappings = {
            ["<"] = { action = "open", pair = "<>", neigh_pattern = "%S" },
            [">"] = { action = "close", pair = "<>", neigh_pattern = "%S" },
        },
    },
}
