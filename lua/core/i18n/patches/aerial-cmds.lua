-- =====================================================================
--  aerial.nvim 命令与键位说明汉化
-- =====================================================================
--  init.lua：`:AerialOpen` / `:AerialToggle` 等命令的 desc
--  nav_actions.lua：浮动导航窗里 g? 的操作说明
--  注：autocommands.lua / window.lua 里的 "Aerial xxx" 是内部 autocmd 描述，
--      只在 `:autocmd` 输出与调试时可见，不属于常规界面，保留英文。
-- =====================================================================

return {
  rules = {
    {
      path = "aerial.nvim/lua/aerial/init.lua",
      note = "aerial 命令说明（15 条）",
      replacements = {
        { [[desc = "Open or close the aerial window. With `!` cursor stays in current window"]], [[desc = "打开或关闭大纲窗口（加 ! 时焦点留在当前窗口）"]] },
        { [[desc = "Open the aerial window. With `!` cursor stays in current window"]], [[desc = "打开大纲窗口（加 ! 时焦点留在当前窗口）"]] },
        { [[desc = "Open an aerial window for each visible window."]], [[desc = "为每个可见窗口打开一个大纲窗口"]] },
        { [[desc = "Close the aerial window."]], [[desc = "关闭大纲窗口"]] },
        { [[desc = "Close all visible aerial windows."]], [[desc = "关闭所有可见的大纲窗口"]] },
        { [[desc = "Jump forwards {count} symbols (default 1)."]], [[desc = "向后跳 {count} 个符号（默认 1）"]] },
        { [[desc = "Jump backwards [count] symbols (default 1)."]], [[desc = "向前跳 [count] 个符号（默认 1）"]] },
        { [[desc = "Jump to the [count] symbol (default 1)."]], [[desc = "跳到第 [count] 个符号（默认 1）"]] },
        { [[desc = "Print out debug info related to aerial."]], [[desc = "输出 aerial 的调试信息"]] },
        { [[desc = "Open the aerial nav window."]], [[desc = "打开大纲导航窗"]] },
        { [[desc = "Close the aerial nav window."]], [[desc = "关闭大纲导航窗"]] },
        { [[desc = "Open or close the aerial nav window."]], [[desc = "打开或关闭大纲导航窗"]] },
      },
    },
    {
      path = "aerial.nvim/lua/aerial/nav_actions.lua",
      note = "aerial 导航窗操作说明（7 条）",
      replacements = {
        { [[desc = "Jump to the symbol under the cursor"]], [[desc = "跳转到光标处的符号"]] },
        { [[desc = "Jump to the symbol in a vertical split"]], [[desc = "在垂直分屏中打开该符号"]] },
        { [[desc = "Jump to the symbol in a horizontal split"]], [[desc = "在水平分屏中打开该符号"]] },
        { [[desc = "Navigate to parent symbol"]], [[desc = "跳到父级符号"]] },
        { [[desc = "Navigate to child symbol"]], [[desc = "跳到子级符号"]] },
        { [[desc = "Close the nav windows"]], [[desc = "关闭导航窗"]] },
      },
    },
    {
      -- aerial 提供的 telescope 扩展（:Telescope aerial）
      path = "aerial.nvim/lua/telescope/_extensions/aerial.lua",
      note = "aerial 的 telescope 扩展标题（1 条）",
      replacements = {
        { [[title = "Document Symbols"]], [[title = "文档符号"]] },
      },
    },
  },
}
