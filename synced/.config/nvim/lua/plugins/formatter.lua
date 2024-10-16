vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        vim.fn.jobstart("killall prettierd eslint_d", { detach = true })
    end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
    if args.bang then
        -- FormatDisable! will disable formatting globally
        vim.g.disable_autoformat = true
    else
        vim.b.disable_autoformat = true
    end
end, {
    desc = "Disable autoformat-on-save",
    bang = true,
})

vim.api.nvim_create_user_command("FormatEnable", function()
    vim.b.disable_autoformat = false
    vim.g.disable_autoformat = false
end, {
    desc = "Re-enable autoformat-on-save",
})

-- specify conform.format opts based on the ft
local format_opts_by_ft = {
    -- on templ files run only the templ lsp formatter
    -- because html lsp also would run otherwise
    templ = { name = "templ" },
}

return {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    opts = {
        formatters_by_ft = {
            html = { "prettierd" },
            javascript = { "prettierd" },
            json = { "prettierd" },
            jsonc = { "prettierd" },
            tsx = { "prettierd" },
            typescript = { "prettierd" },
            typescriptreact = { "prettierd" },

            sh = { "shfmt" },
            zsh = { "shfmt" },

            gdscript = { "gdformat" },
            lua = { "stylua" },
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
        format_on_save = function(bufnr)
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
            end

            return format_opts_by_ft[vim.bo[bufnr].filetype] or {}
        end,
    },
}
