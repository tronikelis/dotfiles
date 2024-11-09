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

        require("telescope").setup({
            defaults = {
                layout_strategy = "flex",
                vimgrep_arguments = vimgrep_arguments,
                file_ignore_patterns = {
                    ".git/",
                },
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<c-s>"] = actions.file_split,
                        ["<c-v>"] = actions.file_vsplit,
                    },
                },
                path_display = { "truncate" },
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
            }),
            extensions = with_picker_defaults({
                live_grep_args = {
                    mappings = {
                        i = {
                            ["<c-space>"] = actions.to_fuzzy_refine,
                        },
                    },
                },
            }),
        })

        require("telescope").load_extension("fzf")
        require("telescope").load_extension("live_grep_args")

        local builtin = require("telescope.builtin")
        local extensions = require("telescope").extensions

        vim.keymap.set("n", "<leader>fG", builtin.grep_string)
        vim.keymap.set("n", "<leader>fg", extensions.live_grep_args.live_grep_args)

        vim.keymap.set("n", "<leader>of", builtin.oldfiles)
        vim.keymap.set("n", "<leader>ht", builtin.help_tags)
        vim.keymap.set("n", "<leader>gs", builtin.git_status)
        vim.keymap.set("n", "<C-p>", builtin.find_files)
        vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)
        vim.keymap.set("n", "<leader>b", builtin.buffers)

        vim.keymap.set("n", "<leader>fr", function()
            local cwd = require("oil").get_current_dir()
            cwd = cwd or vim.fn.expand("%:p:h")
            builtin.find_files({ cwd = cwd })
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
