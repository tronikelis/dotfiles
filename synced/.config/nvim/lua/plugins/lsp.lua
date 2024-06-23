vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>t", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

vim.keymap.set("n", "[e", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]e", vim.diagnostic.goto_next)

return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
		"onsails/lspkind.nvim",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"hrsh7th/cmp-path",
		{
			"j-hui/fidget.nvim",
			config = function()
				require("fidget").setup()
			end,
		},
	},
	config = function()
		local lsp_zero = require("lsp-zero")

		lsp_zero.on_attach(function(client, bufnr)
			local opts = { buffer = bufnr }
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
			vim.keymap.set("n", "gr", builtin.lsp_references, opts)
			vim.keymap.set("n", "gt", builtin.lsp_type_definitions, opts)
			vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)

			vim.keymap.set("n", "<leader>dc", function()
				builtin.diagnostics({ bufnr = 0 })
			end, opts)
			vim.keymap.set("n", "<leader>dC", builtin.diagnostics, opts)

			vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
			vim.keymap.set("n", "<leader>dS", builtin.lsp_workspace_symbols, opts)
		end)

		local cmp = require("cmp")
		local lspkind = require("lspkind")

		cmp.setup({
			preselect = cmp.PreselectMode.Item,
			completion = {
				completeopt = "menu,menuone,noinsert",
				keyword_length = 1,
			},
			sources = {
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "path" },
				{ name = "luasnip" },
			},
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
				format = lspkind.cmp_format({
					mode = "symbol",
					menu = {
						nvim_lsp = "[LSP]",
						path = "[Path]",
						luasnip = "[Snip]",
						emoji = "[Emoji]",
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
					follow_cursor = true,
				},
			},
		})

		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = {
				"yamlls",
				"taplo",
				"css-lsp",
				"json-lsp",
				"eslint-lsp",
				"prettier",
				"prettierd",
				"shfmt",
				"stylua",
				"tailwindcss-language-server",
				"gopls",
				"rust_analyzer",
				"tsserver",
				"lua_ls",
				"jdtls",
				"typos-lsp",
				"html-lsp",
				"docker_compose_language_service",
				"dockerls",
			},
		})
		require("mason-lspconfig").setup({
			handlers = {
				lsp_zero.default_setup,

				eslint = function()
					require("lspconfig").eslint.setup({
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
					})
				end,

				tailwindcss = function()
					require("lspconfig").tailwindcss.setup({
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
					})
				end,
			},
		})

		-- lsp config without mason
		require("lspconfig").dartls.setup({})
		require("lspconfig").gdscript.setup({})
	end,
}
