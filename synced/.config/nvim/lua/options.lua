local M = {}

---@param buf? integer
---@return boolean
function M.is_autoformat_enabled(buf)
    local g = vim.g.is_autoformat_disabled
    if not buf then
        return not g
    end

    local b = vim.b[buf].is_autoformat_disabled
    if b ~= nil then
        return not b
    end

    return not g
end

---@param buf integer?
---@param value boolean
function M.set_autoformat_enabled(buf, value)
    if buf then
        vim.b[buf].is_autoformat_disabled = not value
    else
        vim.g.is_autoformat_disabled = not value
    end
end

---@param buf? integer
function M.reset_autoformat_enabled(buf)
    if buf then
        vim.b[buf].is_autoformat_disabled = nil
    else
        vim.g.is_autoformat_disabled = nil
    end
end

return M
