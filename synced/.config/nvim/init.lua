-- unpack is deprecated in favor of table.unpack,
-- but nvim still uses older lua that does not support it, so fallback
table.unpack = table.unpack or unpack

local augroup = vim.api.nvim_create_augroup("init.lua", {})

-- todo:
-- set chistory=50
-- try out Difftool builtin plugin 0.12

require("paq")({
    "NMAC427/guess-indent.nvim",
    "folke/lazydev.nvim",
    "folke/ts-comments.nvim",
    "ibhagwan/fzf-lua",
    "kylechui/nvim-surround",
    "lewis6991/gitsigns.nvim",
    "mbbill/undotree", -- replace with builtin undotree plugin 0.12
    "mfussenegger/nvim-jdtls",
    "neovim/nvim-lspconfig",
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter-context",
    "savq/paq-nvim",
    "scalameta/nvim-metals",
    "stevearc/conform.nvim",
    "stevearc/oil.nvim",
    "tronikelis/blink-cmp-ctags",
    "tronikelis/caser.nvim",
    "tronikelis/conflict-marker.nvim",
    "tronikelis/gitdive.nvim",
    "tronikelis/indent-textobject.nvim",
    "tronikelis/sstash.nvim",
    "tronikelis/ts-autotag.nvim",
    "tronikelis/xylene.nvim",
    { "catppuccin/nvim", branch = "v1.11.0" },
    { "nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate" },
    { "saghen/blink.cmp", branch = "v1.8.0", build = "cargo build --release" },
})

require("catppuccin").setup({
    flavour = "mocha",
    no_italic = true,
    transparent_background = false,
})

vim.cmd.colorscheme("catppuccin")

if not vim.g.del_mappings then
    local del_mappings = {
        "gri",
        "grr",
        "gra",
        "grn",
        "grt",
    }
    for _, v in ipairs(del_mappings) do
        vim.keymap.del("", v)
    end
end
vim.g.del_mappings = true

-- interferes with <C-c> to exit insert mode
vim.g.omni_sql_no_default_maps = true
-- this opens a split by default, what
vim.g.zig_fmt_parse_errors = 0

vim.opt.wrap = false
vim.opt.matchpairs:append("<:>")

vim.opt.softtabstop = -1 -- use shiftwidth value
vim.opt.shiftwidth = 4 -- number of spaces to << >>
vim.opt.tabstop = 4 -- number of spaces tab counts for
vim.opt.expandtab = true -- convert tab to spaces

-- To disable jumping
vim.opt.signcolumn = "yes"
vim.opt.pumheight = 10 -- pop up menu height
vim.opt.relativenumber = true
vim.opt.number = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait1000-blinkoff500-blinkon500"
vim.opt.ttimeoutlen = 10 -- faster insert mode exits
vim.opt.listchars = {
    nbsp = "+",
    space = "•",
    tab = "• ",
}
vim.opt.sidescroll = 10
vim.opt.sidescrolloff = 2

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.autoindent = true

if vim.fn.executable("rg") == 1 then
    -- the default is rg -uu --vimgrep, but -uu ignores .gitignore and shows hidden files
    vim.opt.grepprg = "rg --vimgrep -S --hidden"
end

-- spelling
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"
vim.opt.spell = false -- im using typos-lsp

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true

-- splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- enabled lsps
for _, v in pairs({
    "biome",
    "clangd",
    "dartls",
    "eslint",
    "gdscript",
    "gopls",
    "html",
    "jdtls",
    "jsonls",
    "lua_ls",
    "marksman",
    "pyright",
    "rubocop",
    "ruby_lsp",
    "rust_analyzer",
    "tailwindcss",
    "taplo",
    "templ",
    "ts_ls",
    "vespa_ls",
    "yamlls",
    "zls",
}) do
    vim.lsp.enable(v)
end

vim.opt.diffopt:append("algorithm:histogram")
vim.opt.exrc = true

