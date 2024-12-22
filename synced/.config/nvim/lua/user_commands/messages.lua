local M = {}

function M.setup()
    local function messages()
        local out = vim.api.nvim_exec2("messages", { output = true }).output

        out = vim.trim(out)
        out = vim.split(out, "\n")

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, out)

        vim.bo[buf].modified = false
        vim.bo[buf].buflisted = false
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].swapfile = false
        vim.bo[buf].modifiable = false

        vim.cmd("new")
        local win = vim.api.nvim_get_current_win()

        vim.api.nvim_win_set_buf(win, buf)
        vim.api.nvim_win_set_height(win, 10)
    end

    vim.api.nvim_create_user_command("Messages", messages, { desc = ":messages but in a buffer" })
end

return M
