local augroup = vim.api.nvim_create_augroup("plugin/quickfix.lua", {})

vim.api.nvim_create_user_command("Cfuzzy", function(ev)
    local qf = vim.iter(vim.fn.getqflist())
        :map(function(v)
            return vim.tbl_extend("force", v, { user_data = string.format("%s %s", vim.fn.bufname(v.bufnr), v.text) })
        end)
        :totable()
    local matched = vim.fn.matchfuzzy(qf, table.concat(ev.fargs, " "), { key = "user_data" })
    vim.fn.setqflist(matched)
end, {
    nargs = 1,
})

local function remove_qf_entry()
    local count = 1
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1]

    local mode = vim.api.nvim_get_mode().mode
    if vim.list_contains({ "v", "V", "\22" }, mode) then
        local region = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
        count = #region
        line = region[1][1][2]
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, true, true), "n", false)
    end

    local qf = vim.fn.getqflist()
    for _ = 1, count do
        table.remove(qf, line)
    end
    vim.fn.setqflist(qf)

    local new_cursor_line = math.min(cursor[1], #qf)
    local actual_line = vim.api.nvim_buf_get_lines(0, new_cursor_line - 1, new_cursor_line, true)[1]
    local new_cursor_col = math.min(cursor[2], #actual_line)
    vim.api.nvim_win_set_cursor(0, { new_cursor_line, new_cursor_col })
end

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "qf",
    callback = function(ev)
        vim.keymap.set({ "n", "x" }, "<leader>dd", remove_qf_entry, { buf = ev.buf })
    end,
})
