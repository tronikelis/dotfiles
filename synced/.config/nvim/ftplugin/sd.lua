vim.opt_local.commentstring = "# %s"
vim.keymap.set("i", "#", "X#", { buffer = 0 })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "\n setl commentstring<" .. "\n iunmap <buffer> #"
