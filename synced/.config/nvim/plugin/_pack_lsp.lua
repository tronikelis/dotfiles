local augroup = vim.api.nvim_create_augroup("plugin/_pack_lsp.lua", {})

vim.diagnostic.config({
    underline = true,
    severity_sort = true,
    virtual_text = {
        source = true,
        current_line = true,
    },
    float = {
        border = "rounded",
        source = true,
    },
    jump = {
        wrap = false,
        float = true,
    },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
            [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
    },
})

vim.keymap.set("n", "<leader>t", function()
    vim.lsp.buf.hover({ border = "rounded" })
end)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>rn", function()
    local renamed = false
    renamed = require("ts-autotag").rename(nil, true)
    if renamed then
        return
    end

    vim.lsp.buf.rename()
end)
vim.keymap.set("n", "[e", function()
    vim.diagnostic.jump({ severity = vim.diagnostic.severity.E, count = -vim.v.count1 })
end)
vim.keymap.set("n", "]e", function()
    vim.diagnostic.jump({ severity = vim.diagnostic.severity.E, count = vim.v.count1 })
end)
vim.keymap.set("n", "[w", function()
    vim.diagnostic.jump({ severity = vim.diagnostic.severity.W, count = -vim.v.count1 })
end)
vim.keymap.set("n", "]w", function()
    vim.diagnostic.jump({ severity = vim.diagnostic.severity.W, count = vim.v.count1 })
end)
vim.keymap.set({ "n", "i" }, "<c-s>", function()
    vim.lsp.buf.signature_help({ border = "rounded" })
end)

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

local function stop_snippet()
    if vim.snippet.active() then
        vim.snippet.stop()
    end
end

vim.api.nvim_create_autocmd("InsertLeave", {
    group = augroup,
    callback = stop_snippet,
})
