-- huge thanks to
-- https://github.com/kovidgoyal/kitty/discussions/6485#discussioncomment-7219071

vim.opt.clipboard = "unnamedplus"
vim.opt.number = false
vim.opt.relativenumber = true
vim.opt.statuscolumn = ""
vim.opt.signcolumn = "no"
vim.opt.scrollback = 100000
vim.opt.cursorline = true
vim.opt.wrap = false

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

local orig_buf = vim.api.nvim_get_current_buf()

local lines = vim.api.nvim_buf_get_lines(orig_buf, 0, -1, false)
while #lines > 0 and vim.trim(lines[#lines]) == "" do
	lines[#lines] = nil
end

local buf = vim.api.nvim_create_buf(false, true)
local channel = vim.api.nvim_open_term(buf, {})
vim.api.nvim_chan_send(channel, table.concat(lines, "\r\n"))

vim.api.nvim_set_current_buf(buf)
vim.api.nvim_buf_delete(orig_buf, { force = true })

vim.bo.modified = false

vim.api.nvim_create_autocmd("TermEnter", { buffer = buf, command = "stopinsert" })

vim.defer_fn(function()
	-- go to the end of the terminal buffer
	vim.cmd.startinsert()
end, 10)
