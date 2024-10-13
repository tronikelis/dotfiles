local ensure_installed = {
    "tailwindcss-language-server",
    "typescript-language-server",
    "css-lsp",
    "eslint-lsp",
    "html-lsp",
    "json-lsp",
    "prettierd",

    "bash-language-server",
    "clangd",
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
    "typos-lsp",
    "yaml-language-server",
    "zls",
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
