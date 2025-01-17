local M = {}

function M.setup()
    require("user_commands.edit_relative").setup()
    require("user_commands.sudo_write").setup()
    require("user_commands.yank_path").setup()
    require("user_commands.messages").setup()
    require("user_commands.scratchpad").setup()
end

return M
