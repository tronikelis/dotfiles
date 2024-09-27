return {
	"Tronikelis/xylene.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope.nvim",
		"stevearc/oil.nvim",
	},
	config = function()
		require("xylene").setup({
			on_attach = function(renderer)
				vim.keymap.set("n", "<c-cr>", function()
					local row = vim.api.nvim_win_get_cursor(0)[1]

					local file = renderer:find_file(row)
					if not file then
						return
					end

					require("oil").open(file.path)
				end, { buffer = renderer.buf })

				vim.keymap.set("n", "<c-f>", function()
					local builtin = require("telescope.builtin")
					local action_state = require("telescope.actions.state")
					local actions = require("telescope.actions")

					builtin.find_files({
						find_command = { "fd", "-t", "d" },
						attach_mappings = function(_, map)
							map("i", "<cr>", function(prompt_bufnr)
								local entry = action_state.get_selected_entry()
								actions.close(prompt_bufnr)

								local path = vim.fs.joinpath(entry.cwd, entry[1])
								-- remove trailing /
								path = path:sub(1, -2)

								local utils = require("xylene.utils")

								--- find the file that will be rendered
								--- in this case the root file
								local root, root_row
								for i, f in ipairs(renderer.files) do
									if utils.string_starts_with(path, f.path) then
										root_row = i
										root = f
										break
									end
								end

								local pre_from, pre_to = renderer:pre_render_file(root, root_row)

								local file, line = renderer:open_from_filepath(path)
								if not file then
									return
								end

								file:open()
								renderer:render_file(root, pre_from, pre_to)

								vim.api.nvim_win_set_cursor(0, { line, file:indent_len() })
							end)

							return true
						end,
					})
				end, { buffer = renderer.buf })
			end,
		})
	end,
}
