return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"Tronikelis/lualine-components.nvim",
	},
	config = function()
		local weather = require("lualine-components.weather")
		local filename_oil = require("lualine-components.filename-oil")
		local branch_oil = require("lualine-components.branch-oil")
		local linecount = require("lualine-components.linecount")
		local smol_mode = require("lualine-components.smol-mode")

		local formatter_status = function()
			if vim.g.disable_autoformat or vim.b.disable_autoformat then
				return "󰏯"
			end

			return "󰏫"
		end

		require("lualine").setup({
			options = {
				component_separators = {
					left = "/",
					right = "\\",
				},
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_y = { formatter_status, linecount },
				lualine_a = { smol_mode },
				lualine_b = { branch_oil, "diff", "diagnostics" },
			},
			tabline = {
				lualine_b = {
					{
						filename_oil,
						path = 1,
					},
				},
				lualine_a = {},
				lualine_c = {},
				lualine_x = {},
				lualine_y = {
					{
						weather,
						city = "Vilnius",
					},
				},
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
