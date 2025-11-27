---@type vim.lsp.Config
return {
    cmd_env = {
        JAVA_HOME = vim.env.JDTLS_JAVA_HOME or vim.env.JAVA_HOME,
    },
}
