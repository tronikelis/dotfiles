return {
	"cbochs/grapple.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local grapple = require("grapple")
		grapple.setup({
			scope = "git",
			win_opts = {
				border = "rounded",
			},
		})

		vim.keymap.set("n", "<leader><leader>", grapple.toggle_tags)
		vim.keymap.set("n", "<leader>m", grapple.toggle)

		vim.keymap.set("n", "[m", function()
			grapple.cycle_tags("prev")
		end)
		vim.keymap.set("n", "]m", function()
			grapple.cycle_tags("next")
		end)

		for i = 1, 9 do
			vim.keymap.set("n", string.format("<leader>%d", i), function()
				grapple.select({ index = i })
			end)
		end

		require("telescope").load_extension("grapple")
		vim.keymap.set("n", "<leader>gp", require("telescope").extensions.grapple.tags)
	end,
}
