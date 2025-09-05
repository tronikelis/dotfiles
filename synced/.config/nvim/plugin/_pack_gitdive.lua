require("gitdive").setup({
    get_absolute_file = function()
        if vim.bo.filetype == "oil" then
            return require("oil").get_current_dir()
        end

        return vim.fn.expand("%:p")
    end,
})
