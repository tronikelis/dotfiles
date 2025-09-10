local function current_wd()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir()
    end
    return vim.fn.expand("%:p:h")
end

local function action_motion_edit(_, opts)
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, { opts.query or "" })
    local winid = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = 100,
        height = 1,
        row = 4,
        col = vim.o.columns / 4,
        border = "rounded",
        title = "Fzf query:",
        style = "minimal",
    })

    local function close()
        vim.api.nvim_buf_delete(buf, { force = true })
        require("fzf-lua").resume()
    end

    local function accept()
        opts.query = vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
        close()
    end

    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(winid),
        once = true,
        callback = close,
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
            ["ctrl-x"] = action_motion_edit,
        },
    },
})

require("fzf-lua").register_ui_select()

vim.keymap.set("n", "<c-p>", function()
    require("fzf-lua").files()
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

vim.keymap.set("n", "<leader>fg", function()
    require("fzf-lua").live_grep()
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

vim.keymap.set("n", "<leader>gc", function()
    require("fzf-lua").git_bcommits()
end)

vim.keymap.set("n", "<leader>dc", function()
    require("fzf-lua").diagnostics_document()
end)

vim.keymap.set("n", "<leader>dC", function()
    require("fzf-lua").diagnostics_workspace()
end)

vim.keymap.set("n", "<leader>ds", function()
    require("fzf-lua").lsp_document_symbols()
end)

vim.keymap.set("n", "<leader>dS", function()
    require("fzf-lua").lsp_workspace_symbols()
end)

vim.keymap.set("n", "gI", function()
    require("fzf-lua").lsp_implementations()
end)

vim.keymap.set("n", "gt", function()
    require("fzf-lua").lsp_typedefs()
end)

vim.keymap.set("n", "gd", function()
    require("fzf-lua").lsp_definitions()
end)

vim.keymap.set("n", "gr", function()
    require("fzf-lua").lsp_references()
end)
