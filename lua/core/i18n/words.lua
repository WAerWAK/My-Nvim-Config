-- =====================================================================
--  统一词汇表
-- =====================================================================
--  界面用词集中在这里，便于统一改词；其它模块用 require("core.i18n.words") 取用。
-- =====================================================================

return {
  -- 启动页 / 项目
  dashboard_files = "查找文件",
  dashboard_recent = "最近文件",
  dashboard_grep = "全局搜索",
  dashboard_projects = "最近项目",
  dashboard_empty_project = "暂无项目记录",
  dashboard_footer = "⚡ 工欲善其事，必先利其器",

  -- 状态栏
  status_unnamed = "[未命名]",
  status_modified = "已修改",
  status_readonly = "只读",

  -- 文件树
  tree_explorer = "文件浏览器",

  -- 终端
  terminal = "终端",

  -- 常用提示语
  msg_saved = "已保存",
  msg_copied = "已复制",
  msg_nohl = "已取消搜索高亮",
}
