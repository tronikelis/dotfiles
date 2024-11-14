local action_map = {
    current = [[let @+ = expand("%:t")]],
    absolute = [[let @+ = expand("%:p")]],
    relative = [[let @+ = expand("%:~:.")]],
}

vim.api.nvim_create_user_command("YankPath", function(cmd)
    local action = cmd.fargs[1] or "relative"
    vim.cmd(action_map[action])
end, {
    desc = "Yanks file paths into system clipboard",
    nargs = "?",
    complete = function()
        return vim.tbl_keys(action_map)
    end,
})
