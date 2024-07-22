return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-frecency.nvim",
	},
	config = function()
		local picker_config = function()
			return {
				show_line = false,
			}
		end

		local actions = require("telescope.actions")

		local vimgrep_arguments = {
			table.unpack(require("telescope.config").values.vimgrep_arguments),
		}

		table.insert(vimgrep_arguments, "--hidden")
		table.insert(vimgrep_arguments, "--trim")

		require("telescope").setup({
			defaults = {
				vimgrep_arguments = vimgrep_arguments,
				file_ignore_patterns = {
					".git/",
				},
				mappings = {
					i = {
						["<esc>"] = actions.close,
					},
				},
				path_display = { "truncate" },
			},
			pickers = {
				lsp_references = picker_config(),
				lsp_definitions = picker_config(),
				find_files = {
					hidden = true,
				},
				buffers = {
					sort_mru = true,
					show_all_buffers = false,
					only_cwd = true,
				},
			},
			extensions = {
				frecency = {
					db_safe_mode = false,
					auto_validate = true,
				},
			},
		})

		require("telescope").load_extension("fzf")

		require("telescope").load_extension("frecency")
		vim.keymap.set("n", "<leader><leader>", function()
			require("telescope").extensions.frecency.frecency({
				workspace = "CWD",
			})
		end)

		local builtin = require("telescope.builtin")

		vim.keymap.set("n", "<leader>fg", builtin.live_grep)
		vim.keymap.set("n", "<leader>gs", builtin.git_status)
		vim.keymap.set("n", "<C-p>", builtin.find_files)
		vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)
		vim.keymap.set("n", "<leader>b", builtin.buffers)
	end,
}
