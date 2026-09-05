---@param path string
---@return boolean
local function check_is_neovim_project(path)
    local result = vim.system(
        { "grep", "-IRq", "-e", "vim\\.fn", "-e", "vim\\.api", "-e", "vim\\.cmd" },
        { text = true, cwd = path }
    ):wait(1000)
    return result.code == 0
end

---@param client vim.lsp.Client
---@param path string
local function set_neovim_project_options(client, path)
    local library = {
        vim.env.VIMRUNTIME,
        -- For LSP Settings Type Annotations: https://github.com/neovim/nvim-lspconfig#lsp-settings-type-annotations
        vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
    }

    if vim.fn.resolve(path) == vim.fn.resolve(vim.fn.stdpath("config")) then
        table.insert(library, vim.fs.joinpath(vim.fn.stdpath("data"), "site/pack/core/opt"))
    end

    -- credits to https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
        runtime = {
            version = "LuaJIT",
            -- Tell the language server how to find Lua modules same way as Neovim
            -- (see `:h lua-module-load`)
            path = {
                "lua/?.lua",
                "lua/?/init.lua",
            },
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
            checkThirdParty = false,
            library = library,
            -- Or pull in all of 'runtimepath'.
            -- NOTE: this is a lot slower and will cause issues when working on
            -- your own configuration.
            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
            -- library = vim.api.nvim_get_runtime_file('', true),
        },
    })
end

---@type vim.lsp.Config
return {
    on_init = function(client)
        local project_path = vim.fn.getcwd()
        if client.workspace_folders and #client.workspace_folders > 0 then
            project_path = client.workspace_folders[1].name
        end

        if
            vim.uv.fs_stat(vim.fs.joinpath(project_path, ".luarc.json"))
            or vim.uv.fs_stat(vim.fs.joinpath(project_path, ".luarc.jsonc"))
        then
            return
        end

        if check_is_neovim_project(project_path) then
            set_neovim_project_options(client, project_path)
        end
    end,
}
