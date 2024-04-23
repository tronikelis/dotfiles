return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			tabline = {
				lualine_b = {
					{
						"filename",
						path = 1,
					},
				},
				lualine_a = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {
					{
						"datetime",
						style = "%H:%M | %d/%m/%Y",
					},
				},
			},
		})
	end,
}
