local M = {}

function M.setup()
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

        local files = vim.system({ "fd", "-t", "f", "--strip-cwd-prefix=always" }, { text = true, cwd = get_cwd() })
            :wait()
        if files.code ~= 0 then
            error(files.stdout .. files.stderr)
            return
        end

        local out = vim.system({ "fzf", "-f", query }, { text = true, stdin = files.stdout }):wait()
        if out.code ~= 0 then
            error(out.stdout .. out.stderr)
            return
        end

        return vim.split(out.stdout, "\n", { trimempty = true })
    end

    vim.api.nvim_create_user_command("E", accept, {
        desc = "Kinda like :e but relative and depth 1",
        nargs = 1,
        complete = complete,
    })
end

return M
