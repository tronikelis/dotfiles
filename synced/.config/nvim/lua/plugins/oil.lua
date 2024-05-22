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

		-- https://www.reddit.com/r/neovim/comments/1cwd181/comment/l4wqmza/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
		-- sets cwd to git dir
		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function(ctx)
				local dir = require("oil").get_current_dir() or ctx.buf
				local root = vim.fs.root(dir, { ".git" })
				if root then
					vim.uv.chdir(root)
				end
			end,
		})
	end,
}
