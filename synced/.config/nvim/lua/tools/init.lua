local M = {}

---@class NvimConfig.Tool
---@field name string
---@field deps string[]

---@type NvimConfig.Tool[]
local tools = {
    { name = "gofumpt", deps = { "go" } },
    { name = "gopls", deps = { "go" } },

    { name = "pyright", deps = { "python3" } },
    { name = "black", deps = { "python3" } },

    { name = "biome", deps = { "npm" } },
    { name = "eslint-lsp", deps = { "npm" } },
    { name = "html-lsp", deps = { "npm" } },
    { name = "json-lsp", deps = { "npm" } },
    { name = "prettierd", deps = { "npm" } },
    { name = "tailwindcss-language-server", deps = { "npm" } },
    { name = "typescript-language-server", deps = { "npm" } },
    { name = "yaml-language-server", deps = { "npm" } },

    { name = "rubocop", deps = { "ruby" } },
    { name = "ruby-lsp", deps = { "ruby" } },

    { name = "marksman", deps = {} },
    { name = "lua-language-server", deps = {} },
    { name = "rust-analyzer", deps = {} },
    { name = "stylua", deps = {} },
    { name = "taplo", deps = {} },
    { name = "templ", deps = {} },
    { name = "zls", deps = {} },
}

local function ensure_installed()
    local registry = require("mason-registry")

    ---@type string[]
    local filtered = vim.iter(tools)
        :filter(function(x)
            for _, v in ipairs(x.deps) do
                if vim.fn.executable(v) == 0 then
                    return false
                end
            end

            return true
        end)
        :map(function(x)
            return x.name
        end)
        :totable()

    registry.refresh(function()
        for _, v in ipairs(registry.get_installed_package_names()) do
            if not vim.list_contains(filtered, v) then
                print(string.format("uninstalling %s", v))
                registry.get_package(v):uninstall()
            end
        end

        for _, v in ipairs(filtered) do
            local pkg = registry.get_package(v)

            if not registry.is_installed(v) then
                print(string.format("installing %s", v))
                pkg:install()
            end
        end
    end)
end

function M.setup()
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        callback = ensure_installed,
    })
end

return M
