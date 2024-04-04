return {
	"lewis6991/gitsigns.nvim",
	config = function()
		require("gitsigns").setup({
			current_line_blame = true,

			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")
				local opts = { buffer = bufnr }

				vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, opts)
				vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, opts)
			end,
		})
	end,
}
