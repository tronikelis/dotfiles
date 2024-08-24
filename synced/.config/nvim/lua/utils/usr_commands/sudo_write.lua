local log = require("utils.log")
local path = require("utils.path")

local get_password = function()
	vim.fn.inputsave()
	local password = vim.fn.inputsecret("Password: ")
	vim.fn.inputrestore()

	return password
end

local sudo_exec = function(cmd, password)
	if not password or #password == 0 then
		log.info("invalid password, sudo aborted")
		return false
	end

	local out = vim.system({ "sudo", "-S", table.unpack(cmd) }, { text = true, stdin = password }):wait()

	if out.code ~= 0 then
		print("\n")
		log.err(out.stderr)
		return false
	end

	-- clears the `Password: ****` in cmd
	vim.cmd("stopinsert")

	return true
end

local sudo_write = function()
	local tmp_file = vim.fn.tempname()
	local curr_file = path.curr_full_file()

	if not curr_file or #curr_file == 0 then
		log.err("empty filepath")
		return
	end

	local password = get_password()

	if not sudo_exec({ "touch", curr_file }, password) then
		return
	end

	vim.cmd(string.format("silent w! %s", tmp_file))

	if not sudo_exec({ "cp", tmp_file, curr_file }, password) then
		return
	end

	vim.cmd("e!")
	vim.fn.delete(tmp_file)
end

vim.api.nvim_create_user_command("SudoWrite", sudo_write, { desc = "Writes to current file with 'sudo'" })
