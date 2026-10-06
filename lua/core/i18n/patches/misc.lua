-- =====================================================================
--  其它插件界面汉化
-- =====================================================================
--  Comment.nvim：注释键位说明（gc/gcc/gb/gcO…）
--    这些映射是回调型（rhs 为 nil），不能靠 vim.keymap.set 补 desc，
--    否则注释功能会失效；改源码里的 desc 字符串是唯一安全做法。
--  dashboard-nvim：启动页主题文本（hyper 主题由配置文件引入）
-- =====================================================================

return {
  rules = {
    {
      path = "Comment.nvim/lua/Comment/init.lua",
      note = "Comment.nvim 键位说明（9 条）",
      replacements = {
        { [[desc = 'Comment toggle linewise']], [[desc = '注释（按行）']] },
        { [[desc = 'Comment toggle blockwise']], [[desc = '注释（按块）']] },
        { [[desc = 'Comment toggle current line']], [[desc = '注释当前行']] },
        { [[desc = 'Comment toggle current block']], [[desc = '注释当前块']] },
        { [[desc = 'Comment toggle linewise (visual)']], [[desc = '注释选中内容']] },
        { [[desc = 'Comment toggle blockwise (visual)']], [[desc = '块注释选中内容']] },
        { [[desc = 'Comment insert below']], [[desc = '在下方插入注释行']] },
        { [[desc = 'Comment insert above']], [[desc = '在上方插入注释行']] },
        { [[desc = 'Comment insert end of line']], [[desc = '在行尾插入注释']] },
      },
    },
    {
      path = "dashboard-nvim/lua/dashboard/theme/hyper.lua",
      note = "启动页主题文本（3 条）",
      replacements = {
        { [[label = ' Recent Projects:']], [[label = ' 📂 最近项目:']] },
        { [[' empty project']], [[' 暂无项目记录']] },
        { [[label = ' Most Recent Files:']], [[label = ' 🕘 最近打开的文件:']] },
      },
    },
  },
}
