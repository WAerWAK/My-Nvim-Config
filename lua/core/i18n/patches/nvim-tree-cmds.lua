-- =====================================================================
--  nvim-tree.lua 命令说明汉化
-- =====================================================================
--  这些是 `:NvimTreeOpen` 等命令的 desc，用户在 `:help :NvimTreeOpen`、
--  命令补全（按 Tab）和 `:command` 列表里都能看到，值得汉化。
-- =====================================================================

return {
  rules = {
    {
      path = "nvim-tree.lua/lua/nvim-tree/commands.lua",
      note = "文件树命令说明（11 条）",
      replacements = {
        { [[desc = "nvim-tree: open"]], [[desc = "文件树：打开"]] },
        { [[desc = "nvim-tree: close"]], [[desc = "文件树：关闭"]] },
        { [[desc = "nvim-tree: toggle"]], [[desc = "文件树：开关"]] },
        { [[desc = "nvim-tree: focus"]], [[desc = "文件树：聚焦到文件树窗口"]] },
        { [[desc = "nvim-tree: refresh"]], [[desc = "文件树：刷新"]] },
        { [[desc = "nvim-tree: print clipboard"]], [[desc = "文件树：显示剪贴板内容"]] },
        { [[desc = "nvim-tree: find file, toggle"]], [[desc = "文件树：定位当前文件（开关）"]] },
        { [[desc = "nvim-tree: find file"]], [[desc = "文件树：定位当前文件"]] },
        { [[desc = "nvim-tree: resize"]], [[desc = "文件树：调整窗口宽度"]] },
        { [[desc = "nvim-tree: highlight test"]], [[desc = "文件树：高亮组测试页"]] },
        { [[desc = "nvim-tree: collapse, keep directories open"]], [[desc = "文件树：折叠（保留目录展开）"]] },
        { [[desc = "nvim-tree: collapse"]], [[desc = "文件树：全部折叠"]] },
      },
    },
  },
}
