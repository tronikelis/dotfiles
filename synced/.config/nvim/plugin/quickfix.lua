vim.cmd("packadd cfilter")

---@param ev table
---@param ns integer
---@param buf integer
---@return integer
local function cmd_preview(ev, ns, buf)
    -- jump to err line
    vim.cmd("cc")
    return require("utils").inc_command_diff_preview(ev, ns, buf)
end

vim.api.nvim_create_user_command("Cfdo", function(ev)
    vim.cmd.cfirst()

    while true do
        local ok, err = pcall(function()
            vim.cmd(ev.args)
        end)
        if not ok then
            vim.notify(tostring(err), vim.log.levels.ERROR)
        end

        if not pcall(function()
            vim.cmd.cnfile()
        end) then
            break
        end
    end
end, {
    preview = cmd_preview,
    nargs = "+",
})

vim.api.nvim_create_user_command("Cdo", function(ev)
    vim.cmd.cfirst()

    while true do
        local ok, err = pcall(function()
            vim.cmd(ev.args)
        end)
        if not ok then
            vim.notify(tostring(err), vim.log.levels.ERROR)
        end

        if not pcall(function()
            vim.cmd.cnext()
        end) then
            break
        end
    end
end, {
    preview = cmd_preview,
    nargs = "+",
})

vim.api.nvim_create_user_command("Cfuzzy", function(ev)
    local qf = vim.fn.getqflist()
    local matched = vim.fn.matchfuzzy(qf, table.concat(ev.fargs, " "), { key = "text" })
    vim.fn.setqflist(matched)
end, {
    nargs = 1,
})
