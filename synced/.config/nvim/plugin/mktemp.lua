vim.api.nvim_create_user_command("Mktemp", function(ev)
    local tmpfile = string.format("%s.%s", vim.fn.tempname(), ev.fargs[1])
    vim.cmd("new")
    vim.cmd.e(tmpfile)
end, {
    nargs = 1,
})
