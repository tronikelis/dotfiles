local augroup = vim.api.nvim_create_augroup("plugin/_pack_nvim-metals.lua", {})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "scala", "sbt" },
    callback = function()
        local metals_config = require("metals").bare_config()
        metals_config.settings = vim.tbl_deep_extend("force", metals_config.settings, {
            enableSemanticHighlighting = false,
        })
        require("metals").initialize_or_attach(metals_config)
    end,
})
