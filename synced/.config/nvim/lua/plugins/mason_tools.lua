local ensure_installed = {
    "css-lsp",
    "eslint-lsp",
    "html-lsp",
    "json-lsp",
    "prettierd",
    "tailwindcss-language-server",
    "typescript-language-server",

    "bash-language-server",
    "clangd",
    "cspell",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "gopls",
    "hyprls",
    "jdtls",
    "lua-language-server",
    "marksman",
    "rust-analyzer",
    "shellcheck",
    "shfmt",
    "stylua",
    "taplo",
    "templ",
    "yaml-language-server",
    "zls",
}

return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    opts = {
        ensure_installed = ensure_installed,

        integrations = {
            ["mason-lspconfig"] = false,
            ["mason-null-ls"] = false,
            ["mason-nvim-dap"] = false,
        },
    },
}
