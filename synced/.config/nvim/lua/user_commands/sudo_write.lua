local utils = require("utils")

local M = {}

function M.setup()
    local function get_password()
        vim.fn.inputsave()
        local password = vim.fn.inputsecret("Password: ")
        vim.fn.inputrestore()

        return password
    end

    local function sudo_exec(cmd, password)
        if not password or #password == 0 then
            print("invalid password, sudo aborted")
            return false
        end

        local out = vim.system(utils.flatten({ "sudo", "-S", cmd }), { text = true, stdin = password }):wait()

        if out.code ~= 0 then
            print(out.stderr)
            return false
        end

        -- clears the `Password: ****` in cmd
        vim.cmd("stopinsert")

        return true
    end

    local function sudo_write()
        local tmp_file = vim.fn.tempname()
        local curr_file = vim.fn.expand("%:p")

        local password = get_password()

        vim.cmd({ cmd = "w", bang = true, args = { tmp_file } })

        if not sudo_exec({ "cp", tmp_file, curr_file }, password) then
            return
        end

        vim.fn.delete(tmp_file)
        vim.cmd("e!")
    end

    vim.api.nvim_create_user_command("SudoWrite", sudo_write, { desc = "Writes to current file with 'sudo'" })
end

return M
