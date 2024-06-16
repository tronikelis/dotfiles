return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"Tronikelis/lualine-components.nvim",
	},
	config = function()
		local filename_oil = require("lualine-components.filename-oil")
		local branch_oil = require("lualine-components.branch-oil")
		local linecount = require("lualine-components.linecount")
		local smol_mode = require("lualine-components.smol-mode")

		local formatter_status = function()
			local available = "󰏫"
			local not_available = "󰏯"

			local ok, conform = pcall(require, "conform")
			if not ok then
				return not_available
			end

			if #conform.list_formatters() == 0 and not conform.will_fallback_lsp() then
				return not_available
			end

			if vim.g.disable_autoformat or vim.b.disable_autoformat then
				return not_available
			end

			return available
		end

		require("lualine").setup({
			options = {
				component_separators = {
					left = "|",
					right = "|",
				},
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_y = { formatter_status, linecount },
				lualine_a = { smol_mode },
				lualine_b = {
					branch_oil,
					"diff",
					{
						"diagnostics",
						symbols = { error = "E", warn = "W", info = "I", hint = "H" },
					},
				},
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
						"datetime",
						style = "%H:%M",
					},
				},
				lualine_z = {
					{
						"datetime",
						style = "%d/%m/%Y",
					},
				},
			},
		})
	end,
}
