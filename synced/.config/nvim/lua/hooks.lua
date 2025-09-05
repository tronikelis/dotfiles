local M = {}

---@type table<string, string>
local after_update = {}

---@param plugins string
---@param cmd string
function M.after_update(plugins, cmd)
    after_update[plugins] = cmd
end

local function run()
    local mtime_cache_path = vim.fs.joinpath(vim.fn.stdpath("config"), "mtime_cache.json")

    require("utils").read_file(mtime_cache_path, function(data, err)
        local mtime_cache = {}
        if not err then
            mtime_cache = vim.json.decode(data)
        end

        local tasks = 0
        for k, v in pairs(after_update) do
            tasks = tasks + 1
            local plugin_dir = vim.fs.joinpath(vim.fn.expand("~/.local/share/nvim/site/pack/plugins/start"), k)

            local cached_mtime = mtime_cache[k] or 0
            vim.uv.fs_stat(
                plugin_dir,
                vim.schedule_wrap(function(err, stat)
                    local current_mtime = stat and stat.mtime.sec or cached_mtime
                    mtime_cache[k] = current_mtime

                    tasks = tasks - 1
                    if tasks == 0 then
                        vim.fn.writefile({ vim.json.encode(mtime_cache) }, mtime_cache_path)
                    end

                    if err or not stat then
                        return
                    end

                    if current_mtime <= cached_mtime then
                        return
                    end

                    if v:sub(1, 1) == ":" then
                        vim.cmd(v:sub(2))
                    else
                        vim.system({ "bash", "-c", v }, { cwd = plugin_dir }, function(out)
                            print(out.stdout)
                            print(out.stderr)
                        end)
                    end
                end)
            )
        end
    end)
end

vim.api.nvim_create_autocmd("VimEnter", {
    callback = run,
})

return M
