require("xylene").setup({
    get_current_file_dir = function()
        if vim.bo.filetype == "oil" then
            return require("oil").get_current_dir()
        end
        return vim.fn.expand("%:p")
    end,
    on_attach = function(renderer)
        local function map(mode, l, r)
            vim.keymap.set(mode, l, r, { buffer = renderer.buf })
        end

        map("n", "<cr>", function()
            renderer:toggle(vim.api.nvim_win_get_cursor(0)[1])
        end)

        map("n", "!", function()
            renderer:toggle_all(vim.api.nvim_win_get_cursor(0)[1])
        end)

        map("n", "<leader>-", function()
            local file = renderer:find_file_line(vim.api.nvim_win_get_cursor(0)[1])
            if not file then
                return
            end

            require("oil").open(file.path)
        end)
    end,
})
