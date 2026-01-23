if vim.fn.executable("fzf") == 0 or vim.fn.executable("fd") == 0 then
    print(":E command requires fzf and fd")
end

local function get_cwd()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir()
    end
    return vim.fn.expand("%:p:h")
end

local function accept(arg)
    local file = arg.fargs[1]
    local curr_dir = get_cwd()

    vim.cmd.e(vim.fs.joinpath(curr_dir, file))
end

local function complete(query)
    query = query or ""

    local out = vim.system({
        "bash",
        "-c",
        string.format(
            [[fd -t f --strip-cwd-prefix=always --hidden | fzf -f %s | head -n 100]],
            vim.fn.shellescape(query)
        ),
    }, { text = true, cwd = get_cwd() }):wait()

    return vim.split(out.stdout or "", "\n", { trimempty = true })
end

vim.api.nvim_create_user_command("E", accept, {
    desc = "Kinda like :e but relative and depth 1",
    nargs = 1,
    complete = complete,
})
