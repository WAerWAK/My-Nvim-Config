-- =====================================================================
--  gitsigns.nvim 界面汉化
-- =====================================================================
--  覆盖：行内 Git 操作的提示消息（暂存/重置/跳转代码块）与诊断标签说明
--  这些提示走 nvim_echo / vim.notify，会被 noice 接管显示在命令行区域
-- =====================================================================

return {
  rules = {
    {
      path = "gitsigns.nvim/lua/gitsigns/actions.lua",
      note = "gitsigns 操作提示（5 条）",
      replacements = {
        { [['No unstaged changes in the buffer to reset']], [['缓冲区中没有未暂存的改动可重置']] },
        { [['No hunk to stage']], [['没有可暂存的代码块']] },
        { [['No hunk to reset']], [['没有可重置的代码块']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/actions/nav.lua",
      note = "gitsigns 跳转提示（3 条）",
      replacements = {
        { [['No more hunks']], [['没有更多代码块了']] },
        { [['No hunks']], [['没有代码块']] },
        { [[('Hunk %d of %d')]], [[('第 %d / %d 个代码块')]] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/actions/diffthis.lua",
      note = "gitsigns 对比失败提示（1 条）",
      replacements = {
        { [['Failed to run diff']], [['执行 diff 失败']] },
      },
    },
  },
}
