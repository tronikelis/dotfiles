local M = {}

local action_map = {
    current = [[let @+ = expand("%:t")]],
    absolute = [[let @+ = expand("%:p")]],
    relative = [[let @+ = expand("%:~:.")]],
}

function M.setup()
    local function yank_path(ev)
        local action = ev.fargs[1] or "relative"
        vim.cmd(action_map[action])
    end

    vim.api.nvim_create_user_command("YankPath", yank_path, {
        desc = "Yanks file paths into system clipboard",
        nargs = "?",
        complete = function()
            return vim.tbl_keys(action_map)
        end,
    })
end

return M
