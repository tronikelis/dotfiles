function FindFunc(arg)
    local cmd = { "find", ".", "-type", "f", "-regextype", "egrep", "-regex", string.format(".*%s.*", arg) }
    if vim.fn.has("macunix") then
        cmd = { "find", "-E", ".", "-type", "f", "-regex", string.format(".*%s.*", arg) }
    end
    local find_escaped = vim.iter(cmd)
        :map(function(v)
            return vim.fn.shellescape(v)
        end)
        :join(" ")
    cmd = {
        "bash",
        "-c",
        string.format("%s | head -n 100", find_escaped),
    }

    if vim.fn.executable("fd") == 1 then
        cmd = { "fd", "--type", "f", "--hidden", "--full-path", "--max-results", "100", arg }
    end

    local out = vim.system(cmd, { text = true }):wait()
    require("utils").assert_notify(out.code == 0, "findfunc command failed")
    return vim.split(out.stdout or "", "\n", { trimempty = true })
end

vim.opt.findfunc = "v:lua.FindFunc"
