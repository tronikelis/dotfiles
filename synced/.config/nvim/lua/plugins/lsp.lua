local utils = require("utils")

vim.diagnostic.config({
    update_in_insert = true,
    severity_sort = true,
    virtual_text = {
        source = true,
        severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
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
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
    },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "williamboman/mason.nvim",
            opts = {},
        },

        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer",

        "onsails/lspkind.nvim",
    },
    config = function()
        local lsps = {
            jsonls = {
                settings = {
                    json = {
                        schemas = {
                            {
                                fileMatch = { "package.json" },
                                url = "https://json.schemastore.org/package.json",
                            },
                            {
                                fileMatch = { "tsconfig*.json" },
                                url = "https://json.schemastore.org/tsconfig.json",
                            },
                            {
                                fileMatch = { ".prettierr*" },
                                url = "https://json.schemastore.org/prettierrc.json",
                            },
                            {
                                fileMatch = { ".eslintr*" },
                                url = "https://json.schemastore.org/eslintrc.json",
                            },
                        },
                    },
                },
            },
            tailwindcss = {
                settings = {
                    tailwindCSS = {
                        experimental = {
                            classRegex = {
                                [["class":\s*"([^"]*)"]], -- templ
                                { "classNames=\\{([^}]*)\\}", "[\"'`]([^\"'`]*).*?[\"'`]" },
                                { "tv\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                                { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                                {
                                    "{[^{]*?class\\s*?:\\s*([\"'`]+?[\\s\\S]*?[\"'`]+?)",
                                    "[\"'`]([^\"'`]*).*?[\"'`]",
                                },
                            },
                        },
                    },
                },
            },
            eslint = {},
            zls = {
                settings = {
                    zls = {
                        enable_build_on_save = true,
                        build_on_save_step = "check",
                    },
                },
            },
            gopls = {
                settings = {
                    gopls = {
                        gofumpt = true,
                    },
                },
            },
            golangci_lint_ls = {},
            jdtls = {},
            lua_ls = {},
            rust_analyzer = {},
            taplo = {},
            ts_ls = {},
            cssls = {},
            yamlls = {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                        },
                    },
                },
            },
            html = {},
            dartls = {},
            gdscript = {},
            templ = {},
            marksman = {},
            clangd = {},
            hyprls = {},
            bashls = {},
            biome = {},
            rubocop = {},
            ruby_lsp = {},
        }

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
                local builtin = require("telescope.builtin")

                local function map(mode, l, r)
                    vim.keymap.set(mode, l, r, { buffer = event.buf })
                end

                map("n", "<leader>e", vim.diagnostic.open_float)
                map("n", "<leader>a", vim.lsp.buf.code_action)
                map("n", "<leader>t", vim.lsp.buf.hover)
                map("n", "<leader>rn", vim.lsp.buf.rename)

                map("n", "gd", builtin.lsp_definitions)
                map("n", "gr", builtin.lsp_references)
                map("n", "gt", builtin.lsp_type_definitions)
                -- uppercase cause I'll prob use the gi command
                map("n", "gI", builtin.lsp_implementations)

                map("n", "<leader>dc", function()
                    local severity = (vim.v.count == 0 and { nil } or { vim.v.count })[1]
                    builtin.diagnostics({ bufnr = 0, severity = severity })
                end)
                map("n", "<leader>dC", function()
                    local severity = (vim.v.count == 0 and { nil } or { vim.v.count })[1]
                    builtin.diagnostics({ severity = severity })
                end)

                map("n", "<leader>ds", builtin.lsp_document_symbols)
                map("n", "<leader>dS", builtin.lsp_workspace_symbols)

                map(
                    "n",
                    "[e",
                    utils.keymap_each_count(function()
                        vim.diagnostic.goto_prev({ wrap = false })
                    end)
                )
                map(
                    "n",
                    "]e",
                    utils.keymap_each_count(function()
                        vim.diagnostic.goto_next({ wrap = false })
                    end)
                )
            end,
        })

        local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()

        local default_setup = function(server, options)
            options = options or {}
            options.capabilities = cmp_capabilities
            require("lspconfig")[server].setup(options)
        end

        for k, v in pairs(lsps) do
            default_setup(k, v)
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
                { name = "path" },
            }, {
                { name = "buffer", keyword_length = 4 },
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
