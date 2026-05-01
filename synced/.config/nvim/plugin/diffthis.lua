local function new_buf()
    local term_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[term_buf].bufhidden = "wipe"
    vim.bo[term_buf].undofile = false
    vim.bo[term_buf].scrollback = math.pow(10, 5) -- maximum
    return term_buf
end

---@return number?
local function get_diff_current_line()
    local line = vim.api.nvim_get_current_line()
    local num = line:match("^ %d*%s*⋮%s*(%d+)")
    if num then
        return tonumber(num)
    end
    num = line:match("^%s*(%d+)")
    if num then
        return tonumber(num)
    end
end

---@param tabid integer
---@param prev_buf integer
---@param cursor integer[]
local function attach(tabid, prev_buf, cursor)
    vim.wo[0][0].number = true
    vim.wo[0][0].relativenumber = true

    vim.cmd("stopinsert")
    vim.fn.search(string.format([[^ \d*\s*⋮ %d]], cursor[1]), "cw")

    vim.keymap.set("n", "q", function()
        vim.api.nvim_set_current_buf(prev_buf)
    end, { buffer = 0 })
    vim.keymap.set("n", "<esc>", function()
        vim.api.nvim_set_current_buf(prev_buf)
    end, { buffer = 0 })

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = 0,
        callback = function()
            local current_line = get_diff_current_line()
            vim.schedule(function()
                if vim.api.nvim_tabpage_is_valid(tabid) then
                    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tabid))
                end
                if current_line and vim.api.nvim_get_current_buf() == prev_buf then
                    vim.cmd(tostring(current_line))
                end
            end)
        end,
    })
end

---@param ev vim.api.keyset.create_user_command.command_args
local function diffthis(ev)
    if
        not require("utils").assert_notify(
            vim.bo.buftype == "" and vim.fn.expand("%:p"):sub(1, 1) == "/",
            "Buffer not a regular file"
        )
    then
        return
    end

    local git_root = vim.fs.root(0, ".git")
    if not require("utils").assert_notify(git_root, "Buffer not in git directory") then
        return
    end

    local file = vim.fn.expand("%:p"):sub(#git_root + 2)
    local cursor = vim.api.nvim_win_get_cursor(0)

    if vim.system(require("utils").flatten({ "git", "diff", ev.fargs, "--quiet", "--", file })):wait().code == 0 then
        vim.notify("No differences")
        return
    end

    local extra_options = vim.iter(ev.fargs)
        :map(function(v)
            return vim.fn.shellescape(v)
        end)
        :totable()

    local cmd = string.format(
        "git diff %s -- %s | delta --line-numbers --paging=never",
        table.concat(extra_options, " "),
        vim.fn.shellescape(file)
    )

    local prev_buf = vim.api.nvim_get_current_buf()
    local buf = new_buf()

    vim.cmd("tab split")
    local tabid = vim.api.nvim_get_current_tabpage()

    vim.api.nvim_set_current_buf(buf)

    vim.fn.jobstart(cmd, {
        cwd = git_root,
        term = true,
        on_exit = function()
            vim.api.nvim_buf_call(buf, function()
                attach(tabid, prev_buf, cursor)
            end)
        end,
    })
end

vim.api.nvim_create_user_command("Diffthis", diffthis, {
    nargs = "*",
})
