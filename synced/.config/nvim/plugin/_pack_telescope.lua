local function current_wd()
    if vim.bo.filetype == "oil" then
        return require("oil").get_current_dir()
    end
    return vim.fn.expand("%:p:h")
end

local function setup()
    if vim.g.did_telescope then
        return
    end
    vim.g.did_telescope = true

    local utils = require("utils")
    local actions = require("telescope.actions")
    local actions_state = require("telescope.actions.state")
    local lga_actions = require("telescope-live-grep-args.actions")

    local vimgrep_arguments = utils.flatten({ -- poor mans table copy, lmao
        require("telescope.config").values.vimgrep_arguments,
    })

    table.insert(vimgrep_arguments, "--hidden")
    table.insert(vimgrep_arguments, "--trim")

    local picker_defaults = {
        debounce = 200,
    }

    local with_picker_defaults = function(pickers)
        for k, v in pairs(pickers) do
            pickers[k] = vim.tbl_extend("force", picker_defaults, v)
        end

        return pickers
    end

    local copy_current_entry = function(prompt_bufnr)
        local selected_entry = actions_state.get_selected_entry()
        vim.fn.setreg("+", selected_entry.value)
        actions.close(prompt_bufnr)
    end

    local function pass_mappings(mappings)
        return {
            n = mappings,
            i = mappings,
        }
    end

    require("telescope").setup({
        defaults = {
            sorting_strategy = "ascending",
            layout_strategy = "flex",
            layout_config = {
                height = 0.85,
                width = 0.9,
                horizontal = {
                    prompt_position = "top",
                },
                vertical = {
                    prompt_position = "top",
                    mirror = true,
                },
            },
            vimgrep_arguments = vimgrep_arguments,
            mappings = pass_mappings({
                ["<c-h>"] = actions.preview_scrolling_left,
                ["<c-l>"] = actions.preview_scrolling_right,

                ["<c-d>"] = actions.preview_scrolling_down,
                ["<c-u>"] = actions.preview_scrolling_up,

                ["<c-y>"] = copy_current_entry,

                ["<c-f>"] = actions.cycle_previewers_next,
                ["<c-b>"] = actions.cycle_previewers_prev,

                ["<c-n>"] = actions.move_selection_next,
                ["<c-p>"] = actions.move_selection_previous,

                ["<c-c>"] = actions.close,

                ["<c-s>"] = actions.file_split,
                ["<c-v>"] = actions.file_vsplit,
            }),
            path_display = { "truncate" },
            cache_picker = {
                num_pickers = 50,
                limit_entries = 500,
            },
            file_ignore_patterns = {
                "^%.git/",
            },
        },
        pickers = with_picker_defaults({
            lsp_references = {
                show_line = false,
            },
            lsp_definitions = {
                show_line = false,
            },
            find_files = {
                hidden = true,
            },
            buffers = {
                sort_mru = true,
                mappings = pass_mappings({
                    ["<c-x>"] = actions.delete_buffer,
                }),
            },
            oldfiles = {
                only_cwd = true,
            },
            git_status = {},
            quickfix = {
                trim_text = true,
            },
            help_tags = {},
            current_buffer_fuzzy_find = {},
            pickers = {},
            git_bcommits = {},
            git_bcommits_range = {},
        }),
        extensions = with_picker_defaults({
            live_grep_args = {
                mappings = pass_mappings({
                    ["<c-space>"] = actions.to_fuzzy_refine,
                    ["<c-f>"] = lga_actions.quote_prompt({ postfix = " -F" }),
                }),
            },
            git_diff_stat = {
                preview_get_command = function(opts, entry)
                    return {
                        "git",
                        "-c",
                        "delta.line-numbers=false",
                        "diff",
                        "-p",
                        opts.git_args,
                        "--",
                        entry.absolute,
                    }
                end,
            },
            ["ui-select"] = {
                require("telescope.themes").get_cursor(),
            },
        }),
    })

    require("telescope").load_extension("fzf")
    require("telescope").load_extension("ui-select")
    require("telescope").load_extension("live_grep_args")
    require("telescope").load_extension("git_diff_stat")
end

local function keymap(mode, lhs, fn)
    vim.keymap.set(mode, lhs, function()
        setup()
        fn()
    end)
end

keymap("n", "<leader>fg", function()
    require("telescope").extensions.live_grep_args.live_grep_args()
end)
keymap("n", "<leader>fG", function()
    require("telescope-live-grep-args.shortcuts").grep_word_under_cursor()
end)

keymap("n", "<leader>gd", function()
    require("telescope").extensions.git_diff_stat.git_diff_stat()
end)
keymap("n", "<leader>gs", function()
    require("telescope.builtin").git_status()
end)

keymap("n", "<leader>of", function()
    require("telescope.builtin").oldfiles()
end)
keymap("n", "<C-p>", function()
    require("telescope.builtin").find_files()
end)

keymap("n", "<leader>/", function()
    require("telescope.builtin").current_buffer_fuzzy_find()
end)
keymap("n", "<leader>b", function()
    require("telescope.builtin").buffers()
end)
keymap("n", "<leader>qf", function()
    require("telescope.builtin").quickfix()
end)

keymap("n", "<leader>ht", function()
    require("telescope.builtin").help_tags()
end)
keymap("n", "<leader>op", function()
    require("telescope.builtin").pickers()
end)

keymap("n", "<leader>fr", function()
    require("telescope.builtin").find_files({ cwd = current_wd() })
end)
keymap("n", "<leader>fR", function()
    require("telescope").extensions.live_grep_args.live_grep_args({ search_dirs = { current_wd() } })
end)

keymap({ "n", "v" }, "<leader>gc", function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" then
        require("telescope.builtin").git_bcommits()
    else
        require("telescope.builtin").git_bcommits_range()
    end
end)

keymap("n", "gd", function()
    require("telescope.builtin").lsp_definitions()
end)
keymap("n", "gr", function()
    require("telescope.builtin").lsp_references()
end)
keymap("n", "gt", function()
    require("telescope.builtin").lsp_type_definitions()
end)
keymap("n", "gI", function()
    require("telescope.builtin").lsp_implementations()
end)
keymap("n", "<leader>dc", function()
    local severity = (vim.v.count == 0 and { nil } or { vim.v.count })[1]
    require("telescope.builtin").diagnostics({ bufnr = 0, severity = severity })
end)
keymap("n", "<leader>dC", function()
    local severity = (vim.v.count == 0 and { nil } or { vim.v.count })[1]
    require("telescope.builtin").diagnostics({ severity = severity })
end)
keymap("n", "<leader>ds", function()
    require("telescope.builtin").lsp_document_symbols()
end)
keymap("n", "<leader>dS", function()
    require("telescope.builtin").lsp_workspace_symbols()
end)
