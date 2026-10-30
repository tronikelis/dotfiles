local M = {}

---@enum config.LSP
local LSP = {
    biome = "biome",
    clangd = "clangd",
    dartls = "dartls",
    eslint = "eslint",
    gdscript = "gdscript",
    gopls = "gopls",
    html = "html",
    jdtls = "jdtls",
    jsonls = "jsonls",
    lua_ls = "lua_ls",
    marksman = "marksman",
    pyright = "pyright",
    rubocop = "rubocop",
    ruby_lsp = "ruby_lsp",
    rust_analyzer = "rust_analyzer",
    tailwindcss = "tailwindcss",
    taplo = "taplo",
    templ = "templ",
    ts_ls = "ts_ls",
    vespa_ls = "vespa_ls",
    yamlls = "yamlls",
    zls = "zls",
    metals = "metals",
}

local function lsp_enable_metals()
    local augroup = vim.api.nvim_create_augroup("plugin/startup.lsp.metals", {})
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = { "scala", "sbt" },
        callback = function()
            if not _G.__nvim_metals_config then
                _G.__nvim_metals_config = require("metals").bare_config()
                local config = _G.__nvim_metals_config

                config.init_options.statusBarProvider = "off"
                config.capabilities = require("blink.cmp").get_lsp_capabilities()
            end
            require("metals").initialize_or_attach(_G.__nvim_metals_config)
        end,
    })
end

---@param name string
local function lsp_enable(name)
    if not vim.tbl_contains(vim.tbl_values(LSP), name) then
        vim.notify(string.format("lsp_enable: lsp %s is not known, add it if valid", name), vim.log.levels.WARN)
        return
    end

    if name == "metals" then
        lsp_enable_metals()
        return
    end

    vim.lsp.enable(name)
end

-- enable an lsp in a startup script.
---@param name config.LSP|config.LSP[]
function M.lsp_enable(name)
    if type(name) == "string" then
        lsp_enable(name)
        return
    end

    if type(name) == "table" then
        for _, v in ipairs(name) do
            lsp_enable(v)
        end
        return
    end

    error(string.format("expected string|table, got: %s", type(name)))
end

return M
