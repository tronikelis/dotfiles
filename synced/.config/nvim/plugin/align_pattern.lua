vim.api.nvim_create_user_command("AlignPattern", function(ev)
    local pattern = ev.fargs[1]
    local matches = {}
    for i = ev.line1, ev.line2 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, true)[1]
        table.insert(matches, vim.fn.match(line, pattern))
    end

    local matches_max = 0
    for _, v in ipairs(matches) do
        if v > matches_max then
            matches_max = v
        end
    end

    for i, v in ipairs(matches) do
        if v ~= -1 then
            local line = ev.line1 - 1 + i - 1
            local delta = matches_max - v
            vim.api.nvim_buf_set_text(0, line, v, line, v, { string.rep(" ", delta) })
        end
    end
end, {
    range = true,
    nargs = 1,
})
