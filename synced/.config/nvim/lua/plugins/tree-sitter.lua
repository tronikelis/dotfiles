return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-context",
			config = function()
				require("treesitter-context").setup({
					enable = true,
					max_lines = 3,
					multiline_threshold = 1,
					min_window_height = 25,
				})

				vim.keymap.set("n", "[c", function()
					require("treesitter-context").go_to_context(vim.v.count1)
				end)
			end,
		},
	},
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"rust",
				"go",
				"bash",
				"json",
				"yaml",
				"c",
				"markdown",
				"java",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"html",
				"typescript",
				"tsx",
				"css",
				"scss",
			},
			sync_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
		})
	end,
}
