---@param buf integer
---@param from integer
---@param to integer
---@param lines string[]
local function nvim_buf_set_lines(buf, from, to, lines)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, from, to, true, lines)
    vim.bo[buf].modifiable = false
end

vim.api.nvim_create_user_command("GitShow", function(ev)
    local current_buf = vim.api.nvim_get_current_buf()
    assert(vim.bo.buftype == "", "buftype not empty")

    local git_root = vim.fs.root(current_buf, ".git")
    assert(git_root, "not in git directory")
    local file = vim.fn.expand("%:p"):sub(#git_root + 2)

    local bufname = string.format("gitshow:%s:///%s", ev.fargs[1], vim.fn.fnamemodify(file, ":~:."))
    local buf = vim.fn.bufnr(bufname)
    if buf == -1 then
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(buf, bufname)
    end
    nvim_buf_set_lines(buf, 0, -1, {})

    vim.bo[buf].undofile = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].filetype = vim.bo[current_buf].filetype

    vim.system(
        { "git", "--no-pager", "show", string.format("%s:%s", ev.fargs[1], file) },
        {
            text = true,
            cwd = git_root,
            stdout = function(err, data)
                if err then
                    print("error reading stdout:", err)
                    return
                end
                if not data then
                    return
                end

                vim.schedule(function()
                    local lines = vim.split(data, "\n")
                    nvim_buf_set_lines(buf, -2, -1, lines)
                end)
            end,
        },
        vim.schedule_wrap(function(out)
            if out.code ~= 0 then
                vim.api.nvim_buf_delete(buf, { force = true })
                if out.stderr ~= "" then
                    error(out.stderr)
                end
                return
            end

            vim.api.nvim_set_current_buf(buf)
        end)
    ):wait()
end, { nargs = 1 })
