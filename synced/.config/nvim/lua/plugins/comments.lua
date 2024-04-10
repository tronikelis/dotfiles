return {
	-- main comment plugin
	"numToStr/Comment.nvim",
	lazy = false,

	dependencies = {
		{
			-- dynamic comment changing based on scope (jsx, ts) in same file
			"JoosepAlviste/nvim-ts-context-commentstring",
			dependencies = {
				"nvim-treesitter/nvim-treesitter",
			},
			config = function()
				require("ts_context_commentstring").setup({
					enable_autocmd = false,
				})
			end,
		},
	},
	config = function()
		require("Comment").setup({
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})
	end,
}
