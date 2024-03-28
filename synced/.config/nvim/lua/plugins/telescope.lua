return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.6",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local function live_grep_from_project_git_root()
			local function is_git_repo()
				vim.fn.system("git rev-parse --is-inside-work-tree")

				return vim.v.shell_error == 0
			end

			local function get_git_root()
				local dot_git_path = vim.fn.finddir(".git", ".;")
				return vim.fn.fnamemodify(dot_git_path, ":h")
			end

			local opts = {}

			if is_git_repo() then
				opts = {
					cwd = get_git_root(),
				}
			end

			require("telescope.builtin").live_grep(opts)
		end

		local function find_files_from_project_git_root()
			local function is_git_repo()
				vim.fn.system("git rev-parse --is-inside-work-tree")
				return vim.v.shell_error == 0
			end
			local function get_git_root()
				local dot_git_path = vim.fn.finddir(".git", ".;")
				return vim.fn.fnamemodify(dot_git_path, ":h")
			end
			local opts = {}
			if is_git_repo() then
				opts = {
					cwd = get_git_root(),
				}
			end
			require("telescope.builtin").find_files(opts)
		end

		local picker_config = function()
			return {
				show_line = false,
			}
		end

		local actions = require("telescope.actions")

		require("telescope").setup({
			defaults = {
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
			},
		})

		require("telescope").load_extension("fzf")

		local builtin = require("telescope.builtin")

		vim.keymap.set("n", "<leader>ff", find_files_from_project_git_root, {})
		vim.keymap.set("n", "<leader>fg", live_grep_from_project_git_root, {})
		vim.keymap.set("n", "<leader>gs", builtin.git_status, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
	end,
}
