---@param buf integer
---@return boolean
local function is_buf_valid_for_statusline(buf)
    return vim.bo[buf].buftype == ""
end

---@param events string[]|string
---@param augroup integer
---@param callback fun(ev: vim.api.keyset.create_autocmd.callback_args)
local function cmp_autocmd(events, augroup, callback)
    vim.api.nvim_create_autocmd(events, {
        group = augroup,
        callback = function(ev)
            if not is_buf_valid_for_statusline(ev.buf) then
                return
            end
            callback(ev)
        end,
    })
end

---@param instance table
local function cmp_redraw_all(instance)
    for _, v in ipairs(vim.api.nvim_list_wins()) do
        instance:compute(v, vim.api.nvim_win_get_buf(v))
    end
end

---@param events string[]
---@param augroup integer
---@param instance table
local function cmp_autocmd_redraw_all(events, augroup, instance)
    cmp_autocmd(events, augroup, function()
        cmp_redraw_all(instance)
    end)
end

vim.api.nvim_create_user_command("StatuslineRefresh", function()
    vim.api.nvim_exec_autocmds("User", {
        pattern = "StatuslineRefresh",
    })
end, {})

---@param instance table
local function cmp_autocmd_init(instance)
    assert(instance.compute, "cmp instance compute function exists")
    assert(instance.augroup, "cmp instance augroup exists")
    vim.api.nvim_create_autocmd("User", {
        group = instance.augroup,
        pattern = "StatuslineRefresh",
        callback = function()
            cmp_redraw_all(instance)
            vim.cmd("redrawstatus!")
        end,
    })
end

---@class Statusline.LspStatusCmp
---@field augroup integer
---@field output string
---@field throttle_timer uv.uv_timer_t
---@field reset_timer uv.uv_timer_t
local LspStatusCmp = {}

function LspStatusCmp:new()
    ---@type Statusline.LspStatusCmp
    local instance = setmetatable({
        augroup = vim.api.nvim_create_augroup("lsp/statusline.lua/LspStatusCmp", {}),
        output = "",
        throttle_timer = assert(vim.uv.new_timer()),
        reset_timer = assert(vim.uv.new_timer()),
    }, { __index = self })

    cmp_autocmd_init(instance)

    cmp_autocmd("LspProgress", instance.augroup, function(ev)
        if vim.tbl_contains({ "end" }, ev.data.params.value.kind) then
            instance:set("")
            return
        end
        instance:set(vim.lsp.status())
    end)

    local reset_ms = 1000 * 60 * 5
    instance.reset_timer:start(reset_ms, reset_ms, function()
        instance:set("")
    end)

    return instance
end

---@param value string
function LspStatusCmp:set(value)
    self.output = value
    if not self.throttle_timer:is_active() then
        self.throttle_timer:start(100, 0, function()
            vim.schedule(function()
                vim.cmd("redrawstatus")
            end)
        end)
    end
end

function LspStatusCmp:compute() end

function LspStatusCmp:get()
    return self.output or ""
end

---@class Statusline.FormattersCmp
---@field augroup integer
---@field outputs table<integer, string?>
local FormattersCmp = {}

function FormattersCmp:new()
    ---@type Statusline.FormattersCmp
    local instance = setmetatable({
        outputs = {},
        augroup = vim.api.nvim_create_augroup("plugin/statusline.lua/FormattersCmp", {}),
    }, { __index = self })

    cmp_autocmd_init(instance)

    cmp_autocmd({ "BufEnter", "WinEnter" }, instance.augroup, function(ev)
        instance:compute(vim.api.nvim_get_current_win(), ev.buf)
    end)

    cmp_autocmd({ "WinClosed" }, instance.augroup, function(ev)
        instance:set(assert(tonumber(ev.match), "winid number expected"), nil)
    end)

    cmp_autocmd_redraw_all({ "FocusGained", "LspAttach", "LspDetach" }, instance.augroup, instance)

    return instance
end

---@param win integer
---@param buf integer
function FormattersCmp:compute(win, buf)
    vim.b[buf].__FormattersCmp_last_is_autoformat_enabled = require("options").is_autoformat_enabled(buf)
    self:set(win, "")

    local conform = require("conform")

    local ok = "󰏫"
    local not_ok = "󰏯"

    local formatters, lsp = conform.list_formatters_to_run(buf)

    if not lsp and #formatters == 0 then
        return
    end

    if not require("options").is_autoformat_enabled(buf) then
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

    self:set(win, table.concat(str, " "))
