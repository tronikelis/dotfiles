local augroup = vim.api.nvim_create_augroup("plugin/_pack_formatter.lua", {})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = augroup,
    callback = function()
        vim.fn.jobstart("killall prettierd eslint_d", { detach = true })
    end,
})

local function format_async(args)
    local range = nil

    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end

    require("conform").format({ async = true, range = range }, function(err)
        if err then
            print("[err]: " .. err)
            return
        end

        print("Formatted")
    end)
end

local format_cmds = {
    enable = function(args)
        if args.bang then
            vim.g.disable_autoformat = false
        end
        vim.b.disable_autoformat = false
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
    complete = function(query)
        return require("utils").prefix_filter(query, vim.tbl_keys(format_cmds))
    end,
})

local function biome_or_prettier(buf)
    if vim.fs.root(buf, { { "biome.json", "biome.jsonc" } }) then
        return { "biome" }
    end

    return { "prettierd" }
end

require("conform").setup({
    formatters_by_ft = {
        html = { "prettierd" },

        css = biome_or_prettier,
        scss = biome_or_prettier,
        javascript = biome_or_prettier,
        javascriptreact = biome_or_prettier,
        json = biome_or_prettier,
        jsonc = biome_or_prettier,
        typescript = biome_or_prettier,
        typescriptreact = biome_or_prettier,

        gdscript = { "gdformat" },
        lua = { "stylua" },
        templ = { name = "templ" },
        ruby = { name = "ruby_lsp" },
        python = { "black" },
    },
    default_format_opts = {
        lsp_format = "fallback",
        stop_after_first = true,
    },
    format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
        end

        return {}
    end,
})

---@param buf integer
local function set_formatexpr(buf)
    local formatters, lsp = require("conform").list_formatters_to_run(buf)
    if lsp or #formatters ~= 0 then
        vim.bo[buf].formatexpr = "v:lua.require'conform'.formatexpr()"
    end
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(ev)
        set_formatexpr(ev.buf)
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    callback = function(ev)
        set_formatexpr(ev.buf)
    end,
})
