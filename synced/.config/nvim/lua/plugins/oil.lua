return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("oil").setup({
			keymaps = {
				["g?"] = false,
				["<cr>"] = "actions.select",
				["<C-s>"] = false,
				["<C-h>"] = false,
				["<C-t>"] = false,
				["<C-p>"] = false,
				["<C-c>"] = false,
				["<C-l>"] = false,
				["-"] = "actions.parent",
				["_"] = false,
				["`"] = false,
				["~"] = false,
				["gs"] = false,
				["gx"] = false,
				["g."] = false,
				["g\\"] = false,
			},
			view_options = {
				show_hidden = true,
			},
		})

		vim.keymap.set("n", "-", "<cmd>Oil<cr>")
		vim.keymap.set("n", "<leader>-", require("oil").toggle_float)
	end,
}
