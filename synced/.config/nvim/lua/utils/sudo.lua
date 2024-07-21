local log = require("utils.log")

local M = {}

M.sudo_exec = function(cmd)
	vim.fn.inputsave()
	local password = vim.fn.inputsecret("Password: ")
	vim.fn.inputrestore()

	if not password or #password == 0 then
		log.info("invalid password, sudo aborted")
		return false
	end

	local out = vim.fn.system(string.format("sudo -S %s", cmd), password)

	if vim.v.shell_error ~= 0 then
		print("\n")
		log.err(out)
		return false
	end

	return true
end

M.sudo_write = function()
	local tmpfile = vim.fn.tempname()
	local filepath = vim.fn.expand("%:p")

	if not filepath or #filepath == 0 then
		log.err("empty filepath")
		return
	end

	local stat = vim.system({ "stat", vim.fn.shellescape(filepath) }):wait()
	if stat.code ~= 0 then
		log.err(string.format("filepath '%s' does not exist", filepath))
		return
	end

	vim.cmd(string.format("silent w! %s", tmpfile))

	if not M.sudo_exec(string.format("cp %s %s", vim.fn.shellescape(tmpfile), vim.fn.shellescape(filepath))) then
		return
	end

	vim.cmd("e!")
	vim.fn.delete(tmpfile)
end

return M
