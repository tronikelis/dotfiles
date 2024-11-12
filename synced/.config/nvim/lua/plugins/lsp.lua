local ensure_installed = {
    "css-lsp",
    "eslint-lsp",
    "html-lsp",
    "json-lsp",
    "prettierd",
    "tailwindcss-language-server",
    "typescript-language-server",

    "bash-language-server",
    "clangd",
    "cspell",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "gopls",
    "hyprls",
    "jdtls",
    "lua-language-server",
    "marksman",
    "rust-analyzer",
    "shellcheck",
    "shfmt",
    "stylua",
    "taplo",
    "templ",
    "yaml-language-server",
    "zls",
}

local function install_mason_tools()
    local registry = require("mason-registry")

    registry.refresh(function()
        for _, v in ipairs(ensure_installed) do
            local pkg = registry.get_package(v)

            if not registry.is_installed(v) then
                pkg:install()
            end
        end
    end)
end

vim.diagnostic.config({
    update_in_insert = true,
    severity_sort = true,
    virtual_text = {
        source = true,
    },
    float = {
        border = "rounded",
        source = true,
    },
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>t", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

vim.keymap.set("n", "[e", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]e", vim.diagnostic.goto_next)

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
        vim.defer_fn(install_mason_tools, 3000)

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
            eslint = {
                root_dir = require("lspconfig").util.root_pattern(
                    ".eslintrc.js",
                    ".eslintrc.cjs",
                    ".eslintrc.mjs",
                    ".eslintrc.yaml",
                    ".eslintrc.yml",
                    ".eslintrc.json",
                    ".eslintrc",
                    "eslint.config.js",
                    "eslint.config.mjs",
                    "eslint.config.cjs",
                    "eslint.config.ts",
                    "eslint.config.mts",
                    "eslint.config.cts"
                ),
            },
            zls = {
                settings = {
                    zls = {
                        enable_build_on_save = true,
                        build_on_save_step = "check",
                    },
                },
            },
            gopls = {},
            jdtls = {},
            lua_ls = {},
            rust_analyzer = {},
            taplo = {},
            ts_ls = {},
            cssls = {},
            yamlls = {},
            html = {},
            dartls = {},
            gdscript = {},
            templ = {},
            marksman = {},
            clangd = {},
            hyprls = {},
            bashls = {},
            docker_compose_language_service = {},
            dockerls = {},
        }

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(event)
                local opts = { buffer = event.buf }
                local builtin = require("telescope.builtin")

                vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
                vim.keymap.set("n", "gr", builtin.lsp_references, opts)
                vim.keymap.set("n", "gt", builtin.lsp_type_definitions, opts)
                -- uppercase cause I'll prob use the gi command
                vim.keymap.set("n", "gI", builtin.lsp_implementations, opts)

                vim.keymap.set("n", "<leader>dc", function()
                    builtin.diagnostics({ bufnr = 0 })
                end, opts)
                vim.keymap.set("n", "<leader>dC", builtin.diagnostics, opts)

                vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
                vim.keymap.set("n", "<leader>dS", builtin.lsp_workspace_symbols, opts)
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
        vim.keymap.set("", "<a-l>", stop_snippet)

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
