local augroup = vim.api.nvim_create_augroup("plugin/statusline.lua", {})

local cmp = {}

--- highlight pattern
-- This has three parts:
-- 1. the highlight group
-- 2. text content
-- 3. special sequence to restore highlight: %*
-- Example pattern: %#SomeHighlight#some-text%*
local hi_pattern = "%%#%s#%s%%*"

function _G._statusline_component(name)
    local prompt = cmp[name]()
    if prompt ~= "" then
        prompt = " " .. prompt
    end
    return prompt
end

---@param v string
local function escape(v)
    local res = v:gsub("%%", "%%%%")
    return res
end

local function refresh_timer()
    local timer = _G.__statusline_timer or assert(vim.uv.new_timer())
    _G.__statusline_timer = timer
    return timer
end
local function start_refresh_timer()
    refresh_timer():start(
        0,
        3000,
        vim.schedule_wrap(function()
            vim.cmd("redrawstatus!")
        end)
    )
end
local function stop_refresh_timer()
    refresh_timer():stop()
end
start_refresh_timer()
vim.api.nvim_create_autocmd("FocusGained", {
    group = augroup,
    callback = start_refresh_timer,
})
vim.api.nvim_create_autocmd("FocusLost", {
    group = augroup,
    callback = stop_refresh_timer,
})

_G.__statusline_root_to_git_status = _G.__statusline_root_to_git_status or {}
---@type table<string, string?>
local root_to_git_status = _G.__statusline_root_to_git_status

_G.__statusline_root_to_git_status_system = _G.__statusline_root_to_git_status_system or {}
---@type table<string, vim.SystemObj?>
local root_to_git_status_system = _G.__statusline_root_to_git_status_system

local function get_buffer_git_root()
    local cached_root = vim.b.git_root
    if cached_root == "" then
        return
    end

    local root = cached_root or vim.fs.root(0, ".git")
    if not root then
        vim.b.git_root = ""
        return
    end
    vim.b.git_root = root

    return root
end

local function run_git_status()
    if vim.bo.buftype ~= "" or vim.fn.expand("%:p"):sub(1, 1) ~= "/" then
        return
    end

    local root = get_buffer_git_root()
    if not root then
        return
    end

    local obj = root_to_git_status_system[root]
    if obj then
        return
    end

    root_to_git_status_system[root] = vim.system(
        -- sleep here to not spam
        { "bash", "-c", [[sleep 3; starship module git_status | perl -pe 's/\e\[[0-9;]*m//g']] },
        { cwd = root, text = true },
        function(out)
            local stdout = vim.trim(out.stdout or "")
            root_to_git_status_system[root] = nil
            root_to_git_status[root] = stdout
        end
    )
end

local function get_git_status()
    if vim.bo.buftype ~= "" or vim.fn.expand("%:p"):sub(1, 1) ~= "/" then
        return
    end

    local root = get_buffer_git_root()
    if not root then
        return
    end
    return root_to_git_status[root]
end

function cmp.git()
    run_git_status()

    local symbol = " "

    if not vim.b.gitsigns_status_dict then
        return ""
    end

    local prompt = hi_pattern:format(
        "Conditional",
        symbol .. escape(vim.b.gitsigns_status_dict.head) .. escape(get_git_status() or "")
    )
    return prompt .. " "
end

function cmp.git_lines()
    if not vim.b.gitsigns_status_dict then
        return ""
    end

    local lines = {}
    if vim.b.gitsigns_status_dict.added and vim.b.gitsigns_status_dict.added ~= 0 then
        table.insert(lines, hi_pattern:format("GitsignsAdd", "+" .. vim.b.gitsigns_status_dict.added))
    end
    if vim.b.gitsigns_status_dict.changed and vim.b.gitsigns_status_dict.changed ~= 0 then
        table.insert(lines, hi_pattern:format("GitsignsChange", "~" .. vim.b.gitsigns_status_dict.changed))
    end
    if vim.b.gitsigns_status_dict.removed and vim.b.gitsigns_status_dict.removed ~= 0 then
        table.insert(lines, hi_pattern:format("GitsignsDelete", "-" .. vim.b.gitsigns_status_dict.removed))
    end

    local prompt = table.concat(lines, " ")
    if prompt ~= "" then
        prompt = string.format("(%s)", prompt)
    end

    return prompt
end

function cmp.lines()
    local winnr_expr = "%{winnr()}"
    if vim.api.nvim_buf_line_count(0) < 1000 then
        return string.format("%s:%d:%%-3c", winnr_expr, vim.api.nvim_buf_line_count(0))
    end
    return string.format("%s:%.1fK:%%-3c", winnr_expr, vim.api.nvim_buf_line_count(0) / 1000)
end

function cmp.full_file()
    local file = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.")

    if vim.bo.filetype == "oil" then
        local dir = require("oil").get_current_dir()
        if dir then
            dir = escape(vim.fn.fnamemodify(dir, ":~:."))
            return hi_pattern:format("Directory", " ") .. dir
        end
    end

    local icon, hl = require("nvim-web-devicons").get_icon(vim.fs.basename(file))
    if icon and hl then
        file = hi_pattern:format(hl, icon .. " ") .. escape(file)
    else
        file = " " .. escape(file)
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
            return escape(x.name)
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
    local count = vim.diagnostic.count(0)

    local errors = count[vim.diagnostic.severity.E] or 0
    local warnings = count[vim.diagnostic.severity.W] or 0
    local infos = count[vim.diagnostic.severity.I] or 0
    local hints = count[vim.diagnostic.severity.HINT] or 0

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

    local prompt = table.concat(diagnostics, " ")
    return prompt
end

function cmp.attached_lsp()
    local clients = #vim.lsp.get_clients({ bufnr = 0 })
    if clients == 0 then
        return ""
    end

    return " 󰒓 " .. clients
end

vim.api.nvim_create_autocmd("LspProgress", {
    group = augroup,
    callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

        local function set(msg)
            for k in pairs(client.attached_buffers) do
                vim.b[k].statusline_progress_msg = msg
            end
        end
        set()

        local value = ev.data.params.value

        if vim.tbl_contains({ "end" }, value.kind) then
            vim.cmd("redrawstatus!")
            return
        end

        local messages = {}
        if value.percentage then
            table.insert(messages, string.format("[%s%%%%]", value.percentage))
        end
        if value.message then
            table.insert(messages, escape(value.message))
        end
        if value.title then
            table.insert(messages, escape(value.title))
        end

        set(string.format(hi_pattern, "Comment", table.concat(messages, " ")))
        vim.cmd("redrawstatus!")
    end,
})

function cmp.progress()
    return vim.b.statusline_progress_msg or ""
end

vim.opt.statusline = table.concat({
    '%{%v:lua._statusline_component("git")%}',
    " %t",
    "%r",
    "%m ",
    '%{%v:lua._statusline_component("diagnostics")%}',
    '%{%v:lua._statusline_component("git_lines")%}',
    "%<",
    "%=",
    '%{%v:lua._statusline_component("progress")%}',
    "%=",
    '%{%v:lua._statusline_component("formatters")%}',
    '%{%v:lua._statusline_component("attached_lsp")%}',
    ' %{%v:lua._statusline_component("filetype")%}',
    ' %{%v:lua._statusline_component("lines")%}',
})

vim.opt.tabline = table.concat({
    '%{%v:lua._statusline_component("full_file")%}',
    "%r",
    "%m",
})
vim.opt.showtabline = 2
