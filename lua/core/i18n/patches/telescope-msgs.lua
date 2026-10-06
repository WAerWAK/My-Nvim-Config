-- =====================================================================
--  telescope.nvim 用户提示消息汉化
-- =====================================================================
--  这些是 telescope 在操作过程中弹出的提示（找 branch/tags/诊断失败、
--  没有选中项、缺依赖等），会显示在命令行区域，用户可见。
--  ⚠️ 只改给人看的文本，不动任何用于判断的字段（如 picker 名、opts 键名）。
-- =====================================================================

return {
  rules = {
    {
      path = "telescope.nvim/lua/telescope/actions/init.lua",
      note = "telescope git 分支操作提示（12 条）",
      replacements = {
        { [[message = "Error when tracking branch: %s. Git returned: '%s'"]], [[message = "跟踪分支失败：%s。Git 返回：'%s'"]] },
        { [[message = "Error when deleting branch: %s. Git returned: '%s'"]], [[message = "删除分支失败：%s。Git 返回：'%s'"]] },
        { [[message = "Error when merging branch: %s. Git returned: '%s'"]], [[message = "合并分支失败：%s。Git 返回：'%s'"]] },
        { [[message = "Error when rebasing branch: %s. Git returned: '%s'"]], [[message = "变基分支失败：%s。Git 返回：'%s'"]] },
        { [[message = "Tracking branch: %s"]], [[message = "已跟踪分支：%s"]] },
        { [[message = "Deleted branch: %s"]], [[message = "已删除分支：%s"]] },
        { [[message = "Merged branch: %s"]], [[message = "已合并分支：%s"]] },
        { [[message = "Rebased branch: %s"]], [[message = "已变基分支：%s"]] },
        { [[msg = "Missing the new branch name"]], [[msg = "请填写新分支名"]] },
        { [[msg = "No matches found"]], [[msg = "没有匹配项"]] },
        { [[msg = "No tag pre-filtering set for this picker"]], [[msg = "该 picker 未设置标签预过滤"]] },
        { [[msg = "No name available for anonymous functions."]], [[msg = "匿名函数没有可用名称。"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/actions/history.lua",
      note = "telescope 历史记录提示（1 条）",
      replacements = {
        { [[msg = "You are cycling to next the history item but history is disabled. Read ':help telescope.defaults.history'"]], [[msg = "正在切换历史记录，但历史功能已关闭。见 ':help telescope.defaults.history'"]] },
        { [[msg = "You are cycling to the previous history item but history is disabled. Read ':help telescope.defaults.history'"]], [[msg = "正在切换历史记录，但历史功能已关闭。见 ':help telescope.defaults.history'"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/actions/set.lua",
      note = "telescope 选择提示（2 条）",
      replacements = {
        { [[msg = "Nothing currently selected"]], [[msg = "当前没有选中任何项"]] },
        { [[msg = "Could not do anything with blank line..."]], [[msg = "空行上无法执行该操作……"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/builtin/__diagnostics.lua",
      note = "telescope 诊断提示（2 条）",
      replacements = {
        { [[msg = "Invalid severity parameters. Both a specific severity and a limit/bound is not allowed"]], [[msg = "严重级别参数无效：不能同时指定具体级别和数量上限"]] },
        { [[msg = "No diagnostics found"]], [[msg = "没有找到诊断信息"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/builtin/__files.lua",
      note = "telescope 文件查找提示（4 条）",
      replacements = {
        { [[msg = "You need to install either find, fd, or rg"]], [[msg = "需要安装 find、fd 或 rg 其中之一"]] },
        { [[msg = "User need to install nvim-treesitter needs to be installed"]], [[msg = "需要先安装 nvim-treesitter"]] },
        { [[msg = "No parser for the current buffer"]], [[msg = "当前缓冲区没有对应的语法解析器"]] },
        { [[msg = "No tags file found. Create one with ctags -R"]], [[msg = "没有找到 tags 文件，可用 ctags -R 生成"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/builtin/__internal.lua",
      note = "telescope 内置 picker 提示（6 条）",
      replacements = {
        { [[msg = "No sources found! Check out https://github.com/nvim-telescope/telescope-symbols.nvim "]], [[msg = "没有找到符号源！可参考 https://github.com/nvim-telescope/telescope-symbols.nvim "]] },
        { [[msg = "No buffers found with the provided options"]], [[msg = "按给定条件没有找到缓冲区"]] },
        { [[msg = "No cached picker(s)."]], [[msg = "没有缓存的 picker。"]] },
        { [[msg = "No quickfix items"]], [[msg = "快速修复列表为空"]] },
        { [[msg = "No loclist items"]], [[msg = "位置列表为空"]] },
        { [[msg = "No tagstack available"]], [[msg = "没有可用的标签栈"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/builtin/__lsp.lua",
      note = "telescope LSP 提示（5 条）",
      replacements = {
        { [[msg = "No results from workspace/symbol. Maybe try a different query: "]], [[msg = "workspace/symbol 没有返回结果，换个查询试试："]] },
        { [[msg = "No results from textDocument/documentSymbol"]], [[msg = "textDocument/documentSymbol 没有返回结果"]] },
        { [[msg = "No document_symbol locations found"]], [[msg = "没有找到 document_symbol 位置"]] },
        { [[msg = "no client attached"]], [[msg = "没有连接语言服务器"]] },
        { [[msg = "server does not support "]], [[msg = "语言服务器不支持 "]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/command.lua",
      note = "telescope 命令提示（2 条）",
      replacements = {
        { [[msg = "Command missing arguments"]], [[msg = "命令缺少参数"]] },
        { [[msg = "Unknown command"]], [[msg = "未知命令"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/utils.lua",
      note = "telescope 工具函数提示（5 条）",
      replacements = {
        { [[msg = "Either opts.symbols or opts.ignore_symbols, can't process opposing options at the same time!"]], [[msg = "opts.symbols 与 opts.ignore_symbols 不能同时使用！"]] },
        { [[msg = "Please pass ignore_symbols as either a string or a list of strings"]], [[msg = "ignore_symbols 需要传字符串或字符串列表"]] },
        { [[msg = "Please pass filtering symbols as either a string or a list of strings"]], [[msg = "过滤符号需要传字符串或字符串列表"]] },
        { [[msg = "Nothing currently selected"]], [[msg = "当前没有选中任何项"]] },
        { [[msg = "cmd has to be a table"]], [[msg = "cmd 必须是 table"]] },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/make_entry.lua",
      note = "telescope 空提交信息（1 条）",
      replacements = {
        { [[msg = "<empty commit message>"]], [[msg = "<提交信息为空>"]] },
      },
    },
  },
}
