local guess_indent = require("guess-indent")
guess_indent.setup({
    on_tab_options = {
        ["expandtab"] = false,
    },
    on_space_options = {
        ["expandtab"] = true,
        ["shiftwidth"] = "detected",
    },
})

vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function(args)
        guess_indent.set_from_buffer(args.buf, true, true)
    end,
})
