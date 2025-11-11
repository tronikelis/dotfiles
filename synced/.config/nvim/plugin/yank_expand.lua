vim.api.nvim_create_user_command("YankExpand", function(ev)
    local line = ""
    if ev.count ~= -1 then
        line = string.format("%d,%d:", ev.line1, ev.line2)
    end

    local flag = ev.fargs[1] or "%"
    if flag:sub(1, 1) == "%" then
        if ev.bang then
            flag = flag .. ":p"
        else
            flag = flag .. ":~:."
        end
    end

    if vim.bo.filetype == "oil" then
        local dir = assert(require("oil").get_current_dir())
        if flag:sub(1, 1) == "%" then
            flag = flag:sub(2)
        end
        vim.fn.setreg("+", line .. vim.fn.fnamemodify(dir, flag))
        return
    end

    vim.fn.setreg("+", line .. vim.fn.expand(flag))
end, {
    nargs = "?",
    range = true,
    bang = true,
})
