local augroup = vim.api.nvim_create_augroup("plugin/_pack_tree-sitter.lua", {})

require("treesitter-context").setup({
    enable = true,
    max_lines = 5,
    multiline_threshold = 1,
    min_window_height = 25,
})

require("nvim-treesitter").install({
    "rust",
    "markdown",
    "typescript",
    "tsx",
    "jsx",
    "javascript",
    "json",
    "jsonc",
    "go",
    "yaml",
    "toml",
    "lua",
    "zig",
    "ruby",
    "c",
    "cpp",
    "bash",
    "css",
    "sql",
    "scss",
    "python",
    "java",
    "c_sharp",
    "kotlin",
    "swift",
    "php",
    "dart",
    "gdscript",
    "templ",
    "html",
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = augroup,
    callback = function(ev)
        if vim.b[ev.buf].is_treesitter_started then
            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    callback = function(ev)
        vim.treesitter.stop(ev.buf)
        local success, parser = pcall(vim.treesitter.get_parser, ev.buf)
        if success and parser then
            vim.treesitter.start(ev.buf)
            vim.b[ev.buf].is_treesitter_started = true
        end
    end,
})
