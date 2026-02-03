vim.keymap.set("n", "<c-w>d", function()
    local windows = vim.fn.gettabinfo()[1].windows

    for _, v in ipairs(windows) do
        if vim.api.nvim_win_get_config(v).relative ~= "" then
            vim.api.nvim_win_call(v, function()
                vim.cmd("split")
            end)
            return
        end
    end
end)
vim.keymap.set("n", "<c-w><c-d>", "<c-w>d", { remap = true })