end

---@param win integer
---@param value? string
function FormattersCmp:set(win, value)
    self.outputs[win] = value
    vim.schedule(function()
        vim.cmd("redrawstatus")
    end)
end

function FormattersCmp:get()
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    if vim.b[buf].__FormattersCmp_last_is_autoformat_enabled ~= require("options").is_autoformat_enabled(buf) then
        self:compute(win, buf)
    end
    return self.outputs[win] or ""
end

---@class Statusline.GitStatusCmp
---@field root_handles table<string, vim.SystemObj?>
---@field augroup integer
---@field root_outputs table<string, string?>
---@field timer uv.uv_timer_t
local GitStatusCmp = {}

function GitStatusCmp:new()
    ---@type Statusline.GitStatusCmp
    local instance = setmetatable({
        augroup = vim.api.nvim_create_augroup("plugin/statusline.lua/GitStatusCmp", {}),
        root_handles = {},
        root_outputs = {},
        timer = assert(vim.uv.new_timer()),
    }, { __index = self })

    cmp_autocmd_init(instance)

    cmp_autocmd({ "BufEnter", "WinEnter", "BufWritePost" }, instance.augroup, function(ev)
        instance:compute(vim.api.nvim_get_current_win(), ev.buf)
    end)

    cmp_autocmd_redraw_all({ "FocusGained" }, instance.augroup, instance)

    local timer_ms = 1000 * 5
    instance.timer:start(timer_ms, timer_ms, function()
        vim.schedule(function()
            instance:compute(vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf())
        end)
    end)

    return instance
end

---@param buf integer
---@return string?
function GitStatusCmp.git_root(buf)
    local cached_root = vim.b[buf].git_root
    if cached_root == "" then
        return
    end
    if cached_root then
        return cached_root
    end

    if
        not is_buf_valid_for_statusline(buf)
        or vim.api.nvim_buf_call(buf, function()
            return vim.fn.expand("%:p"):sub(1, 1) ~= "/"
        end)
    then
        return
    end

    local root = cached_root or vim.fs.root(buf, ".git")
    if not root then
        vim.b[buf].git_root = ""
        return
    end
    vim.b[buf].git_root = root

    return root
end

---@param win integer
---@param buf integer
---@diagnostic disable-next-line: unused-local
function GitStatusCmp:compute(win, buf)
    local git_root = GitStatusCmp.git_root(buf)
    if not git_root then
        return
    end

    if self.root_handles[git_root] then
        return
    end
    self.root_handles[git_root] = vim.system({
        "bash",
        "-c",
        [[
            if [ -e ~/.config/git/scripts/git-prompt.sh ]; then
                source ~/.config/git/scripts/git-prompt.sh
                GIT_PS1_SHOWDIRTYSTATE=1
                GIT_PS1_SHOWSTASHSTATE=1
                GIT_PS1_SHOWUNTRACKEDFILES=1
                GIT_PS1_SHOWUPSTREAM="auto"
                GIT_PS1_SHOWCONFLICTSTATE=yes
                export GIT_OPTIONAL_LOCKS=0
                echo "[$(__git_ps1 '%s' 2>/dev/null | awk '{print $2}')]"
            else
                echo "n/a"
            fi
        ]],
    }, { cwd = git_root, text = true }, function(out)
        local stdout = vim.trim(out.stdout or "")
        self:set(git_root, stdout)
        self.root_handles[git_root] = nil
    end)
end

---@param git_root string
---@param value string
function GitStatusCmp:set(git_root, value)
    self.root_outputs[git_root] = value
    vim.schedule(function()
        vim.cmd("redrawstatus")
    end)
end

function GitStatusCmp:get()
    local git_root = GitStatusCmp.git_root(vim.api.nvim_get_current_buf())
    if not git_root then
        return ""
    end
    return self.root_outputs[git_root] or ""
end

local git_status_cmp = GitStatusCmp:new()
local formatters_cmp = FormattersCmp:new()
local lsp_status_cmp = LspStatusCmp:new()

local cmp = {}

---@param group string
---@param value string
local function get_hl_pattern(group, value)
    --- highlight pattern
    -- This has three parts:
    -- 1. the highlight group
    -- 2. text content
    -- 3. special sequence to restore highlight: %*
    -- Example pattern: %#SomeHighlight#some-text%*
    local format = "%%#%s#%s%%*"

    if tostring(vim.api.nvim_get_current_win()) ~= vim.g.actual_curwin then
        group = "StatusLineNC"
    end
    return format:format(group, value)
