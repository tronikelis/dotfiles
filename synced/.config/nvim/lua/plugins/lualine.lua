return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "Tronikelis/lualine-components.nvim",
    },
    config = function()
        local filename_oil = require("lualine-components.filename-oil")
        local linecount = require("lualine-components.linecount")
        local git_prompt = require("lualine-components.git-prompt")
        local active_lsp = require("lualine-components.active-lsp")

        local grapple = function()
            if not package.loaded.grapple then
                return
            end

            return require("grapple").statusline()
        end

        local formatter_status = function()
            if not package.loaded.conform then
                return
            end

            local conform = require("conform")

            local available = "󰏫"
            local not_available = "󰏯"

            local formatters, lsp = conform.list_formatters_to_run()

            if not lsp and #formatters == 0 then
                return not_available
            end

            if vim.g.disable_autoformat or vim.b.disable_autoformat then
                return not_available
            end

            return available
        end

        require("lualine").setup({
            options = {
                component_separators = {
                    left = "|",
                    right = "|",
                },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        ---@param str string
                        fmt = function(str)
                            return str:sub(1, 1)
                        end,
                    },
                },
                lualine_b = {
                    "branch",
                    git_prompt,
                    "diff",
                    {
                        "diagnostics",
                        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
                    },
                },
                lualine_c = { "filename", grapple },

                lualine_x = {
                    "encoding",
                    "fileformat",
                    {
                        active_lsp,
                        exclude = { "typos_lsp" },
                    },
                    "filetype",
                },
                lualine_y = {
                    formatter_status,
                    linecount,
                },
                lualine_z = { "location" },
            },
            tabline = {
                lualine_b = {
                    {
                        filename_oil,
                        path = 1,
                    },
                },
                lualine_a = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {
                    {
                        "datetime",
                        style = "%H:%M",
                    },
                },
                lualine_z = {
                    {
                        "datetime",
                        style = "%d/%m/%Y",
                    },
                },
            },
        })
    end,
}
