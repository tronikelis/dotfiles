vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        vim.fn.jobstart("killall prettierd eslint_d", { detach = true })
    end,
})

-- specify conform.format opts based on the ft
local format_opts_by_ft = {
    -- on templ files run only the templ lsp formatter
    -- because html lsp also would run otherwise
    templ = { name = "templ" },
}

local function format_async(args)
    local range = nil

    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end

    require("conform").format(
        vim.tbl_deep_extend("keep", { async = true, range = range }, format_opts_by_ft[vim.bo.filetype] or {}),
        function(err)
            if err then
                print(" 󰅙 " .. err)
                return
            end

            print(" 󰗠 Formatted")
        end
    )
end

local format_cmds = {
    enable = function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
    end,
    disable = function(args)
        if args.bang then
            vim.g.disable_autoformat = true
        else
            vim.b.disable_autoformat = true
        end
    end,
}

vim.api.nvim_create_user_command("Format", function(args)
    local cmd = format_cmds[args.fargs[1]]
    if cmd then
        cmd(args)
        return
    end

    format_async(args)
end, {
    bang = true,
    range = true,
    nargs = "?",
    complete = function()
        return vim.tbl_keys(format_cmds)
    end,
})

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
