local path = require("utils.path")

local get_sorted_files = function()
	local curr_file = vim.fn.expand("%:p")
	local files = path.files(vim.fn.expand("%:p:h"), { full = true })

	table.sort(files)

	local curr_index = vim.fn.index(files, curr_file)
	if curr_index == -1 then
		return
	end

	-- vim.fn.index returns index - 1 for some reason
	curr_index = curr_index + 1

	return files, curr_index
end

local cycle_file = function(target)
	local files, curr_index = get_sorted_files()
	if files == nil or curr_index == nil then
		return
	end

	local next_file = files[curr_index + target]
	local curr_file = files[curr_index]

	if next_file == nil or next_file == curr_file then
		return
	end

	vim.cmd("e " .. next_file)
end

vim.keymap.set("n", "[f", function()
	cycle_file(-1)
end)

vim.keymap.set("n", "]f", function()
	cycle_file(1)
end)
