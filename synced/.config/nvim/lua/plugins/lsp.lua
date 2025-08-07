vim.diagnostic.config({
    underline = true,
    update_in_insert = true,
    severity_sort = true,
    virtual_text = {
        source = true,
        current_line = true,
    },
    float = {
        border = "rounded",
        source = true,
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
    vim.diagnostic.jump({ wrap = false, count = -vim.v.count1, float = true })
end)
vim.keymap.set("n", "]e", function()
    vim.diagnostic.jump({ wrap = false, count = vim.v.count1, float = true })
end)

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "mason-org/mason.nvim",
            opts = {},
        },

        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-buffer",

        "onsails/lspkind.nvim",
    },
    config = function()
        vim.lsp.config("*", {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })

        for lsp in vim.fs.dir("~/.config/nvim/lsp") do
            local name = lsp:match("(.*)%.lua")
            vim.lsp.enable(name)
        end

        local cmp = require("cmp")
        cmp.setup({
            preselect = cmp.PreselectMode.Item,
            completion = {
                completeopt = "menu,menuone,noinsert",
                -- disables triggering popup when line is empty
                -- https://github.com/hrsh7th/nvim-cmp/pull/2087
                get_trigger_characters = function(trigger_characters)
                    if vim.trim(vim.api.nvim_get_current_line()) == "" then
                        return {}
                    end

                    return trigger_characters
                end,
                keyword_length = 1,
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
            }, {
                {
                    name = "buffer",
                    option = {
                        keyword_length = 4,
                    },
                    keyword_length = 4,
                },
            }),
            mapping = cmp.mapping.preset.insert({
                ["<C-n>"] = cmp.mapping.select_next_item({
                    behavior = cmp.SelectBehavior.Select,
                }),
                ["<C-p>"] = cmp.mapping.select_prev_item({
                    behavior = cmp.SelectBehavior.Select,
                }),

                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),

                ["<Tab>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete({}),
            }),
            formatting = {
                format = require("lspkind").cmp_format({
                    maxwidth = {
                        menu = 30,
                    },
                    ellipsis_char = "...",
                    -- shows details like auto import sources
                    show_labelDetails = true,
                    mode = "symbol",
                    menu = {
                        nvim_lsp = "[LSP]",
                        path = "[PTH]",
                        buffer = "[BUF]",
                    },
                }),
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            view = {
                entries = {
                    selection_order = "near_cursor",
                },
            },
            snippet = {
                expand = function(arg)
                    vim.snippet.expand(arg.body)
                end,
            },
        })

        local function stop_snippet()
            if vim.snippet.active() then
                vim.snippet.stop()
            end
        end

        vim.api.nvim_create_autocmd("InsertLeave", {
            callback = stop_snippet,
        })

        vim.keymap.set({ "i", "s", "n" }, "<a-n>", function()
            if vim.snippet.active({ direction = 1 }) then
                vim.snippet.jump(1)
            end
        end)
        vim.keymap.set({ "i", "s", "n" }, "<a-p>", function()
            if vim.snippet.active({ direction = -1 }) then
                vim.snippet.jump(-1)
            end
        end)
    end,
}
