return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
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
			vim.keymap.set("n", "gI", builtin.lsp_implementations, opts)
			vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, opts)
			vim.keymap.set("n", "<leader>D", builtin.lsp_type_definitions, opts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			local cmp = require("cmp")

			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),

					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
			})
		end)

		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = {
				"stylua",
				"gopls",
				"rust_analyzer",
				"tsserver",
				"lua_ls",
				"eslint",
				"jdtls",
				"prettierd",
				"eslint-lsp",
			},
		})
		require("mason-lspconfig").setup({
			handlers = {
				lsp_zero.default_setup,
			},
		})
	end,
}
