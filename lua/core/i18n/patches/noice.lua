-- =====================================================================
--  noice.nvim / nvim-notify 界面汉化
-- =====================================================================
--  noice：LSP 悬浮窗（hover / 签名帮助）在无内容时给出的提示
--  nvim-notify：通知历史的 telescope 列表标题
--  注：nvim-notify 的窗口默认标题由调用方传入，插件内无固定标题文案。
-- =====================================================================

return {
  rules = {
    {
      path = "noice.nvim/lua/noice/lsp/hover.lua",
      note = "noice 悬浮文档无内容提示（2 条）",
      replacements = {
        { [[vim.notify("No information available")]], [[vim.notify("没有可显示的信息")]] },
      },
    },
    {
      path = "noice.nvim/lua/noice/lsp/signature.lua",
      note = "noice 签名帮助无内容提示（2 条）",
      replacements = {
        { [[vim.notify("No signature help available")]], [[vim.notify("没有可用的签名帮助")]] },
      },
    },
    {
      path = "nvim-notify/lua/telescope/_extensions/notify.lua",
      note = "通知历史列表标题（2 条）",
      replacements = {
        { [[results_title = "Notifications"]], [[results_title = "通知"]] },
        { [[prompt_title = "Filter Notifications"]], [[prompt_title = "筛选通知"]] },
      },
    },
  },
}
