local M = {}

---@class Caser.Options
---@field prefix string

---@type Caser.Options
M.options = {
	prefix = "gs",
}

---@param a string
---@param b string
---@return boolean
local function cases_differ(a, b)
	assert(#a == 1 and #b == 1, "cases_differ: 1 len")
	if a:match("%d+") or b:match("%d+") then
		return false
	end
	return a:upper() == a and b:lower() == b or a:lower() == a and b:upper() == b
end

---@param line string
---@return string[]
local function separate_line(line)
	---@type string[]
	local separated = {}
	local current = ""
	local prev = ""

	local i = 1
	for v in line:gmatch(".") do
		if vim.list_contains({ "_", " ", "-" }, v) then
			table.insert(separated, current)
			current = ""
		else
			if prev ~= "" then
				if cases_differ(prev, v) then
					table.insert(separated, current:sub(1, -2) .. prev:lower())
					current = v:lower()
					v = ""
				end
			end

			current = current .. v
			if i ~= 1 then
				prev = v
			end
		end

		i = i + 1
	end
	table.insert(separated, current)

	for i in ipairs(separated) do
		separated[i] = separated[i]:lower()
	end

	return separated
end

---@alias Caser.SeparatedLines [string, integer, integer, integer][]

---@param type string
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@return [string, integer, integer, integer][]
local function get_separated_lines(type, start_row, start_col, end_row, end_col)
	if type == "line" then
		local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, true)
		local operator_lines = {}
		for i, v in ipairs(lines) do
			table.insert(operator_lines, { v, start_row + i - 1, 0, #v })
		end
		return operator_lines
	end

	if type == "char" then
		local end_col = end_col + 1
		local line = vim.api.nvim_buf_get_text(0, start_row, start_col, start_row, end_col, {})[1]
		return { {
			line,
			start_row,
			start_col,
			end_col,
		} }
	end

	if type == "block" then
		local operator_lines = {}
		for i = start_row, end_row do
			local end_col = end_col + 1
			local line = vim.api.nvim_buf_get_text(0, i, start_col, i, end_col, {})[1]
			table.insert(operator_lines, {
				line,
				i,
				start_col,
				end_col,
			})
		end
		return operator_lines
	end

	error("unknown type " .. type)
end

---@return integer, integer, integer, integer
local function get_visual_marks()
	local ending = vim.fn.getpos(".")
	local start = vim.fn.getpos("v")

	if start[2] > ending[2] or start[3] > ending[3] then
		start, ending = ending, start
	end

	return start[2] - 1, start[3] - 1, ending[2] - 1, ending[3] - 1
end

---@return integer, integer, integer, integer
local function get_operator_marks()
	local start = vim.api.nvim_buf_get_mark(0, "[")
	local ending = vim.api.nvim_buf_get_mark(0, "]")
	return start[1] - 1, start[2], ending[1] - 1, ending[2]
end

---@return string
local function mode_to_type()
	local mode = vim.api.nvim_get_mode().mode
	local type = "char"
	if mode == "v" then
		type = "char"
	elseif mode == "V" then
		type = "line"
	elseif mode == "\22" then
		type = "block"
	end
	return type
end

---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@param replacement string
local function nvim_buf_set_text(start_row, start_col, end_row, end_col, replacement)
	local curr = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})[1]
	if curr == replacement then
		return
	end

	vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { replacement })
end

---@param type string
---@param marks [integer, integer, integer, integer]
local function snake_set(type, marks)
	local lines = get_separated_lines(type, unpack(marks))
	for _, line in ipairs(lines) do
		local separate = separate_line(line[1])
		local joined = table.concat(separate, "_")
		nvim_buf_set_text(line[2], line[3], line[2], line[4], joined)
	end
end

---@param v string
local function snake_callback(v)
	snake_set(v, { get_operator_marks() })
end
_G.__caser_operatorfunc_snake = snake_callback

---@param type string
---@param marks [integer, integer, integer, integer]
local function camel_set(type, marks)
	local lines = get_separated_lines(type, unpack(marks))
	for _, line in ipairs(lines) do
		---@type string[]
		local separate = vim.iter(separate_line(line[1]))
			:filter(function(v)
				return v ~= ""
			end)
			:totable()

		local joined = ""
		for i, v in ipairs(separate) do
			local prefix = ""
			if i ~= 1 then
				local first = v:sub(1, 1)
				v = v:sub(2)
				prefix = first:upper()
			end

			joined = joined .. prefix .. v
		end
		nvim_buf_set_text(line[2], line[3], line[2], line[4], joined)
	end
end

---@param v string
local function camel_callback(v)
	camel_set(v, { get_operator_marks() })
end
_G.__caser_operatorfunc_camel = camel_callback

---@param type string
---@param marks [integer, integer, integer, integer]
local function kebab_set(type, marks)
	local lines = get_separated_lines(type, unpack(marks))
	for _, line in ipairs(lines) do
		local separate = separate_line(line[1])
		local joined = table.concat(separate, "-")
		nvim_buf_set_text(line[2], line[3], line[2], line[4], joined)
	end
end

---@param v string
local function kebab_callback(v)
	kebab_set(v, { get_operator_marks() })
end
_G.__caser_operatorfunc_kebab = kebab_callback

---@param type string
---@param marks [integer, integer, integer, integer]
local function space_set(type, marks)
	local lines = get_separated_lines(type, unpack(marks))
	for _, line in ipairs(lines) do
		local separate = separate_line(line[1])
		local joined = table.concat(separate, " ")
		nvim_buf_set_text(line[2], line[3], line[2], line[4], joined)
	end
end

---@param v string
local function space_callback(v)
	space_set(v, { get_operator_marks() })
end
_G.__caser_operatorfunc_space = space_callback

---@param opts Caser.Options?
function M.setup(opts)
	opts = opts or {}
	M.options = vim.tbl_deep_extend("force", M.options, opts)

	vim.keymap.set("n", M.options.prefix .. "s", function()
		vim.opt.operatorfunc = "v:lua.__caser_operatorfunc_snake"
		return "g@"
	end, { expr = true })
	vim.keymap.set("v", M.options.prefix .. "s", function()
		snake_set(mode_to_type(), { get_visual_marks() })
	end, {})

	vim.keymap.set("n", M.options.prefix .. "c", function()
		vim.opt.operatorfunc = "v:lua.__caser_operatorfunc_camel"
		return "g@"
	end, { expr = true })
	vim.keymap.set("v", M.options.prefix .. "c", function()
		camel_set(mode_to_type(), { get_visual_marks() })
	end)

	vim.keymap.set("n", M.options.prefix .. "k", function()
		vim.opt.operatorfunc = "v:lua.__caser_operatorfunc_kebab"
		return "g@"
	end, { expr = true })
	vim.keymap.set("v", M.options.prefix .. "k", function()
		kebab_set(mode_to_type(), { get_visual_marks() })
	end)

	vim.keymap.set("n", M.options.prefix .. " ", function()
		vim.opt.operatorfunc = "v:lua.__caser_operatorfunc_space"
		return "g@"
	end, { expr = true })
	vim.keymap.set("v", M.options.prefix .. " ", function()
		space_set(mode_to_type(), { get_visual_marks() })
	end)
end

return M
