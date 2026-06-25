require("utils").assert_notify(vim.fn.executable("fd") == 1, ":E command requires fd", vim.log.levels.INFO)

local function get_cwd()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir()
    end
    if vim.bo.buftype ~= "" then
        return
    end
    return vim.fn.expand("%:p:h")
end

local function accept(arg)
    local file = arg.fargs[1]
    local curr_dir = get_cwd()

    vim.cmd.e(vim.fs.joinpath(curr_dir, file))
end

local function complete(query)
    local out = vim.system(
        { "fd", "--type", "f", "--hidden", "--full-path", "--max-results", "100", query },
        { text = true, cwd = get_cwd() }
    ):wait()
    require("utils").assert_notify(out.code == 0, "fd command failed")
    return vim.split(out.stdout or "", "\n", { trimempty = true })
end

vim.api.nvim_create_user_command("E", accept, {
    nargs = 1,
    complete = complete,
})
