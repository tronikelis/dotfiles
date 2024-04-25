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
		"hrsh7th/cmp-emoji",
		"lukas-reineke/cmp-under-comparator",
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

		lsp_zero.set_server_config({
			on_init = function(client)
				client.server_capabilities.semanticTokensProvider = nil
			end,
		})

		local cmp = require("cmp")
		local lspkind = require("lspkind")

		cmp.setup({
			preselect = cmp.PreselectMode.Item,
			completion = {
				completeopt = "menu,menuone,noinsert",
				keyword_length = 2,
			},
			sources = {
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "path" },
				{ name = "luasnip" },
				{ name = "emoji" },
			},
			sorting = {
				priority_weight = 2,
				comparators = {
					cmp.config.compare.offset,
					cmp.config.compare.exact,
					cmp.config.compare.score,
					cmp.config.compare.recently_used,
					require("cmp-under-comparator").under,
					cmp.config.compare.kind,
				},
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
				"stylua",
				"tailwindcss-language-server",
				"gopls",
				"rust_analyzer",
				"tsserver",
				"lua_ls",
				"eslint",
				"jdtls",
				"prettierd",
				"eslint-lsp",
				"typos-lsp",
				"html-lsp",
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
							".eslintrc"
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
	end,
}
