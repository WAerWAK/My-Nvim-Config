-- =====================================================================
--  nvim-tree.lua 键位提示汉化
-- =====================================================================
--  为什么改源码而不是用配置覆盖：
--    nvim-tree 的键位提示（按 g? 弹出的帮助窗、which-key 里显示的
--    "nvim-tree: xxx"）全部来自 keymap.lua 里 opts(desc) 的拼接，官方没有
--    提供中文映射表；若用 view.mappings.list 覆盖，需要为 59 个键位逐个
--    重写 action（api.fs.* / api.node.* 全部要重新绑定），漏一个就丢一个
--    功能。这里只替换显示文本 opts("xxx")，键位与动作一律不动。
--
--  ⚠️ 规则顺序敏感："Rename: xxx" 这类前缀较长的必须排在 "Rename" 前面，
--     patcher 按表内顺序逐条查找替换。
-- =====================================================================

return {
  rules = {
    {
      path = "nvim-tree.lua/lua/nvim-tree/keymap.lua",
      note = "文件树默认键位提示（59 条）",
      replacements = {
        -- ---------- 打开 / 导航（长串在前） ----------
        { [[opts("Open: No Window Picker")]], [[opts("打开（不弹出窗口选择）")]] },
        { [[opts("Open: Vertical Split")]], [[opts("垂直分屏打开")]] },
        { [[opts("Open: Horizontal Split")]], [[opts("水平分屏打开")]] },
        { [[opts("Open: New Tab")]], [[opts("在新标签页打开")]] },
        { [[opts("Open: In Place")]], [[opts("就地打开（替换文件树窗口）")]] },
        { [[opts("Open Preview")]], [[opts("预览打开")]] },
        { [[opts("Parent Directory")]], [[opts("父目录")]] },
        { [[opts("Close Directory")]], [[opts("关闭目录（回到父目录）")]] },
        { [[opts("Next Sibling")]], [[opts("下一个同级节点")]] },
        { [[opts("Previous Sibling")]], [[opts("上一个同级节点")]] },
        { [[opts("Last Sibling")]], [[opts("最后一个同级节点")]] },
        { [[opts("First Sibling")]], [[opts("第一个同级节点")]] },
        { [[opts("CD")]], [[opts("切换根目录到此处")]] },
        { [[opts("Info")]], [[opts("查看节点信息")]] },
        { [[opts("Up")]], [[opts("上一层目录")]] },
        { [[opts("Open")]], [[opts("打开")]] },

        -- ---------- 文件操作 ----------
        { [[opts("Create File Or Directory")]], [[opts("新建文件或目录")]] },
        { [[opts("Rename: Omit Filename")]], [[opts("重命名（不含文件名）")]] },
        { [[opts("Rename: Full Path")]], [[opts("重命名（含完整路径）")]] },
        { [[opts("Rename: Basename")]], [[opts("重命名（只改文件名）")]] },
        { [[opts("Copy Absolute Path")]], [[opts("复制绝对路径")]] },
        { [[opts("Copy Relative Path")]], [[opts("复制相对路径")]] },
        { [[opts("Copy Basename")]], [[opts("复制文件名（不含扩展名）")]] },
        { [[opts("Copy Name")]], [[opts("复制文件名")]] },
        { [[opts("Rename")]], [[opts("重命名")]] },
        { [[opts("Delete")]], [[opts("删除")]] },
        { [[opts("Trash")]], [[opts("移入回收站")]] },
        { [[opts("Copy")]], [[opts("复制节点")]] },
        { [[opts("Cut")]], [[opts("剪切节点")]] },
        { [[opts("Paste")]], [[opts("粘贴")]] },
        { [[opts("Run Command")]], [[opts("对节点执行命令")]] },
        { [[opts("Run System")]], [[opts("用系统程序打开")]] },

        -- ---------- 书签 ----------
        { [[opts("Delete Bookmarked")]], [[opts("删除所有书签项")]] },
        { [[opts("Trash Bookmarked")]], [[opts("把书签项移入回收站")]] },
        { [[opts("Move Bookmarked")]], [[opts("移动书签项")]] },
        { [[opts("Toggle Bookmark")]], [[opts("添加/取消书签")]] },

        -- ---------- 过滤 ----------
        { [[opts("Live Filter: Start")]], [[opts("实时过滤：开始")]] },
        { [[opts("Live Filter: Clear")]], [[opts("实时过滤：清除")]] },
        { [[opts("Toggle Filter: No Bookmark")]], [[opts("过滤：只显示书签项")]] },
        { [[opts("Toggle Filter: No Buffer")]], [[opts("过滤：隐藏未打开的文件")]] },
        { [[opts("Toggle Filter: Git Clean")]], [[opts("过滤：隐藏无 Git 改动")]] },
        { [[opts("Toggle Filter: Git Ignore")]], [[opts("过滤：隐藏 .gitignore 项")]] },
        { [[opts("Toggle Filter: Dotfiles")]], [[opts("过滤：隐藏点文件")]] },
        { [[opts("Toggle Filter: Hidden")]], [[opts("过滤：隐藏自定义排除项")]] },

        -- ---------- 树 / 诊断 / Git ----------
        { [[opts("Next Diagnostic")]], [[opts("下一个诊断")]] },
        { [[opts("Prev Diagnostic")]], [[opts("上一个诊断")]] },
        { [[opts("Toggle Group Empty")]], [[opts("折叠/展开空目录")]] },
        { [[opts("Expand All")]], [[opts("展开全部")]] },
        { [[opts("Collapse")]], [[opts("折叠全部")]] },
        { [[opts("Next Git")]], [[opts("下一个 Git 改动")]] },
        { [[opts("Prev Git")]], [[opts("上一个 Git 改动")]] },

        -- ---------- 其它 ----------
        { [[opts("Close")]], [[opts("关闭文件树")]] },
        { [[opts("Refresh")]], [[opts("刷新")]] },
        { [[opts("Search")]], [[opts("搜索节点")]] },
        { [[opts("Help")]], [[opts("查看帮助")]] },
      },
    },
  },
}
