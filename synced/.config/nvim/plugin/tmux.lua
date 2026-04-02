vim.api.nvim_create_user_command("Tmux", function(ev)
    local cwd = vim.fn.expand("%:p:h")
    if vim.bo.filetype == "oil" then
        cwd = assert(require("oil").get_current_dir())
    end

    local out = vim.system(require("utils").flatten({ "tmux", "split-window", ev.fargs, "-c", cwd })):wait()
    require("utils").assert_notify(out.code == 0, out.stderr)
end, {
    nargs = "*",
})
