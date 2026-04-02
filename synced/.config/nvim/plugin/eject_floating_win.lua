vim.keymap.set("n", "<c-w>e", function()
    local windows = vim.fn.gettabinfo()[vim.fn.tabpagenr()].windows

    for _, v in ipairs(windows) do
        if vim.api.nvim_win_get_config(v).relative ~= "" then
            vim.api.nvim_win_call(v, function()
                vim.cmd("split")
            end)
            return
        end
    end
end)
vim.keymap.set("n", "<c-w><c-e>", "<c-w>e", { remap = true })
