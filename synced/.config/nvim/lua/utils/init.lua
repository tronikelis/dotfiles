local dir_cycle = require("utils.dir_cycle")
local sudo = require("utils.sudo")

vim.keymap.set("n", "[f", function()
	dir_cycle.cycle_file(-1)
end)

vim.keymap.set("n", "]f", function()
	dir_cycle.cycle_file(1)
end)

vim.api.nvim_create_user_command("SudoWrite", sudo.sudo_write, { desc = "Writes to current file with 'sudo'" })
