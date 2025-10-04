vim.opt_local.commentstring = "# %s"
vim.treesitter.language.register("asm", "asmh")
vim.keymap.set("i", "#", "X#", { buffer = 0 })
