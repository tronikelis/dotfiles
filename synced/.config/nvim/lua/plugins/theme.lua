return {
	"catppuccin/nvim",
	priority = 1000,
	config = function()
		require("catppuccin").setup({
			integrations = {
				treesitter = true,
				cmp = true,
				gitsigns = true,
			},
		})

		vim.cmd.colorscheme("catppuccin")
	end,
}
