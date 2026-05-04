local function current_wd()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir()
    end
    return vim.fn.expand("%:p:h")
end

local function action_motion_edit(_, opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, { opts.query or "" })
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].undofile = false

    local width = math.min(50, vim.o.columns - 10)
    local height = 1
    local winid = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.min(10, vim.o.lines),
        col = math.floor((vim.o.columns - width) / 2),
        border = "rounded",
        title = "Fzf query:",
        style = "minimal",
    })

    local group = vim.api.nvim_create_augroup("fzflua/action_motion_edit", {})

    local function close()
        vim.api.nvim_del_augroup_by_id(group)
        if vim.api.nvim_win_is_valid(winid) then
            vim.api.nvim_win_close(winid, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end

    local function accept()
        local query = vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
        -- otherwise this just opens same window again
        require("fzf-lua.win").close()
        close()
        require("fzf-lua").resume({ query = query, __call_opts = { query = nil, search = nil } })
    end

    vim.api.nvim_create_autocmd("WinLeave", {
        group = group,
        callback = function()
            if vim.api.nvim_get_current_win() == winid then
                close()
            end
        end,
    })

    vim.keymap.set("n", "<esc>", close, { buffer = buf })
    vim.keymap.set("n", "q", close, { buffer = buf })

    vim.keymap.set({ "n", "i" }, "<c-c>", accept, { buffer = buf })
    vim.keymap.set({ "n", "i" }, "<enter>", accept, { buffer = buf })
end

local function cwd_child()
    local cwd = vim.fn.getcwd()
    local wd = current_wd()

    while wd ~= cwd and vim.fs.dirname(wd) ~= cwd do
        if wd == "/" then
            break
        end
        wd = vim.fs.dirname(wd)
    end

    return wd
end

local actions = require("fzf-lua").actions

require("fzf-lua").setup({
    "telescope",
    fzf_opts = { ["--layout"] = "reverse" },
    actions = {
        files = {
            ["ctrl-s"] = actions.file_split,
            ["ctrl-v"] = actions.file_vsplit,
            ["ctrl-i"] = action_motion_edit,
        },
    },

    grep = {
        rg_opts = "--trim --hidden " .. require("fzf-lua.defaults").defaults.grep.rg_opts,
    },

    defaults = {
        trim_entry = true,
    },

    oldfiles = {
        include_current_session = true,
        cwd_only = true,
    },
})

require("fzf-lua").register_ui_select()

---@param mappings [string?, string?]
---@param get_opts fun(): table
local function map_files_grep_picker(mappings, get_opts)
    local function get_visual_selection()
        local mode = vim.api.nvim_get_mode().mode
        assert(vim.list_contains({ "v", "V", "\22" }, mode))
        return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    end

    if mappings[1] then
        vim.keymap.set("n", mappings[1], function()
            local opts = get_opts()
            require("fzf-lua").files(opts)
        end)
    end
    if mappings[2] then
        vim.keymap.set({ "n", "x" }, mappings[2], function()
            local opts = get_opts()
            if vim.list_contains({ "v", "V", "\22" }, vim.api.nvim_get_mode().mode) then
                require("fzf-lua").grep(vim.tbl_extend("force", opts, {
                    search = vim.trim(get_visual_selection()[1]),
                }))
            else
                require("fzf-lua").live_grep(opts)
            end
        end)
    end
end

vim.keymap.set("n", "<c-p>", function()
    require("fzf-lua").files()
end)

vim.keymap.set("n", "<leader>=", function()
    require("fzf-lua").resume()
end)

map_files_grep_picker({ "<leader>fr", "<leader>fR" }, function()
    return { cwd = current_wd() }
end)

map_files_grep_picker({ "<leader>fh", "<leader>fH" }, function()
    return { cwd = cwd_child() }
end)

map_files_grep_picker({ nil, "<leader>fg" }, function()
    return {}
end)

vim.keymap.set("n", "<leader>fG", function()
    require("fzf-lua").grep_cword()
end)

vim.keymap.set("n", "<leader>fp", function()
    require("fzf-lua").grep_project()
end)

vim.keymap.set("n", "<leader>of", function()
    require("fzf-lua").oldfiles()
end)

vim.keymap.set("n", "<leader>/", function()
    require("fzf-lua").blines()
end)

vim.keymap.set("n", "<leader>ht", function()
    require("fzf-lua").helptags()
end)

vim.keymap.set("n", "<leader>qf", function()
    require("fzf-lua").quickfix()
end)

vim.keymap.set("n", "<leader>b", function()
    require("fzf-lua").buffers()
end)

vim.keymap.set("n", "<leader>gs", function()
    require("fzf-lua").git_status()
end)

vim.keymap.set({ "n", "x" }, "<leader>gc", function()
    require("fzf-lua").git_bcommits()
end)

vim.keymap.set("n", "<leader>dc", function()
    require("fzf-lua").diagnostics_document()
end)

vim.keymap.set("n", "<leader>dC", function()
    require("fzf-lua").diagnostics_workspace()
end)

vim.keymap.set("n", "<leader>dt", function()
    require("fzf-lua").treesitter()
end)

vim.keymap.set("n", "<leader>ch", function()
    require("fzf-lua").command_history()
end)

vim.keymap.set("n", "<leader>cm", function()
    require("fzf-lua").commands()
end)

vim.keymap.set("n", "<leader>ct", function()
    vim.cmd.Taglist()
end)

vim.keymap.set("n", "<leader>cT", function()
    local cword = vim.fn.expand("<cword>")
    if not require("utils").assert_notify(cword ~= "", "Empty cword") then
        return
    end
    vim.cmd.Taglist(cword)
end)

vim.keymap.set("n", "<leader>oo", function()
    require("fzf-lua").fzf_exec("fd -t d --color=never --hidden --exclude .git", {
        winopts = {
            title = "Oil",
        },
        fn_transform = function(x)
            return require("fzf-lua").utils.ansi_codes.magenta(x)
        end,
        preview = "ls -LCp --color=always {}",
        actions = {
            default = function(item)
                require("oil").open(item[1])
            end,
            ["ctrl-s"] = function(item)
                vim.cmd("new")
                require("oil").open(item[1])
            end,
            ["ctrl-v"] = function(item)
                vim.cmd("vertical new")
                require("oil").open(item[1])
            end,
        },
    })
end)

---@param file string
---@param fargs_joined string
---@param cwd string?
local function navigate_to_first_git_hunk(file, fargs_joined, cwd)
    local out = vim.system({
        "bash",
        "-c",
        string.format("git diff %s -- %s | grep ^@@ | head -n 1", fargs_joined, vim.fn.shellescape(file)),
    }, { text = true, cwd = cwd }):wait()
    if not require("utils").assert_notify(out.code == 0, out.stderr) then
        return
    end

    local stdout = vim.trim(out.stdout)
    local line = stdout:match("%+(%d+)")
    if line then
        vim.cmd(line)
    end
end

vim.api.nvim_create_user_command("GitDiff", function(ev)
    local fargs_joined = table.concat(
        vim.iter(ev.fargs)
            :map(function(v)
                return vim.fn.shellescape(v)
            end)
            :totable(),
        " "
    )

    local cmd = string.format("git diff --name-only %s", fargs_joined)
    local preview = string.format("git diff %s -- {} | delta", fargs_joined)

    local cwd = vim.fs.root(0, ".git")
    if not require("utils").assert_notify(cwd, "Not in git directory") then
        return
    end

    if vim.system({ "bash", "-c", string.format("git diff %s --quiet", fargs_joined) }):wait().code == 0 then
        vim.notify("No differences")
        return
    end

    require("fzf-lua").fzf_exec(cmd, {
        preview = preview,
        cwd = cwd,
        winopts = {
            fullscreen = true,
            preview = {
                layout = "vertical",
                vertical = "up:80%",
            },
            title = "Git Diff",
        },
        actions = {
            ["enter"] = function(...)
                require("fzf-lua").actions.file_edit(...)
                local file = { ... }
                file = file[1][1]
                navigate_to_first_git_hunk(file, fargs_joined, cwd)
            end,
        },
    })
end, { nargs = "*" })
