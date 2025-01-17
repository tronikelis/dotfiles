local M = {}

function M.setup()
    ---@type string?
    local last_filetype
    ---@type table<string, integer?>
    local filetype_buf_map = {}

    vim.api.nvim_create_user_command("Scratchpad", function(ev)
        local filetype = ev.fargs[1]
        if not filetype then
            filetype = last_filetype
        end
        last_filetype = filetype

        if not filetype then
            error("no last filetype found")
        end

        ---@type integer?
        local buf = filetype_buf_map[filetype]

        if not buf or not vim.api.nvim_buf_is_valid(buf) then
            local file = string.format("%s.%s", vim.fn.tempname(), filetype)

            buf = vim.api.nvim_create_buf(false, false)
            filetype_buf_map[filetype] = buf

            vim.bo[buf].filetype = filetype
            vim.bo[buf].swapfile = false
            vim.api.nvim_buf_set_name(buf, file)
        end

        local width = math.floor(vim.o.columns * 0.85)
        local height = math.floor(vim.o.lines * 0.85)

        local col = math.floor((vim.o.columns - width) / 2)
        local row = math.floor((vim.o.lines - height) / 2)

        local win = vim.api.nvim_open_win(buf, true, {
            border = "single",
            relative = "editor",
            width = width,
            height = height,
            col = col,
            row = row,
            title = string.format("Scratchpad [%s]", filetype),
        })

        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(win),
            callback = function()
                -- on win close
                return true
            end,
        })
    end, { nargs = "?", complete = "filetype" })
end

return M
