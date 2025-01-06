local utils = require("utils")

local function jump_to_hunk(buf)
    local JUMPED_TO_HUNK = "_jumped_to_hunk"

    if vim.b[buf][JUMPED_TO_HUNK] then
        return
    end

    local file = vim.fn.expand("%:p")

    vim.system(
        { "bash", "-c", string.format("git diff -U0 HEAD %s | grep ^@@ | head -n 1", vim.fn.shellescape(file)) },
        {},
        vim.schedule_wrap(function(out)
            if out.code ~= 0 or not out.stdout then
                return
            end
            if vim.api.nvim_get_current_buf() ~= buf then
                return
            end

            local line = out.stdout:match("+(%d+)")
            if not line then
                return
            end

            line = tonumber(line)

            vim.cmd([[normal! m']]) -- add current cursor position to the jump list
            vim.api.nvim_win_set_cursor(0, { line, 0 })
            vim.b[buf][JUMPED_TO_HUNK] = true
        end)
    )
end

return {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
        local actions = require("telescope.actions")
        local actions_state = require("telescope.actions.state")
        local lga_actions = require("telescope-live-grep-args.actions")

        local vimgrep_arguments = {
            table.unpack(require("telescope.config").values.vimgrep_arguments),
        }

        table.insert(vimgrep_arguments, "--hidden")
        table.insert(vimgrep_arguments, "--trim")

        local picker_defaults = {
            debounce = 300,
        }

        local with_picker_defaults = function(pickers)
            for k, v in pairs(pickers) do
                pickers[k] = vim.tbl_deep_extend("force", picker_defaults, v)
            end

            return pickers
        end

        local action_or_noop = function(key)
            local success, value = pcall(function()
                return actions[key]
            end)

            return success and value or function() end
        end

        local copy_current_entry = function(prompt_bufnr)
            local selected_entry = actions_state.get_selected_entry()
            vim.fn.setreg("+", selected_entry.value)
            actions.close(prompt_bufnr)
        end

        require("telescope").setup({
            defaults = {
                layout_strategy = "flex",
                vimgrep_arguments = vimgrep_arguments,
                file_ignore_patterns = {
                    ".git/",
                },
                mappings = {
                    i = {
                        -- these will come in a future update
                        ["<c-h>"] = action_or_noop("preview_scrolling_left"),
                        ["<c-l>"] = action_or_noop("preview_scrolling_right"),

                        ["<c-y>"] = copy_current_entry,
                        ["<esc>"] = actions.close,

                        ["<c-f>"] = actions.cycle_previewers_next,
                        ["<c-b>"] = actions.cycle_previewers_prev,

                        ["<c-s>"] = actions.file_split,
                        ["<c-v>"] = actions.file_vsplit,
                    },
                },
                path_display = { "truncate" },
                cache_picker = {
                    num_pickers = 50,
                    limit_entries = 500,
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
                },
                oldfiles = {
                    only_cwd = true,
                },
                git_status = {
                    mappings = {
                        i = {
                            ["<cr>"] = function(...)
                                actions.select_default(...)
                                jump_to_hunk(vim.api.nvim_get_current_buf())
                            end,
                            ["<c-s>"] = function(...)
                                actions.file_split(...)
                                jump_to_hunk(vim.api.nvim_get_current_buf())
                            end,
                            ["<c-v>"] = function(...)
                                actions.file_vsplit(...)
                                jump_to_hunk(vim.api.nvim_get_current_buf())
                            end,
                        },
                    },
                },
                quickfix = {
                    trim_text = true,
                },
            }),
            extensions = with_picker_defaults({
                live_grep_args = {
                    mappings = {
                        i = {
                            ["<c-space>"] = actions.to_fuzzy_refine,
                            ["<c-f>"] = lga_actions.quote_prompt({ postfix = " -F" }),
                        },
                    },
                },
            }),
        })

        local function oldfiles_cwd()
            local cwd = vim.fn.getcwd()
            return vim.iter(vim.v.oldfiles)
                :filter(function(file)
                    return utils.string_starts_with(file, cwd)
                end)
                :totable()
        end

        require("telescope").load_extension("fzf")
        require("telescope").load_extension("live_grep_args")

        local builtin = require("telescope.builtin")
        local extensions = require("telescope").extensions

        local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

        vim.keymap.set("n", "<leader>fg", extensions.live_grep_args.live_grep_args)
        vim.keymap.set("n", "<leader>fG", live_grep_args_shortcuts.grep_word_under_cursor)

        vim.keymap.set("n", "<leader>of", builtin.oldfiles)
        vim.keymap.set("n", "<leader>oF", function()
            extensions.live_grep_args.live_grep_args({
                search_dirs = oldfiles_cwd(),
                prompt_title = "Oldfiles (Live Grep)",
            })
        end)

        vim.keymap.set("n", "<leader>ht", builtin.help_tags)
        vim.keymap.set("n", "<leader>gs", builtin.git_status)
        vim.keymap.set("n", "<C-p>", builtin.find_files)
        vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)
        vim.keymap.set("n", "<leader>b", builtin.buffers)
        vim.keymap.set("n", "<leader>qf", builtin.quickfix)
        vim.keymap.set("n", "<leader>op", builtin.pickers)

        local function current_wd()
            if vim.bo.filetype == "oil" then
                return require("oil").get_current_dir()
            end
            return vim.fn.expand("%:p:h")
        end

        vim.keymap.set("n", "<leader>fr", function()
            builtin.find_files({ cwd = current_wd() })
        end)
        vim.keymap.set("n", "<leader>fR", function()
            extensions.live_grep_args.live_grep_args({ search_dirs = { current_wd() } })
        end)

        vim.keymap.set({ "n", "v" }, "<leader>gc", function()
            local mode = vim.api.nvim_get_mode().mode
            if mode == "n" then
                builtin.git_bcommits()
            else
                -- when next version of telescope releases this will be available
                -- builtin.git_bcommits_range()
            end
        end, {})
    end,
}
