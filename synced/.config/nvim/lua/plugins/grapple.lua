return {
	"cbochs/grapple.nvim",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" },
	},
	config = function()
		local grapple = require("grapple")
		grapple.setup({
			scope = "git",
		})

		vim.keymap.set("n", "<leader><leader>", grapple.toggle_tags)
		vim.keymap.set("n", "<leader>m", grapple.toggle)

		vim.keymap.set("n", "[m", function()
			grapple.cycle_tags("next")
		end)
		vim.keymap.set("n", "]m", function()
			grapple.cycle_tags("prev")
		end)

		for i = 1, 9 do
			vim.keymap.set("n", string.format("<leader>%d", i), function()
				grapple.select({ index = i })
			end)
		end
	end,
}
