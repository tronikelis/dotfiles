local augroup = vim.api.nvim_create_augroup("plugin/_pack_nvim-metals.lua", {})

local config

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "scala", "sbt" },
    callback = function()
        if not config then
            config = require("metals").bare_config()
            config.settings.enableSemanticHighlighting = false
            config.init_options.statusBarProvider = "off"
        end
        require("metals").initialize_or_attach(config)
    end,
})
