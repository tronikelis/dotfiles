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

        local next = function()
            if not pcall(vim.cmd, string.format("/%s", MID)) then
                print("No conflicts")
            end
        end
        local prev = function()
            if not pcall(vim.cmd, string.format("?%s", MID)) then
                print("No conflicts")
            end
        end

        map("]h", next)
        map("[h", prev)
    end,
})
