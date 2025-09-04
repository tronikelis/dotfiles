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
vim.opt.updatetime = 1000
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

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.smartindent = true
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

-- misc, no category really
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv") -- has to be :m
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv") -- has to be :m
vim.keymap.set("v", "<leader>p", [["_dP]])
vim.keymap.set("n", "gp", "`[v`]")
vim.keymap.set("n", "yc", "yy<cmd>normal gcc<cr>p")
vim.keymap.set("t", "<esc>", "<c-\\><c-n>")
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

-- autocmds

-- highlights yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 80,
        })
    end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
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
    command = "wincmd =",
})

-- custom filetypes

vim.filetype.add({
    pattern = {
        [".*/hypr/.*%.conf"] = "hyprlang",
        [".*%.gitconfig"] = "gitconfig",
        ["Dockerfile.*"] = "dockerfile",
    },
})

-- tree sitter

vim.treesitter.language.register("bash", "zsh")

-- tree sitter highlighting has priority over semantic tokens
vim.hl.priorities.semantic_tokens, vim.hl.priorities.treesitter =
    vim.hl.priorities.treesitter, vim.hl.priorities.semantic_tokens

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
