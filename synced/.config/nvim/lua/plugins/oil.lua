return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local oil = require("oil")

		oil.setup({
			use_default_keymaps = false,
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name)
					return name == ".git" or name == ".."
				end,
			},
			watch_for_changes = true,
		})

		local actions = require("oil.actions")

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function(event)
				local bufnr = event.buf

				vim.keymap.set("n", "<Cr>", actions.select.callback, { buffer = bufnr })
				vim.keymap.set("n", "-", actions.parent.callback, { buffer = bufnr })
			end,
		})

		vim.keymap.set("n", "-", "<cmd>Oil<cr>")
		vim.keymap.set("n", "<leader>-", oil.toggle_float)
	end,
}
