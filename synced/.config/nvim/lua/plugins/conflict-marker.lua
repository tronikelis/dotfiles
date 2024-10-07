return {
	"Tronikelis/conflict-marker.nvim",
	config = function()
		require("conflict-marker").setup({
			on_attach = function(conflict)
				local map = function(key, fn)
					vim.keymap.set("n", key, fn, { buffer = conflict.bufnr })
				end

				-- map("co", function()
				-- 	conflict:choose_ours()
				-- end)
				-- map("ct", function()
				-- 	conflict:choose_theirs()
				-- end)
				-- map("cb", function()
				-- 	conflict:choose_both()
				-- end)
				-- map("cn", function()
				-- 	conflict:choose_none()
				-- end)

				local MID = "^=======$"

				map("[x", function()
					vim.cmd("?" .. MID)
					vim.cmd("nohl")
				end)

				map("]x", function()
					vim.cmd("/" .. MID)
					vim.cmd("nohl")
				end)
			end,
		})
	end,
}
