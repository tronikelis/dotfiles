return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "tronikelis/lualine-components.nvim",
    },
    config = function()
        local filename_oil = require("lualine-components.filename-oil")
        local linecount = require("lualine-components.linecount")
        local git_prompt = require("lualine-components.git-prompt")
        local active_lsp = require("lualine-components.active-lsp")

        local formatter_status = {
            function()
                local conform = require("conform")

                local ok = "󰏫"
                local not_ok = "󰏯"

                local formatters, lsp = conform.list_formatters_to_run()

                if not lsp and #formatters == 0 then
                    return not_ok
                end

                if vim.g.disable_autoformat or vim.b.disable_autoformat then
                    return not_ok
                end

                local fmts = vim.iter(formatters)
                    :map(function(x)
                        return x.name
                    end)
                    :totable()

                ---@type string[]
                local str = { ok, unpack(fmts) }

                if lsp then
                    table.insert(str, "[LSP]")
                end

                return table.concat(str, " ")
            end,
            cond = function()
                return not not package.loaded.conform
            end,
        }

        require("lualine").setup({
            options = {
                component_separators = {
                    left = "",
                    right = "",
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
                    {
                        "diagnostics",
                        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
                    },
                },
                lualine_c = { "filename" },

                lualine_x = {
                    formatter_status,
                    {
                        active_lsp,
                        exclude = {
                            "typos_lsp",
                            "null-ls",
                            -- it will show gopls
                            "golangci_lint_ls",
                        },
                    },
                    "filetype",
                },
                lualine_y = {
                    {
                        linecount,
                        fmt = function(str)
                            return ":" .. str
                        end,
                    },
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
                lualine_y = {},
                lualine_z = {},
            },
        })
    end,
}
