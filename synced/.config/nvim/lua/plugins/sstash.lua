return {
    "Tronikelis/sstash.nvim",
    event = "VeryLazy",
    opts = {
        write_on_leave = function()
            if vim.wo.diff then
                return false
            end

            local disabled_ft = { gitcommit = true, oil = true }
            return not disabled_ft[vim.bo.filetype]
        end,

        get_cwd = function()
            return vim.fs.root(0, ".git") or vim.fn.getcwd()
        end,
    },
}
