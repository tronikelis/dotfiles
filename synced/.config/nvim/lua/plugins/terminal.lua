return {
	"voldikss/vim-floaterm",
	config = function()
		local keymap = "<A-t>"

		if vim.fn.has("macunix") == 1 then
			-- nice mac
			keymap = "†"
		end

		vim.keymap.set("n", keymap, function()
			vim.cmd("FloatermToggle")
		end)

		vim.keymap.set("t", keymap, function()
			vim.cmd("FloatermToggle")
		end)
	end,
}
