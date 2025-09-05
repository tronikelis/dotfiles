local M = {}

---@param str string
---@param startsWith string
---@return boolean
function M.string_starts_with(str, startsWith)
    return str:sub(1, #startsWith) == startsWith
end

---@param query string
---@param list table
---@return table
function M.prefix_filter(query, list)
    if not query or query == "" then
        return list
    end

    return vim.iter(list)
        :filter(function(x)
            return M.string_starts_with(x, query)
        end)
        :totable()
end

function M.flatten(tbl)
    return vim.iter(tbl):flatten():totable()
end

---@param path string
function M.read_file(path, callback)
    callback = vim.schedule_wrap(callback)

    local function callback_err(fd, err)
        pcall(vim.uv.fs_close, fd)
        callback(nil, err)
    end

    vim.uv.fs_open(path, "r", 438, function(err, fd)
        if err ~= nil then
            callback_err(fd, err)
            return
        end

        vim.uv.fs_fstat(fd, function(err, stat)
            if err ~= nil then
                callback_err(fd, err)
                return
            end

            vim.uv.fs_read(fd, stat.size, 0, function(err, data)
                if err ~= nil then
                    callback_err(fd, err)
                    return
                end

                vim.uv.fs_close(fd, function(err)
                    if err ~= nil then
                        callback_err(fd, err)
                        return
                    end

                    callback(data)
                end)
            end)
        end)
    end)
end

return M
