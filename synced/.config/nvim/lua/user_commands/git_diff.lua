local M = {}

function M.setup()
    vim.api.nvim_create_user_command("GitDiff", function(ev)
        local patch = vim.fn.tempname()
        local current = vim.fn.expand("%:p")

        local out = vim.system({
            "git",
            "diff",
            "-R",
            unpack(ev.fargs),
            "--exit-code",
            string.format("--output=%s", patch),
            "--",
            current,
        }):wait()

        if out.code == 0 then
            print("No diff")
            return
        end
        if out.code ~= 1 then
            if out.stderr then
                error(vim.split(out.stderr, "\n")[1])
            end
            return
        end

        vim.cmd(string.format("silent vertical diffpatch %s", patch))
        local dangling_buf = vim.fn.bufnr(current .. ".new")

        vim.bo[dangling_buf].bufhidden = "delete"
    end, { nargs = "*" })
end

return M
