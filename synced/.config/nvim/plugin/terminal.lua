vim.api.nvim_create_user_command("Terminal", function(ev)
    if _G.terminal_current_buf and vim.api.nvim_buf_is_valid(_G.terminal_current_buf) then
        vim.api.nvim_buf_delete(_G.terminal_current_buf, { force = true })
    end

    vim.cmd("new")
    vim.cmd.terminal(ev.args)

    _G.terminal_current_buf = vim.api.nvim_get_current_buf()
    vim.bo.bufhidden = "wipe"
end, { nargs = "+" })
