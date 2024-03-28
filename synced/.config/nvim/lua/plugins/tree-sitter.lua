return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
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
