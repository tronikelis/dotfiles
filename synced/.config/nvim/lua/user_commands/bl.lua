local utils = require("utils")

local M = {}

local cmds = {
    -- force restart lsp
    lsp = function()
        local buf = vim.api.nvim_get_current_buf()
        local function call(fn)
            vim.api.nvim_buf_call(buf, fn)
        end

        call(vim.cmd.LspStop)
        vim.defer_fn(function()
            call(vim.cmd.LspStop)
            vim.defer_fn(function()
                call(vim.cmd.LspStart)
            end, 1000)
        end, 1000)
    end,
}

function M.setup()
    vim.api.nvim_create_user_command(
        "Bl",
        vim.schedule_wrap(function(ev)
            local cmd = cmds[ev.fargs[1]]
            if not cmd then
                print("what you entering man??")
                return
            end

            cmd()
        end),
        {
            nargs = 1,
            complete = function(query)
                return utils.prefix_filter(query, vim.tbl_keys(cmds))
            end,
        }
    )
end

return M
