return {
	"voldikss/vim-floaterm",
	config = function()
		local created = false

		vim.keymap.set("n", "<A-t>", function()
			if created == false then
				vim.cmd(string.format("FloatermNew --cwd=%s", vim.fn.getcwd()))
				created = true
				return
			end

			vim.cmd("FloatermToggle")
		end)

		vim.keymap.set("t", "<A-t>", function()
			vim.cmd("FloatermToggle")
		end)
	end,
}
