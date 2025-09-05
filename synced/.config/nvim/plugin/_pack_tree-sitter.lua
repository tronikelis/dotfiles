require("hooks").after_update("nvim-treesitter", ":TSUpdate")

require("treesitter-context").setup({
    enable = true,
    max_lines = 5,
    multiline_threshold = 1,
    min_window_height = 25,
})

-- folding
vim.opt.foldtext = ""
vim.opt.foldcolumn = "0"
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

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

vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        local success, parser = pcall(vim.treesitter.get_parser, ev.buf)
        if success and parser then
            vim.treesitter.stop(ev.buf)
            vim.treesitter.start(ev.buf)
        end
    end,
})
