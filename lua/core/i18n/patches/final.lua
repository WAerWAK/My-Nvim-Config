-- =====================================================================
--  最后一轮收尾（运行时拼接文本 + nvim-tree 帮助窗键位）
-- =====================================================================
--  背景：审计工具按行提取字符串字面量，凡是"运行时拼接"的文案
--        （如 "Failed to load `" .. modname .. "`"）在报告里只显示半截，
--        必须按源码里的完整拼接形式来替换。
-- =====================================================================

return {
  rules = {
    {
      path = "nvim-tree.lua/lua/nvim-tree/help.lua",
      note = "文件树帮助窗键位（2 条）",
      replacements = {
        { [[desc = "nvim-tree: toggle sorting method"]], [[desc = "文件树：切换排序方式"]] },
        { [[desc = "nvim-tree: exit help"]], [[desc = "文件树：关闭帮助"]] },
      },
    },
    {
      path = "lazy.nvim/lua/lazy/core/plugin.lua",
      note = "lazy 模块加载失败提示（1 条）",
      replacements = {
        { [[msg = "Failed to load `" .. modname .. "`"]], [[msg = "加载模块 `" .. modname .. "` 失败"]] },
      },
    },
    {
      -- 注：lazy.nvim 里 `opts.title = "lazy.nvim: " .. opts.title` 的 "lazy.nvim: "
      --     是插件名标识（品牌），有意保留，不做汉化。
      path = "lualine.nvim/lua/lualine/components/lsp_status.lua",
      note = "lualine LSP 组件说明（1 条）",
      replacements = {
        { [[desc = "Update the Lualine LSP status component with progress"]], [[desc = "LSP 进度变化时刷新状态栏组件"]] },
      },
    },
    {
      path = "lualine.nvim/lua/lualine.lua",
      note = "lualine 主题校验提示（1 条）",
      replacements = {
        { [[message = "Invalid theme type returned from function: "]], [[message = "主题函数返回了无效类型："]] },
      },
    },
    {
      path = "render-markdown.nvim/lua/render-markdown/health.lua",
      note = "Markdown 渲染健康检查项（3 条）",
      replacements = {
        { [[message = "none installed: "]], [[message = "未安装任何解析器："]] },
        { [[message = "parser: not installed"]], [[message = "解析器：未安装"]] },
        { [[message = "ABI: unknown"]], [[message = "ABI：未知"]] },
      },
    },
    {
      -- nvim-lspconfig 里配置项自带的文本（用户在 :help lspconfig 与配置时可见）
      path = "nvim-lspconfig/lua/lspconfig/configs/clangd.lua",
      note = "clangd 配置项说明（1 条）",
      replacements = {
        { [[title = "Symbol Info"]], [[title = "符号信息"]] },
      },
    },
    {
      path = "nvim-lspconfig/lua/lspconfig/configs/julials.lua",
      note = "julials 环境选择提示（1 条）",
      replacements = {
        { [[prompt = "Select a Julia environment"]], [[prompt = "选择 Julia 环境"]] },
      },
    },
  },
}
