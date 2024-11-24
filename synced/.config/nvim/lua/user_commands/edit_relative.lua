if vim.fn.executable("fzf") == 0 then
    print(":E command requires fzf")
end

local function accept(arg)
    local file = arg.fargs[1]
    local curr_dir = vim.fn.expand("%:p:h")

    vim.cmd("e " .. vim.fs.joinpath(curr_dir, file))
end

local function files_in(dir)
    local files = {}

    for name, type in vim.fs.dir(dir) do
        if type == "file" then
            table.insert(files, name)
        end
    end

    table.sort(files)

    return files
end

local function complete(query)
    query = query or ""

    local files = files_in(vim.fn.expand("%:p:h"))

    local out = vim.system({ "fzf", "-f", query }, { text = true, stdin = table.concat(files, "\n") }):wait()

    if out.code ~= 0 then
        print(out.stderr)
        return
    end

    return vim.split(out.stdout, "\n", { trimempty = true })
end

vim.api.nvim_create_user_command("E", accept, {
    desc = "Kinda like :e but relative and depth 1",
    nargs = 1,
    complete = complete,
})
