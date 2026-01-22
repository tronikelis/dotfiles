vim.opt_local.commentstring = "# %s"
vim.treesitter.language.register("asm", "asmh")
vim.keymap.set("i", "#", "X#", { buffer = 0 })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "\n setl commentstring<" .. "\n iunmap <buffer> #"
