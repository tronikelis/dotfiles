local utils = require("utils")

vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= "quickfix" then
            return
        end

        vim.keymap.set("n", "dd", function()
            local cursor = vim.api.nvim_win_get_cursor(0)

            local entries = vim.fn.getqflist()
            local rm_index = cursor[1]
            table.remove(entries, rm_index)
            vim.fn.setqflist(entries)

            vim.api.nvim_win_set_cursor(0, { utils.clamp_linecount(cursor[1]), cursor[2] })
        end, { buffer = ev.buf })

        vim.keymap.set("v", "d", function()
            local cursor = vim.api.nvim_win_get_cursor(0)

            local from, to = vim.fn.line("v"), vim.fn.line(".")
            local qf = {}
            for i, v in ipairs(vim.fn.getqflist()) do
                if i < from or i > to then
                    table.insert(qf, v)
                end
            end
            vim.fn.setqflist(qf)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, true, true), "nv", false)

            vim.api.nvim_win_set_cursor(0, { utils.clamp_linecount(from), cursor[2] })
        end, { buffer = ev.buf })
    end,
})
