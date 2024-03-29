local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("plugins.theme"),
	require("plugins.telescope"),
	require("plugins.tree-sitter"),
	require("plugins.lsp"),
	require("plugins.formatter"),
	require("plugins.gitsigns"),
	require("plugins.terminal"),

	-- small plugins that don't need config
	"tpope/vim-sleuth",
	{
		"numToStr/Comment.nvim",
		lazy = false,
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup()
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("ibl").setup({
				scope = {
					show_start = false,
					show_end = false,
				},
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
		lazy = true,
		event = "VeryLazy",
	},
})
