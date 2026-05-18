local augroup = vim.api.nvim_create_augroup("plugin/_pack_lazydev.lua", {})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "lua",
    callback = function()
        if not vim.g.did_lazydev then
            require("lazydev").setup({
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            })
        end
        vim.g.did_lazydev = true
    end,
})
