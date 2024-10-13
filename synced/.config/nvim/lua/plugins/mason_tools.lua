local ensure_installed = {
    "zls",
    "templ",
    "marksman",
    "clangd",
    "hyprls",
    "bashls",
    "css-lsp",
    "docker_compose_language_service",
    "dockerls",
    "eslint-lsp",
    "gopls",
    "html-lsp",
    "jdtls",
    "json-lsp",
    "lua_ls",
    "prettierd",
    "rust_analyzer",
    "shellcheck",
    "shfmt",
    "stylua",
    "tailwindcss-language-server",
    "taplo",
    "ts_ls",
    "typos-lsp",
    "yamlls",
}

return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    config = function()
        require("mason-tool-installer").setup({
            ensure_installed = ensure_installed,

            integrations = {
                ["mason-lspconfig"] = false,
                ["mason-null-ls"] = false,
                ["mason-nvim-dap"] = false,
            },
        })
    end,
}
