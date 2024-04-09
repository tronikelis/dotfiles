vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

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
			-- tree sitter ftw
			client.server_capabilities.semanticTokensProvider = nil

			local opts = { buffer = bufnr }
			local builtin = require("telescope.builtin")

			vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
			vim.keymap.set("n", "gr", builtin.lsp_references, opts)
			vim.keymap.set("n", "gt", builtin.lsp_type_definitions, opts)

			vim.keymap.set("n", "<leader>dc", function()
				builtin.diagnostics({ bufnr = 0 })
			end, opts)
			vim.keymap.set("n", "<leader>dC", function()
				builtin.diagnostics({ bufnr = bufnr })
			end, opts)

			vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
			vim.keymap.set("n", "<leader>dS", builtin.lsp_workspace_symbols, opts)

			vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<leader>t", vim.lsp.buf.hover, opts)

			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			local cmp = require("cmp")
			local lspkind = require("lspkind")

			cmp.setup({
				completion = { completeopt = "menu,menuone,noinsert" },
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "nvim_lsp_signature_help" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),

					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				formatting = {
					format = lspkind.cmp_format({
						menu = {
							nvim_lsp = "[LSP]",
							path = "[Path]",
							luasnip = "[LuaSnip]",
						},
					}),
				},
			})
		end)

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
