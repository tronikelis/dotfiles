local augroup = vim.api.nvim_create_augroup("plugin/_pack_nvim-metals.lua", {})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "scala", "sbt" },
    callback = function()
        if not _G.__nvim_metals_config then
            _G.__nvim_metals_config = require("metals").bare_config()
            local config = _G.__nvim_metals_config

            config.settings.enableSemanticHighlighting = false
            config.init_options.statusBarProvider = "off"
        end
        require("metals").initialize_or_attach(_G.__nvim_metals_config)
    end,
})
