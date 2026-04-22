require("guess-indent").setup({
    on_tab_options = {
        ["expandtab"] = false,
    },
    on_space_options = {
        ["expandtab"] = true,
        ["shiftwidth"] = "detected",
    },
})
