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

local ensure_installed = {
	"clangd",
	"hyprls",
	"bashls",
	"css-lsp",
	"docker_compose_language_service",
	"dockerls",
	"eslint-lsp",
	"gopls",
	"html-lsp",
	"jdtls",
	"json-lsp",
	"lua_ls",
	"prettierd",
	"rust_analyzer",
	"shellcheck",
	"shfmt",
	"stylua",
	"tailwindcss-language-server",
	"taplo",
	"tsserver",
	"typos-lsp",
	"yamlls",
}

local get_eslint_options = function()
	return {
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
	}
end

local get_tailwindcss_options = function()
	return {
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
	}
end

local get_jsonls_options = function()
	return {
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
	}
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"yioneko/nvim-cmp",
			branch = "perf",
		},
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-buffer",

		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"onsails/lspkind.nvim",
		"williamboman/mason-lspconfig.nvim",
		"williamboman/mason.nvim",
		{
			"j-hui/fidget.nvim",
			config = function()
				require("fidget").setup()
			end,
		},
	},
	config = function()
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
			}, { { name = "path" } }, { { name = "buffer", keyword_length = 4 } }),
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
					follow_cursor = true,
				},
			},
			snippet = {
				expand = function(arg)
					vim.snippet.expand(arg.body)
				end,
			},
		})

		vim.keymap.set({ "i", "s" }, "<A-n>", function()
			if vim.snippet.active({ direction = 1 }) then
				vim.snippet.jump(1)
			end
		end)
		vim.keymap.set({ "i", "s" }, "<A-p>", function()
			if vim.snippet.active({ direction = -1 }) then
				vim.snippet.jump(-1)
			end
		end)

		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
		})
		require("mason-lspconfig").setup({
			handlers = {
				default_setup,

				jsonls = function()
					default_setup("jsonls", get_jsonls_options())
				end,

				eslint = function()
					default_setup("eslint", get_eslint_options())
				end,

				tailwindcss = function()
					default_setup("tailwindcss", get_tailwindcss_options())
				end,
			},
		})

		-- lsp config without mason
		default_setup("dartls")
		default_setup("gdscript")
	end,
}