-- misc, no category really
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv") -- has to be :m
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv") -- has to be :m
vim.keymap.set("n", "gp", "`[v`]")
vim.keymap.set("n", "yc", "yy<cmd>normal gcc<cr>p")
-- resize windows more
for _, v in ipairs({ "+", "-", "<", ">" }) do
    local m = "<c-w>" .. v
    vim.keymap.set("n", m, "10" .. m)
end
vim.keymap.set("n", "<c-k>", "<cmd>b#<cr>") -- quick switch alternate buffer

-- defaults with zz
vim.keymap.set("n", "<c-d>", "<c-d>zz")
vim.keymap.set("n", "<c-u>", "<c-u>zz")

-- case sensitive * / # normal mode commands
vim.keymap.set("n", "*", [[<cmd>let @/='\C\<' . expand("<cword>") . '\>'<cr><cmd>let v:searchforward=1<cr>n]])
vim.keymap.set("n", "#", [[<cmd>let @/='\C\<' . expand("<cword>") . '\>'<cr><cmd>let v:searchforward=0<cr>n]])

-- simple user commands

vim.api.nvim_create_user_command("RemoveTrailing", [[%s/\s\+$//e | nohlsearch]], {})

vim.api.nvim_create_user_command("BreakChar", function(ev)
    local prefix = string.format("%d,%d", ev.line1, ev.line2)
    vim.cmd(prefix .. [[s/]] .. ev.fargs[1] .. [[/]] .. ev.fargs[1] .. [[\r/ge]])
    vim.cmd("noh")
end, {
    range = true,
    nargs = 1,
})

vim.api.nvim_create_user_command("FoldNewlines", function(ev)
    local prefix = string.format("%d,%d", ev.line1, ev.line2)
    if ev.bang then
        vim.cmd(prefix .. [[g!/\S\+.*$/normal! dd]])
    else
        vim.cmd(prefix .. [[s/\(\S\+.*$\)\(\n\s*$\)\{2,}/\1\r/e]])
    end
    vim.cmd("noh")
end, { range = true, bang = true })

-- autocmds

-- highlights yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 80,
        })
    end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.api.nvim_buf_call(args.buf, function()
                vim.cmd('normal! g`"zz')
            end)
        end
    end,
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    command = "wincmd =",
})

-- custom filetypes

vim.filetype.add({
    pattern = {
        [".*/hypr/.*%.conf"] = "hyprlang",
        [".*%.gitconfig"] = "gitconfig",
        ["Dockerfile.*"] = "dockerfile",
        ["%.env%..*"] = "sh",
    },
    extension = {
        avsc = "json",
        avdl = "avro-idl",
        sd = "sd",
        yql = "yql",
    },
})

-- tree sitter highlighting has priority over semantic tokens
if vim.hl.priorities.semantic_tokens > vim.hl.priorities.treesitter then
    vim.hl.priorities.semantic_tokens, vim.hl.priorities.treesitter =
        vim.hl.priorities.treesitter, vim.hl.priorities.semantic_tokens
end

-- per-project shadafile
vim.opt.shadafile = (function()
    local state = vim.fn.stdpath("state")

    local cwd = vim.fn.getcwd()
    cwd = vim.fs.root(cwd, ".git") or cwd

    local shadafile = vim.uri_encode(cwd, "rfc2396")

    local file = vim.fs.joinpath(state, "project_shada", shadafile)
    vim.fn.mkdir(vim.fs.dirname(file), "p")

    return file
end)()

vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.completeopt = "menu,popup,fuzzy,longest"

vim.opt.tagcase = "followscs"

-- unset the default lsp tagfunc config
vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function(ev)
        vim.bo[ev.buf].tagfunc = ""
    end,
})

-- yankring
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        if vim.v.event.operator == "y" then
            for i = 9, 1, -1 do -- Shift all numbered registers.
                vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
            end
        end
    end,
})

-- folding
vim.opt.foldcolumn = "0"
vim.opt.foldlevelstart = 99
