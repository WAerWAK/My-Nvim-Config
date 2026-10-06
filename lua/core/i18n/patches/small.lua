-- =====================================================================
--  少数官方配置项无法覆盖的界面文本（补丁方式）
-- =====================================================================
--  toggleterm：`<A-p>` 映射说明与"尚未打开终端"提示
--  render-markdown：命令帮助描述
--  nvim-notify：telescope 扩展列表标题
--  noice：LSP 悬浮窗/签名帮助的空内容提示
--  注：rainbow-delimiters 的文本全部在 :checkhealth 里，暂不处理。
-- =====================================================================

return {
  rules = {
    {
      path = "toggleterm.nvim/lua/toggleterm.lua",
      note = "终端开关说明与提示（3 条）",
      replacements = {
        { [[utils.notify("No toggleterms are open yet", "info")]], [[utils.notify("还没有打开任何终端", "info")]] },
        { [[utils.notify("No toggleterms are open yet")]], [[utils.notify("还没有打开任何终端")]] },
        { [[desc = "Toggle Terminal"]], [[desc = "开关浮动终端"]] },
      },
    },
    {
      path = "render-markdown.nvim/lua/render-markdown/core/command.lua",
      note = "Markdown 渲染命令描述（1 条）",
      replacements = {
        { [[desc = plugin .. ' commands']], [[desc = plugin .. ' 命令']] },
      },
    },
    {
      path = "noice.nvim/lua/noice/lsp/hover.lua",
      note = "noice 悬浮文档无内容提示（1 条）",
      replacements = {
        { [[vim.notify("No information available")]], [[vim.notify("没有可显示的信息")]] },
      },
    },
    {
      path = "noice.nvim/lua/noice/lsp/signature.lua",
      note = "noice 签名帮助无内容提示（1 条）",
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
