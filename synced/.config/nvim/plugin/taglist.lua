local fzf_lua = require("fzf-lua")
local builtin = require("fzf-lua.previewer.builtin")
local ansi_codes = fzf_lua.utils.ansi_codes

local entry_matcher = "^.* .\t(.*)\t(.*)$"

local CtagsPreviewer = builtin.tags:extend()

function CtagsPreviewer:new(o, opts, fzf_win)
    CtagsPreviewer.super.new(self, o, opts, fzf_win)
    setmetatable(self, CtagsPreviewer)
    return self
end

function CtagsPreviewer:parse_entry(entry_str)
    local filename, excmd = entry_str:match(entry_matcher)

    return {
        path = filename,
        ctag = excmd:sub(2, -2),
    }
end

local function goto_match(entry_str)
    local filename, excmd = entry_str:match(entry_matcher)
    vim.cmd.e(filename)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.fn.search(excmd:sub(2, -2), "W")
end

vim.api.nvim_create_user_command("Taglist", function(ev)
    if vim.bo.buftype ~= "" then
        print("Taglist requires normal buffer")
        return
    end

    local keyword = ev.fargs[1]
    local matches = vim.fn.taglist(string.format("^%s$", vim.fn.escape(keyword, "^$")), vim.fn.expand("%:p"))

    local rows = {}
    for _, v in ipairs(matches) do
        table.insert(
            rows,
            string.format(
                "%s %s\t%s\t%s",
                ansi_codes.magenta(v.name),
                ansi_codes.yellow(v.kind),
                vim.fn.fnamemodify(v.filename, ":~:."),
                ansi_codes.grey(v.cmd)
            )
        )
    end

    fzf_lua.fzf_exec(rows, {
        prompt = string.format("%s> ", keyword),
        previewer = CtagsPreviewer,
        winopts = {
            title = "Taglist",
        },
        actions = {
            default = function(item)
                goto_match(item[1])
            end,
            ["ctrl-s"] = function(item)
                vim.cmd("new")
                goto_match(item[1])
            end,
            ["ctrl-v"] = function(item)
                vim.cmd("vertical new")
                goto_match(item[1])
            end,
        },
    })
end, {
    nargs = 1,
})
