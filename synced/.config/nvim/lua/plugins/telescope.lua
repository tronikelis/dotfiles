local utils = require("utils")

return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
        "nvim-telescope/telescope-live-grep-args.nvim",
        "tronikelis/telescope-git-diff-stat.nvim",
        "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
        local actions = require("telescope.actions")
        local actions_state = require("telescope.actions.state")
        local lga_actions = require("telescope-live-grep-args.actions")

        local vimgrep_arguments = utils.flatten({ -- poor mans table copy, lmao
            require("telescope.config").values.vimgrep_arguments,
        })

        table.insert(vimgrep_arguments, "--hidden")
        table.insert(vimgrep_arguments, "--trim")

        local picker_defaults = {
            debounce = 300,
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
                mappings = {
                    i = {
                        ["<c-h>"] = actions.preview_scrolling_left,
                        ["<c-l>"] = actions.preview_scrolling_right,

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
                    mappings = {
                        i = {
                            ["<c-x>"] = actions.delete_buffer,
                        },
                    },
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
                    mappings = {
                        i = {
                            ["<c-space>"] = actions.to_fuzzy_refine,
                            ["<c-f>"] = lga_actions.quote_prompt({ postfix = " -F" }),
                        },
                    },
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

        local function current_wd()
            if vim.bo.filetype == "oil" then
                return require("oil").get_current_dir()
            end
            return vim.fn.expand("%:p:h")
        end

        require("telescope").load_extension("fzf")
        require("telescope").load_extension("ui-select")
        require("telescope").load_extension("live_grep_args")
        require("telescope").load_extension("git_diff_stat")

        local builtin = require("telescope.builtin")
        local extensions = require("telescope").extensions

        local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

        vim.keymap.set("n", "<leader>fg", extensions.live_grep_args.live_grep_args)
        vim.keymap.set("n", "<leader>fG", live_grep_args_shortcuts.grep_word_under_cursor)

        vim.keymap.set("n", "<leader>gd", extensions.git_diff_stat.git_diff_stat)
        vim.keymap.set("n", "<leader>gs", builtin.git_status)

        vim.keymap.set("n", "<leader>of", builtin.oldfiles)
        vim.keymap.set("n", "<C-p>", builtin.find_files)

        vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)
        vim.keymap.set("n", "<leader>b", builtin.buffers)
        vim.keymap.set("n", "<leader>qf", builtin.quickfix)

        vim.keymap.set("n", "<leader>ht", builtin.help_tags)
        vim.keymap.set("n", "<leader>op", builtin.pickers)

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
                builtin.git_bcommits_range()
            end
        end, {})
    end,
}
