return {
	"lewis6991/gitsigns.nvim",
	config = function()
		local blame_fast = { "-w", "-C" }
		local blame_slow = { table.unpack(blame_fast), "-C", "-C" }

		require("gitsigns").setup({
			current_line_blame = true,
			current_line_blame_opts = {
				extra_opts = blame_fast,
			},

			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")
				local opts = { buffer = bufnr }

				vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, opts)
				vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, opts)

				vim.keymap.set("n", "<leader>hb", function()
					gitsigns.blame_line({ extra_opts = blame_slow })
				end, opts)
				vim.keymap.set("n", "<leader>hB", function()
					gitsigns.blame_line({ full = true, extra_opts = blame_slow })
				end, opts)

				vim.keymap.set("n", "[h", function()
					gitsigns.nav_hunk("prev")
				end, opts)

				vim.keymap.set("n", "]h", function()
					gitsigns.nav_hunk("next")
				end, opts)
			end,
		})
	end,
}
