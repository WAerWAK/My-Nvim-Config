-- =====================================================================
--  telescope.nvim 界面汉化
-- =====================================================================
--  说明：各 picker 的搜索框标题是**官方配置项**（pickers.*.prompt_title），
--        已在 lua/plugins/telescope.lua 中覆盖，不需要改源码。
--        这里只处理写死在源码里的预览窗标题。
-- =====================================================================

return {
  rules = {
    {
      path = "telescope.nvim/lua/telescope/previewers/buffer_previewer.lua",
      note = "telescope 预览窗口标题（1 条）",
      replacements = {
        { [[title = "File Preview"]], [[title = "文件预览"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/previewers/term_previewer.lua",
      note = "telescope 终端预览窗口标题（1 条）",
      replacements = {
        { [[title = "File Preview"]], [[title = "文件预览"]] },
      },
    },
  },
}
