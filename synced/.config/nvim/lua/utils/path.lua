local M = {}

M.files = function(path, opts)
    opts = opts or {}
    opts = vim.tbl_deep_extend("keep", opts, { full = false })

    local iter = vim.fs.dir(path, opts)

    local files = {}

    for item, t in iter do
        if t == "file" then
            if opts.full then
                item = vim.fs.joinpath(path, item)
            end

            table.insert(files, item)
        end
    end

    return files
end

M.curr_full_file = function()
    return vim.fn.expand("%:p")
end

M.curr_full_dir = function()
    return vim.fn.expand("%:p:h")
end

return M
