vim.api.nvim_create_user_command("Cfuzzy", function(ev)
    local qf = vim.fn.getqflist()
    local matched = vim.fn.matchfuzzy(qf, table.concat(ev.fargs, " "), { key = "text" })
    vim.fn.setqflist(matched)
end, {
    nargs = 1,
})
