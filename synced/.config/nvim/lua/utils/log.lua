local M = {}

M.info = function(arg)
    print("I: " .. arg)
end

M.err = function(arg)
    print("E: " .. arg)
end

M.warn = function(arg)
    print("W: " .. arg)
end

return M
