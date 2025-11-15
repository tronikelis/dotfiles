local augroup = vim.api.nvim_create_augroup("plugin/_pack_fzf.lua", {})

local function current_wd()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir()
    end
    return vim.fn.expand("%:p:h")
end

local function action_motion_edit(_, opts)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, { opts.query or "" })

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
        opts.query = vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
        close()
        require("fzf-lua").resume()
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
        rg_opts = "--trim " .. require("fzf-lua.defaults").defaults.grep.rg_opts,
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

vim.keymap.set("n", "<c-p>", function()
    require("fzf-lua").files()
end)

vim.keymap.set("n", "<leader>=", function()
    require("fzf-lua").resume()
end)

vim.keymap.set("n", "<leader>fr", function()
    require("fzf-lua").files({
        cwd = current_wd(),
    })
end)

vim.keymap.set("n", "<leader>fR", function()
    require("fzf-lua").live_grep({
        cwd = current_wd(),
    })
end)

local function get_visual_selection()
    local mode = vim.api.nvim_get_mode().mode
    assert(vim.list_contains({ "v", "V", "\22" }, mode))
    return vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
end

vim.keymap.set({ "n", "v" }, "<leader>fg", function()
    if vim.list_contains({ "v", "V", "\22" }, vim.api.nvim_get_mode().mode) then
        require("fzf-lua").grep({
            search = vim.trim(get_visual_selection()[1]),
        })
    else
        require("fzf-lua").live_grep()
    end
end)

vim.keymap.set("n", "<leader>fp", function()
    require("fzf-lua").grep_project()
end)

vim.keymap.set("n", "<leader>fG", function()
    require("fzf-lua").grep_cword()
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

vim.keymap.set({ "n", "v" }, "<leader>gc", function()
    require("fzf-lua").git_bcommits()
end)

vim.keymap.set("n", "<leader>dc", function()
    require("fzf-lua").diagnostics_document()
end)

vim.keymap.set("n", "<leader>dC", function()
    require("fzf-lua").diagnostics_workspace()
end)

vim.keymap.set("n", "<leader>ch", function()
    require("fzf-lua").command_history()
end)

vim.keymap.set("n", "<leader>ct", function()
    require("fzf-lua").tags()
end)

vim.keymap.set("n", "<leader>cT", function()
    local cword = vim.fn.expand("<cword>")
    if cword == "" then
        print("Empty cword")
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
        fzf_opts = {
            ["--preview"] = "ls -LCp --color=always {}",
        },
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

vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(ev)
        vim.keymap.set("n", "<leader>ds", function()
            require("fzf-lua").lsp_document_symbols()
        end, { buffer = ev.buf })

        vim.keymap.set("n", "<leader>dS", function()
            require("fzf-lua").lsp_workspace_symbols()
        end, { buffer = ev.buf })

        vim.keymap.set("n", "gI", function()
            require("fzf-lua").lsp_implementations()
        end, { buffer = ev.buf })

        vim.keymap.set("n", "gt", function()
            require("fzf-lua").lsp_typedefs()
        end, { buffer = ev.buf })

        vim.keymap.set("n", "gd", function()
            require("fzf-lua").lsp_definitions()
        end, { buffer = ev.buf })

        vim.keymap.set("n", "gr", function()
            require("fzf-lua").lsp_references()
        end, { buffer = ev.buf })
    end,
})

vim.api.nvim_create_user_command("GitDiff", function(ev)
    ---@type string?
    local ref

    if #ev.fargs == 1 then
        ref = ev.fargs[1]
    elseif #ev.fargs > 1 then
        local out = vim.system(require("utils").flatten({ "git", ev.fargs }), { text = true }):wait()
        if out.code ~= 0 then
            vim.notify(tostring(out.stderr), vim.log.levels.ERROR)
            return
        end

        ref = vim.trim(out.stdout)
    end

    require("fzf-lua").git_diff({ ref = ref })
end, { nargs = "*" })
