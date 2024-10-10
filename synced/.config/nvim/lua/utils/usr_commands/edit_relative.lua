local log = require("utils.log")
local path = require("utils.path")

if vim.fn.executable("fzf") == 0 then
    log.warn("E cmd requires fzf")
end

local accept = function(arg)
    local file = arg.fargs[1]
    local curr_dir = path.curr_full_dir()

    vim.cmd("e " .. vim.fs.joinpath(curr_dir, file))
end

local complete = function(query)
    query = query or ""

    local files = path.files(path.curr_full_dir())

    local out = vim.system({ "fzf", "-f", query }, { text = true, stdin = vim.fn.join(files, "\n") }):wait()

    if out.code ~= 0 then
        log.err(out.stderr)
        return
    end

    return vim.fn.split(out.stdout, "\n")
end

vim.api.nvim_create_user_command("E", accept, {
    desc = "Kinda like :e but relative and depth 1",
    nargs = 1,
    complete = complete,
})
