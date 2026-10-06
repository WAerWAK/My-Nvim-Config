-- =====================================================================
--  aerial.nvim 代码大纲汉化
-- =====================================================================
--  覆盖：大纲窗口内 g? 帮助里 23 条操作说明
--  注：aerial 的符号类型名（Function/Class…）来自 LSP/treesitter 返回的
--      kind 值，属数据而非界面文本，保留原样（改它会破坏 filter_kind 匹配）。
-- =====================================================================

return {
  rules = {
    {
      path = "aerial.nvim/lua/aerial/actions.lua",
      note = "aerial 操作说明（23 条）",
      replacements = {
        { [[desc = "Show default keymaps"]], [[desc = "显示默认键位"]] },
        { [[desc = "Jump to the symbol under the cursor"]], [[desc = "跳转到光标处的符号"]] },
        { [[desc = "Jump to the symbol in a vertical split"]], [[desc = "在垂直分屏中打开该符号"]] },
        { [[desc = "Jump to the symbol in a horizontal split"]], [[desc = "在水平分屏中打开该符号"]] },
        { [[desc = "Scroll to the symbol (stay in aerial buffer)"]], [[desc = "滚动到该符号（停留在大纲窗口）"]] },
        { [[desc = "Go down one line and scroll to that symbol"]], [[desc = "下移一行并滚动到该符号"]] },
        { [[desc = "Go up one line and scroll to that symbol"]], [[desc = "上移一行并滚动到该符号"]] },
        { [[desc = "Jump to the previous symbol"]], [[desc = "跳到上一个符号"]] },
        { [[desc = "Jump to the next symbol"]], [[desc = "跳到下一个符号"]] },
        { [[desc = "Jump up the tree, moving backwards in the file"]], [[desc = "在大纲中向上跳（文件中位置前移）"]] },
        { [[desc = "Jump up the tree, moving forwards in the file"]], [[desc = "在大纲中向上跳（文件中位置后移）"]] },
        { [[desc = "Close the aerial window"]], [[desc = "关闭大纲窗口"]] },
        { [[desc = "Recursively toggle the symbol under the cursor open/closed"]], [[desc = "递归展开/折叠光标处符号"]] },
        { [[desc = "Toggle the symbol under the cursor open/closed"]], [[desc = "展开/折叠光标处符号"]] },
        { [[desc = "Recursively expand the symbol under the cursor"]], [[desc = "递归展开光标处符号"]] },
        { [[desc = "Expand the symbol under the cursor"]], [[desc = "展开光标处符号"]] },
        { [[desc = "Recursively collapse the symbol under the cursor"]], [[desc = "递归折叠光标处符号"]] },
        { [[desc = "Collapse the symbol under the cursor"]], [[desc = "折叠光标处符号"]] },
        { [[desc = "Increase the fold level of the tree"]], [[desc = "提高大纲折叠层级"]] },
        { [[desc = "Decrease the fold level of the tree"]], [[desc = "降低大纲折叠层级"]] },
        { [[desc = "Expand all nodes in the tree"]], [[desc = "展开全部节点"]] },
        { [[desc = "Collapse all nodes in the tree"]], [[desc = "折叠全部节点"]] },
        { [[desc = "Sync code folding to the tree (useful if they get out of sync)"]], [[desc = "把代码折叠同步到大纲（两边不同步时用）"]] },
      },
    },
  },
}
