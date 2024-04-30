local weather = ""
local update_weather
update_weather = function()
	vim.fn.jobstart('curl -s -m 30 "wttr.in/Vilnius?format=%t" | tr -d "[:blank:]"', {
		detach = false,
		stdout_buffered = true,
		on_stdout = function(chan_id, stdout)
			weather = stdout[1]
		end,
		on_exit = function()
			local mins30 = 1000 * 60 * 30
			vim.defer_fn(update_weather, mins30)
		end,
	})
end
update_weather()

local get_weather = function()
	return weather
end

local get_buff_linecount = function()
	local count = vim.api.nvim_buf_line_count(0)

	if count >= 1000 then
		count = count / 1000

		local dotIndex = string.find(count, ".", 1, true)

		if dotIndex ~= nil then
			count = string.sub(count, 1, dotIndex + 1)
		else
			count = count .. ".0"
		end

		count = count .. "K"
	end

	return count
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("lualine").setup({
			options = {
				component_separators = {
					left = "/",
					right = "\\",
				},
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_y = { get_buff_linecount },
				lualine_a = {
					function()
						local mode = require("lualine.utils.mode").get_mode()
						return string.sub(mode, 1, 1)
					end,
				},
			},
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
				lualine_y = { get_weather },
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
