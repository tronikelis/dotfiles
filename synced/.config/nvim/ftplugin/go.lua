-- peak mapping
vim.keymap.set("n", "<leader>ie", "oif err != nil {<cr>return err<cr>}<esc>", { buf = 0 })

vim.api.nvim_buf_create_user_command(0, "GoTesthis", function()
    vim.cmd.Terminal(string.format("go test ./%s", vim.fn.shellescape(vim.fn.expand("%:~:.:h"))))
end, {})
