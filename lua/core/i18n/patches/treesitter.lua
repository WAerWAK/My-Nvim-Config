-- =====================================================================
--  nvim-treesitter 命令说明汉化
-- =====================================================================
--  `:TSInstall` / `:TSUpdate` / `:TSUninstall` / `:TSLog` 的 desc，
--  在命令补全和 `:help :TSInstall` 里可见。
--  注：nvim-treesitter 的 main 分支已把语法高亮改为 `vim.treesitter.start()`
--      驱动，插件本身没有别的界面文本。
-- =====================================================================

return {
  rules = {
    {
      path = "nvim-treesitter/plugin/nvim-treesitter.lua",
      note = "treesitter 命令说明（5 条）",
      replacements = {
        { [[desc = 'Install treesitter parsers from grammar']], [[desc = '从语法定义安装 treesitter 解析器']] },
        { [[desc = 'Install treesitter parsers']], [[desc = '安装 treesitter 解析器（语法高亮）']] },
        { [[desc = 'Update installed treesitter parsers']], [[desc = '更新已安装的 treesitter 解析器']] },
        { [[desc = 'Uninstall treesitter parsers']], [[desc = '卸载 treesitter 解析器']] },
        { [[desc = 'View log messages']], [[desc = '查看 treesitter 日志']] },
      },
    },
  },
}
