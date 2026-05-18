require("blink.cmp").setup({
    completion = {
        documentation = {
            window = { border = "rounded" },
            auto_show = true,
            auto_show_delay_ms = 500,
        },
        menu = {
            border = "rounded",
            auto_show_delay_ms = 100,
        },
        accept = {
            auto_brackets = { enabled = false },
        },
        list = {
            selection = {
                preselect = true,
                auto_insert = false,
            },
        },
    },
    keymap = { preset = "super-tab" },
    sources = {
        default = {
            "lsp",
            "buffer",
            "ctags",
        },
        providers = {
            lsp = { fallbacks = { "buffer", "ctags" } },
            buffer = {
                min_keyword_length = 6,
            },
            ctags = {
                name = "Ctags",
                module = "blink-ctags",
                score_offset = -10,
                min_keyword_length = 4,
            },
        },
    },
    fuzzy = {
        max_typos = function(keyword)
            return math.floor(#keyword / 6)
        end,
        prebuilt_binaries = {
            download = false,
        },
    },
    cmdline = {
        enabled = false,
    },
    term = {
        enabled = false,
    },
})
