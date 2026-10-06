-- =====================================================================
--  体积小但用户可见的插件文本（清扫剩余项）
-- =====================================================================
--  dashboard / Comment / nvim-web-devicons / LuaSnip / nvim-autopairs /
--  which-key / noice / nvim-notify / lualine / mason-lspconfig /
--  render-markdown / rainbow-delimiters
--  注：这些多为 autocmd 描述、命令说明或偶尔弹出的提示，属"完整汉化"的收尾。
--      nvim-lspconfig 的 configs/*.lua 里剩的是 LSP 协议参数与用户配置项，
--      不是 Neovim 界面文本，**有意不动**。
-- =====================================================================

return {
  rules = {
    {
      path = "dashboard-nvim/lua/dashboard/init.lua",
      note = "启动页 autocmd 描述（1 条）",
      replacements = {
        { [[desc = '[Dashboard] clean dashboard data reduce memory']], [[desc = '[Dashboard] 清理启动页数据以减少内存占用']] },
      },
    },
    {
      path = "dashboard-nvim/lua/dashboard/preview.lua",
      note = "启动页预览 autocmd 描述（3 条）",
      replacements = {
        { [[desc = ' Dashboard preview window resized for nvim 0.9']], [[desc = ' 启动页预览窗口尺寸适配 nvim 0.9']] },
        { [[desc = 'dashboard preview window resize for neovim 0.8+ version']], [[desc = '启动页预览窗口尺寸适配 neovim 0.8+']] },
        { [[desc = 'make preview have same lifetime with dashboard buffer']], [[desc = '让预览窗口与启动页缓冲区同生命周期']] },
      },
    },
    {
      path = "Comment.nvim/lua/Comment/utils.lua",
      note = "注释插件提示（1 条）",
      replacements = {
        { [[msg = "Nothing to uncomment!"]], [[msg = "没有可取消注释的内容！"]] },
      },
    },
    {
      path = "nvim-web-devicons/lua/nvim-web-devicons.lua",
      note = "图标插件命令与 autocmd 说明（2 条）",
      replacements = {
        { [[desc = "Re-apply icon colors after changing colorschemes"]], [[desc = "切换配色后重新应用图标颜色"]] },
        { [[desc = "nvim-web-devicons: highlight test"]], [[desc = "图标插件：高亮组测试页"]] },
      },
    },
    {
      path = "LuaSnip/lua/luasnip/loaders/init.lua",
      note = "LuaSnip 选择提示（2 条）",
      replacements = {
        { [[prompt = "Multiple files for this filetype, choose one:"]], [[prompt = "该文件类型有多个片段文件，请选择："]] },
        { [[prompt = "Select filetype:"]], [[prompt = "选择文件类型："]] },
      },
    },
    {
      path = "LuaSnip/lua/luasnip/loaders/util.lua",
      note = "LuaSnip 选择提示（2 条）",
      replacements = {
        { [[prompt = "Multiple files for this filetype, choose one:"]], [[prompt = "该文件类型有多个片段文件，请选择："]] },
        { [[prompt = "Select filetype:"]], [[prompt = "选择文件类型："]] },
      },
    },
    {
      path = "nvim-autopairs/lua/nvim-autopairs.lua",
      note = "自动配对键位说明（6 条）",
      replacements = {
        { [[desc = "autopairs completion confirm"]], [[desc = "自动配对：确认补全"]] },
        { [[desc = "autopairs map key"]], [[desc = "自动配对：括号映射"]] },
        { [[desc = "autopairs fastwrap"]], [[desc = "自动配对：快速包裹"]] },
        { [[desc = "autopairs delete"]], [[desc = "自动配对：删除括号"]] },
      },
    },
    {
      path = "which-key.nvim/lua/which-key/config.lua",
      note = "which-key 配置校验提示（2 条）",
      replacements = {
        { [[msg = " option is deprecated."]], [[msg = " 选项已弃用。"]] },
        { [[msg = "triggers must be a table"]], [[msg = "triggers 必须是 table"]] },
      },
    },
    {
      path = "which-key.nvim/lua/which-key/plugins/spelling.lua",
      note = "which-key 拼写建议标题（1 条）",
      replacements = {
        { [[desc = "Spelling Suggestions"]], [[desc = "拼写建议"]] },
      },
    },
    {
      path = "noice.nvim/lua/noice/lsp/message.lua",
      note = "noice LSP 消息窗标题（1 条）",
      replacements = {
        { [[title = "LSP Message ("]], [[title = "LSP 消息（"]] },
      },
    },
    {
      path = "noice.nvim/lua/noice/ui/init.lua",
      note = "noice 内部错误提示（1 条）",
      replacements = {
        { [[msg = "An error happened while handling a ui event"]], [[msg = "处理界面事件时出错"]] },
      },
    },
    {
      path = "noice.nvim/lua/telescope/_extensions/noice.lua",
      note = "noice 消息历史列表标题（2 条）",
      replacements = {
        { [[title = "Filter Noice"]], [[title = "筛选消息"]] },
        { [[prompt_title = "Filter Noice"]], [[prompt_title = "筛选消息"]] },
      },
    },
    {
      path = "nvim-notify/lua/notify/integrations/fzf.lua",
      note = "通知 fzf 集成标题（1 条）",
      replacements = {
        { [[title = " Filter Notifications "]], [[title = " 筛选通知 "]] },
      },
    },
    {
      path = "lualine.nvim/lua/lualine/components/lsp_status.lua",
      note = "状态栏组件说明（1 条）",
      replacements = {
        { [[desc = "Update the Lualine LSP status component with progress"]], [[desc = "用进度信息更新 lualine 的 LSP 状态组件"]] },
      },
    },
    {
      path = "lualine.nvim/lua/lualine.lua",
      note = "状态栏主题校验提示（1 条）",
      replacements = {
        { [[message = "Invalid theme type returned from function: "]], [[message = "主题函数返回了无效类型："]] },
      },
    },
    {
      path = "mason-lspconfig.nvim/lua/mason-lspconfig/lsp/pylsp.lua",
      note = "pylsp 安装说明（1 条）",
      replacements = {
        { [[desc = "[mason-lspconfig.nvim] Installs the provided packages in the same venv as pylsp."]], [[desc = "[mason-lspconfig.nvim] 把指定的包装到 pylsp 所用的同一个虚拟环境中。"]] },
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
      path = "rainbow-delimiters.nvim/lua/rainbow-delimiters/health.lua",
      note = "彩虹括号健康检查项（5 条）",
      replacements = {
        { [[msg = "Valid custom default strategy."]], [[msg = "自定义默认策略有效。"]] },
        { [[msg = "Invalid custom default strategy."]], [[msg = "自定义默认策略无效。"]] },
        { [[msg = "Valid custom default query"]], [[msg = "自定义默认查询有效"]] },
        { [[msg = "Valid custom default priority"]], [[msg = "自定义默认优先级有效"]] },
        { [[msg = "Invalid custom default priority"]], [[msg = "自定义默认优先级无效"]] },
      },
    },
  },
}
