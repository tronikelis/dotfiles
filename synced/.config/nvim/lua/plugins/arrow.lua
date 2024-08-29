return {
	"otavioschwanck/arrow.nvim",
	config = function()
		-- mappings = {
		-- 	edit = "e",
		-- 	delete_mode = "d",
		-- 	clear_all_items = "C",
		-- 	toggle = "s", -- used as save if separate_save_and_remove is true
		-- 	open_vertical = "v",
		-- 	open_horizontal = "-",
		-- 	quit = "q",
		-- 	remove = "x", -- only used if separate_save_and_remove is true
		-- 	next_item = "]",
		-- 	prev_item = "["
		-- },

		require("arrow").setup({
			show_icons = true,
			hide_handbook = true,
			leader_key = "<leader><leader>",
		})
	end,
}
