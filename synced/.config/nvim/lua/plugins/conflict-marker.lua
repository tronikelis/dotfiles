return {
    "tronikelis/conflict-marker.nvim",
    event = "VeryLazy",
    opts = {
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

            local next = function()
                vim.cmd(string.format("silent! /%s", MID))
            end
            local prev = function()
                vim.cmd(string.format("silent! ?%s", MID))
            end

            map("]x", next)
            map("[x", prev)
        end,
    },
}
