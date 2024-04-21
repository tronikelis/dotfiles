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

-- spelling
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"
vim.opt.spell = false -- im using typos-lsp

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("x", "<leader>p", [["_dP]])

-- quickfix list nav
vim.keymap.set("n", "]q", "<cmd>cnext<cr>zz")
vim.keymap.set("n", "[q", "<cmd>cprev<cr>zz")

vim.diagnostic.config({
	update_in_insert = true,
})

local yank_group = vim.api.nvim_create_augroup("HighlightYank", {})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})
