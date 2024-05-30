return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"debugloop/telescope-undo.nvim",

		{
			"danielfalk/smart-open.nvim",
			branch = "0.2.x",
			dependencies = { "kkharji/sqlite.lua" },
		},
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
				},
			},
			extensions = {},
		})

		require("telescope").load_extension("fzf")

		require("telescope").load_extension("undo")
		vim.keymap.set("n", "<leader>u", require("telescope").extensions.undo.undo)

		require("telescope").load_extension("smart_open")
		vim.keymap.set("n", "<leader><leader>", function()
			require("telescope").extensions.smart_open.smart_open({
				cwd_only = true,
				filename_first = false,
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
