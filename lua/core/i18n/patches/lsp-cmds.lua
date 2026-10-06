-- =====================================================================
--  LSP 相关命令说明汉化
-- =====================================================================
--  来源：nvim-lspconfig 的 plugin/lspconfig.lua、mason.nvim 与
--        mason-lspconfig.nvim 的 api/command.lua
--  这些 desc 在 `:help :LspStart`、命令补全（按 Tab）和 `:command` 里可见。
--  注：mason 的 `:Mason` / `:MasonInstall` 等命令名本身不译（是命令语法）。
-- =====================================================================

return {
  rules = {
    {
      path = "nvim-lspconfig/plugin/lspconfig.lua",
      note = "lspconfig 命令说明（5 条）",
      replacements = {
        { [[{ desc = 'Alias to `:checkhealth vim.lsp`' }]], [[{ desc = '`:checkhealth vim.lsp` 的别名' }]] },
        { [[desc = 'Opens the Nvim LSP client log.']], [[desc = '打开 Nvim LSP 客户端日志' ]] },
        { [[desc = 'Enable and launch a language server']], [[desc = '启用并启动语言服务器']] },
        { [[desc = 'Restart the given client']], [[desc = '重启指定的语言服务器']] },
        { [[desc = 'Disable and stop the given client']], [[desc = '停用并停止指定的语言服务器']] },
        { [[desc = 'Manually launches a language server']], [[desc = '手动启动语言服务器']] },
        { [[desc = 'Manually restart the given language client(s)']], [[desc = '手动重启指定的语言服务器']] },
        { [[desc = 'Manually stops the given language client(s)']], [[desc = '手动停止指定的语言服务器']] },
      },
    },
    {
      path = "mason.nvim/lua/mason/api/command.lua",
      note = "mason 命令说明（6 条）",
      replacements = {
        { [[desc = "Opens mason's UI window."]], [[desc = "打开 mason 主界面"]] },
        { [[desc = "Install one or more packages."]], [[desc = "安装一个或多个包"]] },
        { [[desc = "Uninstall one or more packages."]], [[desc = "卸载一个或多个包"]] },
        { [[desc = "Uninstall all packages."]], [[desc = "卸载全部已安装的包"]] },
        { [[desc = "Update Mason registries."]], [[desc = "更新 Mason 软件源"]] },
        { [[desc = "Opens the mason.nvim log."]], [[desc = "打开 mason.nvim 日志"]] },
      },
    },
    {
      path = "mason-lspconfig.nvim/lua/mason-lspconfig/api/command.lua",
      note = "mason-lspconfig 命令说明（2 条）",
      replacements = {
        { [[desc = "Install one or more LSP servers."]], [[desc = "安装一个或多个 LSP 服务器"]] },
        { [[desc = "Uninstall one or more LSP servers."]], [[desc = "卸载一个或多个 LSP 服务器"]] },
      },
    },
    {
      path = "mason.nvim/lua/mason/ui/instance.lua",
      note = "mason 筛选时选择语言提示（1 条）",
      replacements = {
        { [[prompt = "Select language:"]], [[prompt = "选择语言："]] },
      },
    },
  },
}
