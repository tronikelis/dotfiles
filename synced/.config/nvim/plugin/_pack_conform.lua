local augroup = vim.api.nvim_create_augroup("plugin/_pack_conform.lua", {})

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
        if not require("utils").assert_notify(not err, err) then
            return
        end

        vim.notify("Formatted")
    end)
end

---@param global boolean
---@param value boolean
local function format_enable(global, value)
    if global then
        require("options").set_autoformat_enabled(nil, value)
    else
        require("options").set_autoformat_enabled(0, value)
    end
end

local format_cmds = {
    enable = function(ev)
        format_enable(ev.bang, true)
    end,
    disable = function(ev)
        format_enable(ev.bang, false)
    end,
    reset = function(ev)
        if ev.bang then
            require("options").reset_autoformat_enabled(nil)
        else
            require("options").reset_autoformat_enabled(0)
        end
    end,
}

vim.api.nvim_create_user_command("Format", function(ev)
    if ev.fargs[1] then
        format_cmds[ev.fargs[1]](ev)
        return
    end

    format_async(ev)
end, {
    bang = true,
    range = true,
    nargs = "?",
    complete = function(query)
        return require("utils").prefix_filter(query, vim.tbl_keys(format_cmds))
    end,
})

require("conform").setup({
    formatters_by_ft = {
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
    format_on_save = function(buf)
        if not require("options").is_autoformat_enabled(buf) then
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
        vim.b[buf].undo_ftplugin = (vim.b[buf].undo_ftplugin or "") .. "\n setl formatexpr<"
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