end

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

function cmp.git()
    if not vim.b.gitsigns_status_dict then
        return ""
    end

    local symbol = " "

    local prompt = get_hl_pattern(
        "Conditional",
        symbol .. escape(vim.b.gitsigns_status_dict.head or "") .. escape(git_status_cmp:get())
    )
    return prompt .. " "
end

function cmp.git_lines()
    if not vim.b.gitsigns_status_dict then
        return ""
    end

    local lines = {}
    if vim.b.gitsigns_status_dict.added and vim.b.gitsigns_status_dict.added ~= 0 then
        table.insert(lines, get_hl_pattern("GitsignsAdd", "+" .. vim.b.gitsigns_status_dict.added))
    end
    if vim.b.gitsigns_status_dict.changed and vim.b.gitsigns_status_dict.changed ~= 0 then
        table.insert(lines, get_hl_pattern("GitsignsChange", "~" .. vim.b.gitsigns_status_dict.changed))
    end
    if vim.b.gitsigns_status_dict.removed and vim.b.gitsigns_status_dict.removed ~= 0 then
        table.insert(lines, get_hl_pattern("GitsignsDelete", "-" .. vim.b.gitsigns_status_dict.removed))
    end

    local prompt = table.concat(lines, " ")
    if prompt ~= "" then
        prompt = string.format("(%s)", prompt)
    end

    return prompt
end

function cmp.lines()
    local winnr_expr = "%{winnr()}"
    local line_count = vim.api.nvim_buf_line_count(0)
    if line_count < 1000 then
        return string.format("%s:%d:%%-3c", winnr_expr, line_count)
    end
    return string.format("%s:%.1fK:%%-3c", winnr_expr, line_count / 1000)
end

function cmp.full_file()
    local file = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.")

    if vim.bo.filetype == "oil" then
        local dir = require("oil").get_current_dir()
        if dir then
            dir = escape(vim.fn.fnamemodify(dir, ":~:."))
            return get_hl_pattern("Directory", " ") .. dir
        end
    end

    local icon, hl = require("nvim-web-devicons").get_icon(vim.fs.basename(file))
    if icon and hl then
        file = get_hl_pattern(hl, icon .. " ") .. escape(file)
    else
        file = " " .. escape(file)
    end
    return file
end

function cmp.filetype()
    local filetype = vim.bo.filetype
    local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(filetype)
    filetype = escape(filetype)

    if icon and hl then
        filetype = get_hl_pattern(hl, icon .. " ") .. filetype
    end

    return filetype
end

function cmp.formatters()
    return escape(formatters_cmp:get())
end

function cmp.diagnostics()
    local count = vim.diagnostic.count(0)

    local errors = count[vim.diagnostic.severity.ERROR] or 0
    local warnings = count[vim.diagnostic.severity.WARN] or 0
    local infos = count[vim.diagnostic.severity.INFO] or 0
    local hints = count[vim.diagnostic.severity.HINT] or 0

    local diagnostics = {}
    if errors ~= 0 then
        table.insert(diagnostics, get_hl_pattern("DiagnosticError", "E" .. errors))
    end
    if warnings ~= 0 then
        table.insert(diagnostics, get_hl_pattern("DiagnosticWarn", "W" .. warnings))
    end
    if infos ~= 0 then
        table.insert(diagnostics, get_hl_pattern("DiagnosticInfo", "I" .. infos))
    end
    if hints ~= 0 then
        table.insert(diagnostics, get_hl_pattern("DiagnosticHint", "H" .. hints))
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

function cmp.tabpage_nr_non_empty()
    if vim.fn.tabpagenr("$") == 1 then
        return ""
    end
    return " [%{tabpagenr()}/%{tabpagenr('$')}]"
end

function cmp.progress()
    local status = {}
    local function insert(value)
        if value and value ~= "" then
            table.insert(status, value)
        end
    end
    insert(vim.ui.progress_status())
    insert(escape(lsp_status_cmp:get()))
    return get_hl_pattern("Whitespace", table.concat(status, " / "))
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
    "%=",
    '%{%v:lua._statusline_component("tabpage_nr_non_empty")%}',
})
vim.opt.showtabline = 2
