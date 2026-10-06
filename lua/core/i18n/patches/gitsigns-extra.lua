-- =====================================================================
--  gitsigns.nvim 剩余界面文本汉化
-- =====================================================================
--  覆盖：blame 菜单、预览/警告提示、autocmd 描述、高亮组说明
--  注：highlight.lua 的 desc 会出现在 `:hi GitSignsAdd` 的输出里，属可见文本。
-- =====================================================================

return {
  rules = {
    {
      path = "gitsigns.nvim/lua/gitsigns/actions/blame.lua",
      note = "blame 上下文菜单（6 条）",
      replacements = {
        { [[desc = 'Open blame context menu']], [[desc = '打开 blame 菜单']] },
        { [[desc = 'Reblame at commit']], [[desc = '按该提交重新 blame']] },
        { [[desc = 'Reblame at commit parent']], [[desc = '按该提交的父提交重新 blame']] },
        { [[desc = 'Diff (tab)']], [[desc = '差异对比（新标签页）']] },
        { [[desc = 'Show commit in a vertical split']], [[desc = '在垂直分屏中查看提交']] },
        { [[desc = 'Show commit in a new tab']], [[desc = '在新标签页中查看提交']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/actions/diffthis.lua",
      note = "索引变更警告提示（1 条）",
      replacements = {
        { [[prompt = 'Warning: The git index has changed and the buffer was changed as well. [O]K, (L)oad File:']], [[prompt = '警告：Git 索引与缓冲区都已变更。[O] 继续，(L) 加载文件：']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/actions/preview.lua",
      note = "行内预览说明（1 条）",
      replacements = {
        { [[desc = 'Clear gitsigns inline preview']], [[desc = '清除行内预览']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/git/blame.lua",
      note = "blame 执行失败提示（1 条）",
      replacements = {
        { [[msg = 'Error running git-blame: ']], [[msg = '执行 git-blame 出错：']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/highlight.lua",
      note = "高亮组说明（14 条，显示在 :hi 输出中）",
      replacements = {
        { [[desc = 'Used for added lines in previews.']], [[desc = '用于预览中的新增行。']] },
        { [[desc = 'Used for deleted lines in previews.']], [[desc = '用于预览中的删除行。']] },
        { [[desc = 'Used for "No newline at end of file".']], [[desc = '用于「文件末尾缺少换行」提示。']] },
        { [[desc = 'Used for current line blame.']], [[desc = '用于当前行的 blame 信息。']] },
        { [[desc = 'Used for added word diff regions in inline previews.']], [[desc = '用于行内预览中新增的词级差异。']] },
        { [[desc = 'Used for deleted word diff regions in inline previews.']], [[desc = '用于行内预览中删除的词级差异。']] },
        { [[desc = 'Used for changed word diff regions in inline previews.']], [[desc = '用于行内预览中修改的词级差异。']] },
        { [[desc = 'Used for added word diff regions when `config.word_diff == true`.']], [[desc = '用于 `config.word_diff == true` 时新增的词级差异。']] },
        { [[desc = 'Used for changed word diff regions when `config.word_diff == true`.']], [[desc = '用于 `config.word_diff == true` 时修改的词级差异。']] },
        { [[desc = 'Used for deleted word diff regions when `config.word_diff == true`.']], [[desc = '用于 `config.word_diff == true` 时删除的词级差异。']] },
        { [[desc = 'Used for deleted lines shown by inline `preview_hunk_inline()` or `show_deleted()`.']], [[desc = '用于 `preview_hunk_inline()` / `show_deleted()` 展示的删除行。']] },
        { [[desc = 'Used for word diff regions in lines shown by inline `preview_hunk_inline()` or `show_deleted()`.']], [[desc = '用于上述删除行中的词级差异。']] },
        { [[desc = 'Used for line numbers in inline hunks previews.']], [[desc = '用于行内代码块预览的行号。']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns.lua",
      note = "gitsigns autocmd 描述（2 条）",
      replacements = {
        { [[desc = 'Gitsigns: attach']], [[desc = 'Gitsigns：挂载到缓冲区']] },
        { [[desc = 'Gitsigns: disable attach during vimgrep']], [[desc = 'Gitsigns：vimgrep 期间暂停挂载']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/attach.lua",
      note = "gitsigns autocmd 描述（2 条）",
      replacements = {
        { [[desc = 'Gitsigns: detach when changing buffer names']], [[desc = 'Gitsigns：缓冲区改名时卸载']] },
        { [[desc = 'Gitsigns: detach from all buffers']], [[desc = 'Gitsigns：从全部缓冲区卸载']] },
      },
    },
    {
      path = "gitsigns.nvim/lua/gitsigns/manager.lua",
      note = "gitsigns autocmd 描述（1 条）",
      replacements = {
        { [[desc = 'Gitsigns: deferred updates']], [[desc = 'Gitsigns：延迟更新']] },
      },
    },
  },
}
