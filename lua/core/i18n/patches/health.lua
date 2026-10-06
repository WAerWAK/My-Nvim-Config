-- =====================================================================
--  插件健康检查（:checkhealth）文案汉化
-- =====================================================================
--  ⚠️ 规则必须带**引号边界**（'文本' / "文本"）：
--     早期版本用无边界的裸文本匹配，把 `state.validate()` 里的 `valid`
--     也换成了中文，直接把 render-markdown 的 health.lua 改成非法 Lua。
--     本文件由 scripts/i18n-health-gen.py 生成，每条都已用 nvim 做过
--     loadfile 语法校验后才写入。
--  注：含 %%s/%%d 占位符的串在生成阶段已排除；health 的「分组名」保持英文。
-- =====================================================================

-- =====================================================================
--  :checkhealth 入口
-- =====================================================================
--  本文件是规则表，但 nvim 0.12 的 `:checkhealth`（无参数）会扫描 rtp 下
--  所有可 require 的模块并调用 `require(name).check()`，缺失就报 ERROR，
--  所以这里补一个真实的检查。
local M = {
  rules = {
    {
      path = "LuaSnip/lua/luasnip/health.lua",
      note = "LuaSnip 健康检查文案（1 条，带引号边界）",
      replacements = {
        { [["jsregexp is installed"]], [["jsregexp 已安装"]] }, -- jsregexp is installed
      },
    },
    {
      path = "nvim-lspconfig/lua/lspconfig/health.lua",
      note = "nvim-lspconfig 健康检查文案（24 条，带引号边界）",
      replacements = {
        { [['Unable to find executable. Check your $PATH and ensure the server is installed.']], [['未找到可执行文件。请检查 $PATH，并确认该服务器已安装。']] }, -- Unable to find executable. Check your $PATH and ensure the s
        { [['No filetypes defined. Define filetypes in setup().']], [['未定义任何文件类型。请在 setup() 中定义 filetypes。']] }, -- No filetypes defined. Define filetypes in setup().
        { [['Not found.']], [['未找到。']] }, -- Not found.
        { [['Asynchronous root_dir functions are not supported by `:checkhealth lspconfig`']], [['`:checkhealth lspconfig` 不支持异步的 root_dir 函数']] }, -- Asynchronous root_dir functions are not supported by `:check
        { [['cmd not defined']], [['未定义 cmd']] }, -- cmd not defined
        { [['? (cmd is a function)']], [['?（cmd 是函数）']] }, -- ? (cmd is a function)
        { [['filetypes:         ']], [['文件类型：         ']] }, -- filetypes:         
        { [['cmd:               ']], [['cmd：              ']] }, -- cmd:               
        { [['version:']], [['版本：']] }, -- version:
        { [['executable:        ']], [['可执行文件：       ']] }, -- executable:        
        { [['autostart:         ']], [['自动启动：         ']] }, -- autostart:         
        { [['Config: ']], [['配置：']] }, -- Config: 
        { [['root directory:    ']], [['根目录：           ']] }, -- root directory:    
        { [['custom handlers:   ']], [['自定义处理器：     ']] }, -- custom handlers:   
        { [['Refer to ']], [['请参阅 ']] }, -- Refer to 
        { [[' for help.']], [[' 以获取帮助。']] }, --  for help.
        { [['Running in single file mode.']], [['运行于单文件模式。']] }, -- Running in single file mode.
        { [['Configured servers: ']], [['已配置的服务器：']] }, -- Configured servers: 
        { [['Deprecated servers: (none)']], [['已弃用的服务器：（无）']] }, -- Deprecated servers: (none)
        { [['Deprecated servers: ']], [['已弃用的服务器：']] }, -- Deprecated servers: 
        { [['(invalid buffer)']], [['（无效缓冲区）']] }, -- (invalid buffer)
        { [['Language client log: ']], [['语言客户端日志：']] }, -- Language client log: 
        { [['`:checkhealth lspconfig` was removed. Use `:checkhealth vim.lsp` instead.']], [['`:checkhealth lspconfig` 已被移除，请改用 `:checkhealth vim.lsp`。']] }, -- `:checkhealth lspconfig` was removed. Use `:checkhealth vim.
        { [['Skipped. This healthcheck is redundant with `:checkhealth vim.lsp`.']], [['已跳过。此健康检查与 `:checkhealth vim.lsp` 功能重复。']] }, -- Skipped. This healthcheck is redundant with `:checkhealth vi
      },
    },
    {
      -- 逻辑同步：fmtpath() 用英文前缀判断"这不是路径，而是占位文案"。
      -- 上面把 'Not found.' 译成中文后，这个前缀判断必须一起改，否则会拿中文
      -- 句子去 isdirectory()（只影响末尾是否补 "/"，但改对更好）。
      path = "nvim-lspconfig/lua/lspconfig/health.lua",
      note = "lspconfig 路径美化逻辑同步（1 条）",
      replacements = {
        {
          [[  if vim.startswith(p, 'Running') or vim.startswith(p, 'Not') then]],
          [[  if
    vim.startswith(p, "Running")
    or vim.startswith(p, "Not")
    or vim.startswith(p, "未找到")
  then]],
        },
      },
    },
    {
      path = "nvim-treesitter/lua/nvim-treesitter/health.lua",
      note = "nvim-treesitter 健康检查文案（17 条，带引号边界）",
      replacements = {
        { [['Nvim-treesitter requires Neovim 0.12.0 or later.']], [['Nvim-treesitter 需要 Neovim 0.12.0 或更高版本。']] }, -- Nvim-treesitter requires Neovim 0.12.0 or later.
        { [['Neovim was compiled with tree-sitter runtime ABI version ']], [['Neovim 编译时使用的 tree-sitter 运行时 ABI 版本为 ']] }, -- Neovim was compiled with tree-sitter runtime ABI version 
        { [[' (required >=']], [['（要求 >=']] }, --  (required >=
        { [[').']], [['）。']] }, -- ).
        { [['.\n']], [['。\n']] }, -- .\n
        { [['nvim-treesitter expects at least ABI version ']], [['nvim-treesitter 要求 ABI 版本至少为 ']] }, -- nvim-treesitter expects at least ABI version 
        { [['Please make sure that Neovim is linked against a recent tree-sitter library when building']], [['构建 Neovim 时请确保它链接到较新的 tree-sitter 库']] }, -- Please make sure that Neovim is linked against a recent tree
        { [[' or raise an issue at your Neovim packager. Parsers must be compatible with runtime ABI.']], [['，或向你的 Neovim 打包方提交 issue。解析器必须与运行时 ABI 兼容。']] }, --  or raise an issue at your Neovim packager. Parsers must be 
        { [['tree-sitter-cli not found']], [['未找到 tree-sitter-cli']] }, -- tree-sitter-cli not found
        { [['tar not found']], [['未找到 tar']] }, -- tar not found
        { [['curl not found']], [['未找到 curl']] }, -- curl not found
        { [['is writable.']], [['可写。']] }, -- is writable.
        { [['is not writable.']], [['不可写。']] }, -- is not writable.
        { [['is in runtimepath.']], [['已在 runtimepath 中。']] }, -- is in runtimepath.
        { [['is not in runtimepath.']], [['不在 runtimepath 中。']] }, -- is not in runtimepath.
        { [['dependency ']], [['依赖 ']] }, -- dependency 
        { [[' missing']], [[' 缺失']] }, --  missing
      },
    },
    {
      path = "render-markdown.nvim/lua/render-markdown/health.lua",
      note = "render-markdown.nvim 健康检查文案（21 条，带引号边界）",
      replacements = {
        { [['tree-sitter ABI: ']], [['tree-sitter ABI：']] }, -- tree-sitter ABI: 
        { [['plugin: ']], [['插件：']] }, -- plugin: 
        { [['valid']], [['配置有效']] }, -- valid
        { [['using: ']], [['正在使用：']] }, -- using: 
        { [['none installed: ']], [['未安装：']] }, -- none installed: 
        { [['none installed']], [['未安装']] }, -- none installed
        { [['Disable the UI in your obsidian.nvim config']], [['在你的 obsidian.nvim 配置中禁用其 UI']] }, -- Disable the UI in your obsidian.nvim config
        { [['neovim < ']], [['neovim 版本低于 ']] }, -- neovim < 
        { [[' some features will not work']], [['，部分功能将无法正常工作']] }, --  some features will not work
        { [['neovim >= ']], [['neovim 版本 >= ']] }, -- neovim >= 
        { [['parser: installed']], [['解析器：已安装']] }, -- parser: installed
        { [['parser: not installed']], [['解析器：未安装']] }, -- parser: not installed
        { [['ABI: unknown']], [['ABI：未知']] }, -- ABI: unknown
        { [['ABI: ']], [['ABI：']] }, -- ABI: 
        { [['highlights: unknown']], [['高亮：未知']] }, -- highlights: unknown
        { [['highlights: ']], [['高亮：']] }, -- highlights: 
        { [['highlighter: enabled']], [['高亮器：已启用']] }, -- highlighter: enabled
        { [['highlighter: not enabled']], [['高亮器：未启用']] }, -- highlighter: not enabled
        { [[': installed but should not conflict']], [['：已安装，但不应产生冲突']] }, -- : installed but should not conflict
        { [[': not installed']], [['：未安装']] }, -- : not installed
        { [[': installed']], [['：已安装']] }, -- : installed
      },
    },
  },
}

--- 见文件头的说明：提供给 `:checkhealth` 的无参扫描使用
function M.check()
  vim.health.start("core.i18n.patches.health（插件健康检查汉化）")
  local total = 0
  for _, g in ipairs(M.rules) do
    total = total + #g.replacements
  end
  vim.health.ok(("%d 个插件的 health 文案规则 / %d 条（带引号边界）"):format(#M.rules, total))

  local base = vim.fn.stdpath("data") .. "/lazy/"
  local missing = {}
  for _, g in ipairs(M.rules) do
    if vim.fn.filereadable(base .. g.path) ~= 1 then
      missing[#missing + 1] = g.path
    end
  end
  if #missing == 0 then
    vim.health.ok("全部目标 health 文件都存在")
  else
    vim.health.warn(("有 %d 个目标文件不存在：%s"):format(#missing, table.concat(missing, "、")))
  end
end

return M
