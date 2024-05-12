return {
	"catppuccin/nvim",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			no_italic = true,
			integrations = {
				treesitter = true,
				cmp = true,
				gitsigns = true,
				treesitter_context = true,
			},
		})

		vim.cmd.colorscheme("catppuccin")
	end,
}
