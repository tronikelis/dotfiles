local utils = require("utils")

local M = {}

function M.setup()
    -- interferes with <C-c> to exit insert mode
    vim.g.omni_sql_no_default_maps = true
    -- this opens a split by default, what
    vim.g.zig_fmt_parse_errors = 0

    vim.opt.wrap = false

    vim.opt.tabstop = 4
    vim.opt.expandtab = true
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4

    -- To disable jumping
    vim.opt.signcolumn = "yes"
    vim.opt.pumheight = 10 -- pop up menu height
    vim.opt.relativenumber = true
    vim.opt.number = true
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.opt.clipboard = "unnamedplus"
    vim.opt.breakindent = true
    vim.opt.undofile = true
    vim.opt.updatetime = 100
    vim.opt.inccommand = "split"
    vim.opt.cursorline = true
    vim.opt.ignorecase = true
    vim.opt.smartcase = true
    vim.opt.scrolloff = 10
    vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,a:blinkwait1000-blinkoff500-blinkon500"

    if vim.fn.executable("rg") == 1 then
        -- the default is rg -uu --vimgrep, but -uu ignores .gitignore and shows hidden files
        vim.opt.grepprg = "rg --vimgrep -S"
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

    -- resize windows more
    for _, v in ipairs({ "+", "-", "<", ">" }) do
        local m = "<c-w>" .. v
        vim.keymap.set("n", m, "10" .. m)
    end

    vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
    vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
    vim.keymap.set("n", "<C-d>", "<C-d>zz")
    vim.keymap.set("n", "<C-u>", "<C-u>zz")
    vim.keymap.set("n", "n", "nzzzv")
    vim.keymap.set("n", "N", "Nzzzv")
    vim.keymap.set("n", "n", "nzzzv")
    vim.keymap.set("n", "N", "Nzzzv")
    vim.keymap.set("x", "<leader>p", [["_dP]])
    vim.keymap.set("n", "}", "}zz")
    vim.keymap.set("n", "{", "{zz")
    vim.keymap.set("n", "]c", "]czz")
    vim.keymap.set("n", "[c", "[czz")

    vim.keymap.set("n", "yc", "yy<cmd>normal gcc<cr>p")
    vim.keymap.set("n", "<leader><tab>", "<cmd>b#<cr>")

    -- quickfix list nav
    vim.keymap.set("n", "]q", utils.with_count("cnext<cr>zz"), { expr = true })
    vim.keymap.set("n", "[q", utils.with_count("cprev<cr>zz"), { expr = true })
    vim.keymap.set("n", "]Q", "<cmd>clast<cr>zz")
    vim.keymap.set("n", "[Q", "<cmd>cfirst<cr>zz")

    -- terminal mode
    vim.keymap.set("t", "<esc>", "<c-\\><c-n>")

    -- autocmds

    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = "*",
        callback = function()
            local save_cursor = vim.fn.getpos(".")
            vim.cmd([[%s/\s\+$//e]])
            vim.fn.setpos(".", save_cursor)
        end,
    })

    vim.api.nvim_create_autocmd("TextYankPost", {
        pattern = "*",
        callback = function()
            vim.highlight.on_yank({
                higroup = "IncSearch",
                timeout = 40,
            })
        end,
    })

    -- folding
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt.foldtext = ""
    vim.opt.foldcolumn = "0"
    vim.opt.foldlevelstart = 99

    -- custom filetypes

    vim.filetype.add({
        pattern = {
            [".*/hypr/.*%.conf"] = "hyprlang",
            ["docker%-compose.-%.ya?ml"] = "yaml.docker-compose",
            [".*%.gitconfig"] = "gitconfig",
            ["Dockerfile.*"] = "dockerfile",
        },
    })

    -- tree sitter

    vim.treesitter.language.register("bash", "zsh")

    -- tree sitter highlighting has priority over semantic tokens
    vim.highlight.priorities.semantic_tokens = 95

    vim.opt.shadafile = (function()
        local data = vim.fn.stdpath("data")

        local cwd = vim.fn.getcwd()
        cwd = vim.fs.root(cwd, ".git") or cwd

        local cwd_b64 = vim.base64.encode(cwd)

        local file = vim.fs.joinpath(data, "project_shada", cwd_b64)
        vim.fn.mkdir(vim.fs.dirname(file), "p")

        return file
    end)()
end

return M
