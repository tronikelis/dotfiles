local utils = require("utils")

local M = {}

local function expand(flags)
    if vim.bo.filetype == "oil" then
        return vim.fn.fnamemodify(require("oil").get_current_dir(), flags)
    end

    return vim.fn.expand("%" .. flags)
end

local function create_copy_expand(flags)
    return function(ev)
        local line = ""
        if ev.count ~= -1 then
            line = string.format("%d,%d:", ev.line1, ev.line2)
        end

        vim.fn.setreg("+", line .. expand(flags))
    end
end

local action_map = {
    current = create_copy_expand(":t"),
    absolute = create_copy_expand(":p"),
    relative = create_copy_expand(":~:."),
}

function M.setup()
    local function yank_path(ev)
        local action = action_map[ev.fargs[1] or "relative"]
        if action then
            action(ev)
        end
    end

    vim.api.nvim_create_user_command("YankPath", yank_path, {
        desc = "Yanks file paths into system clipboard",
        nargs = "?",
        complete = function(query)
            return utils.prefix_filter(query, vim.tbl_keys(action_map))
        end,
        range = true,
    })
end

return M
