local cmp = {}

--- highlight pattern
-- This has three parts:
-- 1. the highlight group
-- 2. text content
-- 3. special sequence to restore highlight: %*
-- Example pattern: %#SomeHighlight#some-text%*
local hi_pattern = "%%#%s#%s%%*"

function _G._statusline_component(name)
    return cmp[name]()
end

if not vim.g.did_statusline then
    local timer = assert(vim.uv.new_timer())
    local function callback()
        timer:start(
            2000,
            0,
            vim.schedule_wrap(function()
                vim.cmd("redrawstatus")
                callback()
            end)
        )
    end
    callback()
end
vim.g.did_statusline = true

local git_status = ""
local git_status_running = false
local function run_git_status()
    if git_status_running then
        return git_status
    end
    git_status_running = true

    local cwd = vim.fn.expand("%:p:h")
    if cwd:sub(1, 1) ~= "/" then
        cwd = nil
    end

    vim.system(
        { "bash", "-c", [[starship module git_status | perl -pe 's/\e\[[0-9;]*m//g'; sleep 1]] }, -- sleep here to not spam
        { cwd = cwd },
        function(out)
            git_status_running = false
            local stdout = vim.trim(out.stdout or "")
            git_status = stdout
        end
    )

    return git_status
end

function cmp.git()
    run_git_status()

    local symbol = "  "

    if not vim.b.gitsigns_status_dict then
        return " "
    end

    local raw = symbol .. vim.b.gitsigns_status_dict.head .. " " .. git_status

    return hi_pattern:format("Conditional", raw) .. " "
end

function cmp.lines()
    local ln = vim.api.nvim_buf_line_count(0)
    local suffix = ""

    if ln >= 1000 then
        suffix = "K"
        ln = ln / 1000

        local dotIndex = string.find(ln, ".", 1, true)

        if dotIndex ~= nil then
            ln = string.sub(ln, 1, dotIndex + 1)
        else
            ln = ln .. ".0"
        end
    end

    return tostring(ln) .. suffix .. ":" .. "%-3c"
end

function cmp.full_file()
    local file = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.")

    if vim.bo.filetype == "oil" then
        local dir = require("oil").get_current_dir()
        if dir then
            dir = vim.fn.fnamemodify(dir, ":~:.")
            return hi_pattern:format("Directory", " ") .. dir
        end
    end

    local icon, hl = require("nvim-web-devicons").get_icon(file)
    if icon and hl then
        file = hi_pattern:format(hl, icon .. " ") .. file
    end
    return file
end

function cmp.filetype()
    local filetype = vim.bo.filetype
    local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(filetype)

    if icon and hl then
        filetype = hi_pattern:format(hl, icon .. " ") .. filetype
    end

    return filetype
end

function cmp.formatters()
    local conform = require("conform")

    local ok = "󰏫"
    local not_ok = "󰏯"

    local formatters, lsp = conform.list_formatters_to_run()

    if not lsp and #formatters == 0 then
        return ""
    end

    if vim.g.disable_autoformat or vim.b.disable_autoformat then
        ok = not_ok
    end

    local fmts = vim.iter(formatters)
        :map(function(x)
            return x.name
        end)
        :totable()

    ---@type string[]
    local str = require("utils").flatten({ ok, fmts })

    if lsp then
        table.insert(str, "[LSP]")
    end

    return table.concat(str, " ")
end

function cmp.diagnostics()
    local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.E })
    local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.W })
    local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.I })
    local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })

    local diagnostics = {}
    if errors ~= 0 then
        table.insert(diagnostics, hi_pattern:format("DiagnosticError", "E" .. errors))
    end
    if warnings ~= 0 then
        table.insert(diagnostics, hi_pattern:format("DiagnosticWarn", "W" .. warnings))
    end
    if infos ~= 0 then
        table.insert(diagnostics, hi_pattern:format("DiagnosticInfo", "I" .. infos))
    end
    if hints ~= 0 then
        table.insert(diagnostics, hi_pattern:format("DiagnosticHint", "H" .. hints))
    end

    return table.concat(diagnostics, " ")
end

function cmp.attached_lsp()
    local clients = #vim.lsp.get_clients({ bufnr = 0 })
    if clients == 0 then
        return ""
    end

    return "󰒓 " .. clients
end

vim.opt.statusline = table.concat({
    '%{%v:lua._statusline_component("git")%}',
    "%t ",
    "%r",
    "%m",
    ' %{%v:lua._statusline_component("diagnostics")%}',
    "%=",
    '%{%v:lua._statusline_component("formatters")%} ',
    '%{%v:lua._statusline_component("attached_lsp")%} ',
    '%{%v:lua._statusline_component("filetype")%} ',
    ' %{%v:lua._statusline_component("lines")%}',
})

vim.opt.tabline = table.concat({
    ' %{%v:lua._statusline_component("full_file")%} ',
    "%r",
    "%m",
})
vim.opt.showtabline = 2
