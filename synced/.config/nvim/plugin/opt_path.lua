local has_fd = vim.fn.executable("fd") == 1
require("utils").assert_notify(has_fd, "fd not found, FindFunc will not be used", vim.log.levels.INFO)

function FindFunc(arg)
    local out = vim.system(
        { "fd", "--type", "f", "--hidden", "--full-path", "--max-results", "100", arg },
        { text = true }
    )
        :wait()
    require("utils").assert_notify(out.code == 0, "fd command failed")
    return vim.split(out.stdout or "", "\n", { trimempty = true })
end

vim.opt.path:append("**")
if has_fd then
    vim.opt.findfunc = "v:lua.FindFunc"
end
