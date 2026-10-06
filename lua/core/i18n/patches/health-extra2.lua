-- =====================================================================
--  mason / noice / telescope / which-key 健康检查汉化（补充）
-- =====================================================================
--  与 health-extra.lua 同样的安全约定：**带引号边界** + 生成时用 nvim
--  做 loadfile 语法校验，避免把标识符子串误替换（历史上出过一次）。
--  ⚠️ 顺序敏感：前缀重叠的串（如 "No " 与 "No overlapping keymaps found"）
--     已按「长在前」排列。
-- =====================================================================

return {
  rules = {
    {
      path = "mason.nvim/lua/mason/health.lua",
      note = "mason 健康检查文案（1 条）",
      replacements = {
        { [['neovim version < 0.10.0']], [['Neovim 版本低于 0.10.0']] },
      },
    },
    {
      path = "noice.nvim/lua/noice/health.lua",
      note = "noice 健康检查文案（13 条）",
      replacements = {
        -- 长串在前（前缀重叠：前两条是后两条的前缀）
        { [['Noice requires Neovim >= 0.9.0']], [['Noice 需要 Neovim 0.9.0 或更高版本']] },
        { [['Noice needs Neovim >= 0.9.0 (nightly)']], [['Noice 需要 Neovim 0.9.0+（nightly）']] },
        { [['*Neovim* >= 0.11 is highly recommended, since it fixes some issues related to `vim.ui_attach`']], [['强烈建议使用 *Neovim* 0.11+，它修复了一些与 `vim.ui_attach` 相关的问题']] },
        { [['*Neovim* >= 0.9.0']], [['*Neovim* 0.9.0 及以上']] },
        { [["You have enabled 'lazyredraw' (see `:h 'lazyredraw'`)\\nThis is only meant to be set temporarily.\\nYou'll experience issues using Noice."]], [["你启用了 'lazyredraw'（见 `:h 'lazyredraw'`）\\n该选项只应临时设置。\\n否则使用 Noice 时会遇到问题。"] ] },
        { [["*vim.go.lazyredraw* is not enabled"]], [["*vim.go.lazyredraw* 未启用"]] },
        { [['Noice needs `snacks.nvim` or `nvim-notify` for routes using the `notify` view']], [['使用 `notify` 视图的路由需要 `snacks.nvim` 或 `nvim-notify`']] },
        { [['You added `S` to `vim.opt.shortmess`. Search count messages will not be handled by Noice.']], [['你在 `vim.opt.shortmess` 中加了 `S`，搜索计数消息将不由 Noice 处理。']] },
        { [["You're using a GUI that uses "]], [["你使用的是一个 GUI，它使用 "]] },
        { [["You're not using a GUI"]], [["你没有使用 GUI"]] },
        { [["You're using a GUI that should work ok"]], [["你使用的 GUI 可以正常工作"]] },
      },
    },
    {
      path = "which-key.nvim/lua/which-key/health.lua",
      note = "which-key 健康检查文案（11 条）",
      replacements = {
        -- 长串在前
        { [['Overlapping keymaps are only reported for informational purposes.\\n']], [['重叠键位的报告仅供参考。\\n']] },
        { [['Duplicate mappings are only reported for informational purposes.\\n']], [['重复映射的报告仅供参考。\\n']] },
        { [['Most of these checks are for informational purposes only.\\n']], [['这些检查大多仅供参考。\\n']] },
        { [['No overlapping keymaps found']], [['没有发现重叠的键位']] },
        { [['No duplicate mappings found']], [['没有发现重复的映射']] },
        { [['No issues reported']], [['没有报告问题']] },
        { [['Checking for issues with your mappings']], [['正在检查键位映射的问题']] },
        { [['Checking for duplicate mappings']], [['正在检查重复的映射']] },
        { [['checking for overlapping keymaps']], [['正在检查重叠的键位']] },
        { [['Checking your config']], [['正在检查你的配置']] },
        { [['Keymap icon support will be limited.']], [['键位图标支持将受限。']] },
        { [['In mode `']], [['在模式 `']] },
        { [['Duplicates for <']], [['重复项：<']] },
      },
    },
  },
}
