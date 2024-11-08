return {
    "tronikelis/sstash.nvim",
    event = "VeryLazy",
    opts = {
        write_on_leave = function()
            if vim.wo.diff then
                return false
            end

            local disabled_ft = { gitcommit = true, oil = true, gitrebase = true }
            return not disabled_ft[vim.bo.filetype]
        end,

        get_cwd = function()
            local cwd = vim.fn.getcwd()
            return vim.fs.root(cwd, ".git") or cwd
        end,
    },
}
