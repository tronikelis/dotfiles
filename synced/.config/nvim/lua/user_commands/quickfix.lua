local M = {}

local function cmd_preview(ev)
    vim.cmd(ev.args)
    return 1
end

function M.setup()
    vim.api.nvim_create_user_command("Cfdo", function(ev)
        vim.cmd.cfdo(ev.args)
    end, {
        preview = cmd_preview,
        nargs = "+",
    })

    vim.api.nvim_create_user_command("Cdo", function(ev)
        vim.cmd.cdo(ev.args)
    end, {
        preview = cmd_preview,
        nargs = "+",
    })
end

return M
