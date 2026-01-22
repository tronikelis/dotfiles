vim.wo[0][0].wrap = true
vim.wo[0][0].linebreak = true

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. "\n setl wrap< linebreak<"
