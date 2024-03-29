return {
	"voldikss/vim-floaterm",
	config = function()
		local created = false
		local keymap = "<A-t>"

		if vim.fn.has("macunix") == 1 then
			-- nice mac
			keymap = "†"
		end

		vim.keymap.set("n", keymap, function()
			if created == false then
				vim.cmd(string.format("FloatermNew --cwd=%s", vim.fn.getcwd()))
				created = true
				return
			end

			vim.cmd("FloatermToggle")
		end)

		vim.keymap.set("t", keymap, function()
			vim.cmd("FloatermToggle")
		end)
	end,
}
