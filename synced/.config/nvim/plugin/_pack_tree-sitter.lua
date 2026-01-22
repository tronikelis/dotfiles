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

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    callback = function(ev)
        vim.treesitter.stop(ev.buf)
        local success, parser = pcall(vim.treesitter.get_parser, ev.buf)
        if success and parser then
            vim.treesitter.start(ev.buf)

            assert(vim.api.nvim_get_current_buf() == ev.buf, "sanity check current buffer is event buffer")
            vim.wo[0][0].foldmethod = "expr"
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "\n setl foldmethod< foldexpr<"
        end
    end,
})
