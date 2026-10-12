function FindFunc(arg)
    local out = require("utils").system_find(arg, 100, {}):wait()
    require("utils").assert_notify(out.code == 0, "findfunc command failed")
    return vim.split(out.stdout or "", "\n", { trimempty = true })
end

vim.opt.findfunc = "v:lua.FindFunc"
