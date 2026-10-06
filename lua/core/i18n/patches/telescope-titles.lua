-- =====================================================================
--  telescope.nvim 标题与预览窗汉化
-- =====================================================================
--  ⚠️ 为什么有些标题用配置改不掉（原来的坑）：
--     telescope 的 pickers.<name>.prompt_title 配置是在 `setup()` 时写入的，
--     而 builtin 里写死的 `prompt_title = "..."` 是**之后**才合并进 opts 的
--     （builtin/__files.lua 等文件里各 picker 自己设了一遍），
--     所以 defaults/pickers 覆盖不到它们。这些只能改源码文本。
-- =====================================================================

return {
  rules = {
    {
      -- 文件类 picker：这几个配置里没覆盖（或覆盖不到）
      -- 注：该文件里只用 prompt_title，没有单独的 title 字段
      path = "telescope.nvim/lua/telescope/builtin/__files.lua",
      note = "telescope 文件类 picker 标题（7 条）",
      replacements = {
        { [[prompt_title = "Current Buffer Fuzzy"]], [[prompt_title = "在当前文件中搜索"]] },
        { [[prompt_title = "Current Buffer Tags"]], [[prompt_title = "当前文件的标签"]] },
        { [[prompt_title = "Treesitter Symbols"]], [[prompt_title = "语法树符号"]] },
        { [[prompt_title = "Find Files"]], [[prompt_title = "查找文件"]] },
        { [[prompt_title = "Find Word ("]], [[prompt_title = "查找单词（"]] },
        { [[prompt_title = "Live Grep"]], [[prompt_title = "全局搜索内容"]] },
        { [[prompt_title = "Tags"]], [[prompt_title = "标签"]] },
      },
    },
    {
      -- LSP 类 picker（配置里虽已覆盖，但补上源码标题以防 opts 合并顺序变化）
      path = "telescope.nvim/lua/telescope/builtin/__lsp.lua",
      note = "telescope LSP picker 标题（4 条）",
      replacements = {
        { [[prompt_title = "LSP Document Symbols"]], [[prompt_title = "当前文件符号"]] },
        { [[prompt_title = "LSP Dynamic Workspace Symbols"]], [[prompt_title = "工作区符号（动态）"]] },
        { [[prompt_title = "LSP Workspace Symbols"]], [[prompt_title = "工作区符号"]] },
        { [[prompt_title = "LSP References"]], [[prompt_title = "LSP 引用"]] },
      },
    },
    {
      -- 预览窗标题（英文 File Preview 已单独处理过，这里是其余预览器）
      path = "telescope.nvim/lua/telescope/previewers/buffer_previewer.lua",
      note = "telescope 缓冲区预览窗标题（18 条）",
      replacements = {
        { [[title = "Git Diff to Parent Preview"]], [[title = "Git 与父提交的差异"]] },
        { [[title = "Git Diff to Head Preview"]], [[title = "Git 与 HEAD 的差异"]] },
        { [[title = "Autocommands Preview"]], [[title = "自动命令预览"]] },
        { [[title = "Quickfix List Preview"]], [[title = "快速修复列表预览"]] },
        { [[title = "Highlights Preview"]], [[title = "高亮组预览"]] },
        { [[title = "Git Branch Preview"]], [[title = "Git 分支预览"]] },
        { [[title = "Git File Diff Preview"]], [[title = "Git 文件差异"]] },
        { [[title = "Git Stash Preview"]], [[title = "Git 储藏预览"]] },
        { [[title = "Git Show Preview"]], [[title = "Git 提交内容"]] },
        { [[title = "Telescope Builtin"]], [[title = "Telescope 内置函数"]] },
        { [[title = "Telescope Pickers"]], [[title = "Telescope 全部 picker"]] },
        { [[title = "Help Preview"]], [[title = "帮助预览"]] },
        { [[title = "Man Preview"]], [[title = "手册页预览"]] },
        { [[title = "Tags Preview"]], [[title = "标签预览"]] },
        { [[title = "Grep Preview"]], [[title = "搜索结果预览"]] },
        { [[title = "Git Message"]], [[title = "Git 提交信息"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/previewers/term_previewer.lua",
      note = "telescope 终端预览窗标题（1 条）",
      replacements = {
        { [[title = "Grep Preview"]], [[title = "搜索结果预览"]] },
      },
    },
    {
      -- 内置 picker 的标题（配置里已覆盖大部分，这里补齐写死在源码里的几个）
      path = "telescope.nvim/lua/telescope/builtin/__internal.lua",
      note = "telescope 内置 picker 标题（6 条）",
      replacements = {
        { [[prompt_title = "Change Colorscheme"]], [[prompt_title = "切换配色"]] },
        { [[prompt_title = "Command History"]], [[prompt_title = "命令历史"]] },
        { [[prompt_title = "Quickfix History"]], [[prompt_title = "快速修复历史"]] },
        { [[prompt_title = "Spelling Suggestions"]], [[prompt_title = "拼写建议"]] },
        { [[prompt_title = "Key Maps"]], [[prompt_title = "键位映射"]] },
        { [[prompt_title = "TagStack"]], [[prompt_title = "标签栈"]] },
      },
    },
  },
}
