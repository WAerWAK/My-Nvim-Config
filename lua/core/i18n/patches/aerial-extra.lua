-- =====================================================================
--  aerial.nvim 内部 autocmd 描述汉化
-- =====================================================================
--  这些 desc 会显示在 `:autocmd Aerial*` 的输出里。对普通使用影响很小，
--  但为了"完整汉化"一并处理。
-- =====================================================================

return {
  rules = {
    {
      path = "aerial.nvim/lua/aerial/autocommands.lua",
      note = "aerial autocmd 描述（2 条）",
      replacements = {
        { [[desc = "Aerial update highlights in window when cursor moves"]], [[desc = "光标移动时更新窗口高亮"]] },
        { [[desc = "Aerial clean up stored data"]], [[desc = "清理缓存的数据"]] },
      },
    },
    {
      path = "aerial.nvim/lua/aerial/backends/util.lua",
      note = "aerial autocmd 描述（1 条）",
      replacements = {
        { [[desc = "Aerial update symbols"]], [[desc = "更新符号列表"]] },
      },
    },
    {
      path = "aerial.nvim/lua/aerial/fold.lua",
      note = "aerial autocmd 描述（1 条）",
      replacements = {
        { [[desc = "Aerial update tree folds based on foldlevel"]], [[desc = "按折叠层级同步大纲折叠"]] },
      },
    },
    {
      path = "aerial.nvim/lua/aerial/nav_view.lua",
      note = "aerial 导航窗 autocmd 描述（4 条）",
      replacements = {
        { [[desc = "Close Aerial nav window on leave"]], [[desc = "离开时关闭大纲导航窗"]] },
        { [[desc = "Update symbols on cursor move"]], [[desc = "光标移动时更新符号"]] },
        { [[desc = "Update aerial nav view"]], [[desc = "更新大纲导航窗"]] },
      },
    },
    {
      path = "aerial.nvim/lua/aerial/window.lua",
      note = "aerial 窗口 autocmd 描述（5 条）",
      replacements = {
        { [[desc = "Aerial update highlights in the source buffer"]], [[desc = "更新源缓冲区里的高亮"]] },
        { [[desc = "Aerial clear highlights in the source buffer"]], [[desc = "清除源缓冲区里的高亮"]] },
        { [[desc = "Aerial render symbols after buffer loads in window"]], [[desc = "缓冲区载入窗口后渲染符号"]] },
        { [[desc = "After entering aerial win, add hook to close it when leaving"]], [[desc = "进入大纲窗口后，注册离开时自动关闭"]] },
        { [[desc = "Close aerial floating win when leaving"]], [[desc = "离开时关闭大纲浮窗"]] },
      },
    },
  },
}
