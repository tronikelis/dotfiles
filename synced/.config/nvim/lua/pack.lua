local augroup = vim.api.nvim_create_augroup("lua/pack.lua", {})

local M = {}

function M.set_hooks(tbl)
    M.hooks = tbl
end

vim.api.nvim_create_autocmd("PackChanged", {
    group = augroup,
    callback = function(ev)
        local name, kind, path, active = ev.data.spec.name, ev.data.kind, ev.data.path, ev.data.active
        for _, hook in ipairs(M.hooks) do
            if hook[1] == name and vim.tbl_contains(hook[2], kind) then
                print("running hook for", name)
                if (hook[4] or {}).packadd then
                    if not active then
                        vim.cmd.packadd(name)
                    end
                end

                hook[3](path)
                break
            end
        end
    end,
})

return M
