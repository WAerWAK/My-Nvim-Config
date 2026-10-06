-- =====================================================================
--  lazy.nvim / mason / noice / telescope / which-key 健康检查汉化
-- =====================================================================
--  ⚠️ 规则必须带**引号边界**，且生成后要用 nvim 做 loadfile 语法校验：
--     早期版本用裸文本匹配，把 `state.validate()` 里的 valid 也换掉，
--     直接把 render-markdown 的 health.lua 改成非法 Lua（已修复并记档）。
--  ⚠️ 顺序敏感：前缀重叠的串必须「长的在前」，例如
--     ": installed" ⊂ ": installed but should not conflict"
--  详见 scripts/i18n-health-gen.py 的生成逻辑。
-- =====================================================================

return {
  rules = {
    {
      path = "lazy.nvim/lua/lazy/health.lua",
      note = "lazy.nvim 健康检查文案（11 条，带引号边界）",
      replacements = {
        { [['failed to get version of {%s}\n%s']], [['获取 {%s} 版本失败\n%s']] },
        { [['`%s` version `%s` needed, but found `%s`']], [['需要 `%s` 版本 `%s`，但当前是 `%s`']] },
        { [['{%s} %snot installed']], [['{%s} %s未安装']] },
        { [['no existing packages found by other package managers']], [['没有发现其它包管理器安装的插件']] },
        { [['found existing packages at `']], [['在以下位置发现已存在的插件：`']] },
        { [['Found paths on the rtp from another plugin manager `']], [['runtimepath 里有来自其它插件管理器的路径：`']] },
        { [['please remove the file `']], [['请删除文件 `']] },
        { [['packer_compiled.lua not found']], [['未发现 packer_compiled.lua']] },
        { [['No plugins loaded. Did you forget to run `require("lazy").setup()`?']], [['没有加载任何插件。是否忘记执行 `require("lazy").setup()`？']] },
        { [['Issues were reported when loading your specs:']], [['加载插件清单时报告了以下问题：']] },
        { [['checking `hererocks` installation']], [['正在检查 `hererocks` 安装']] },
        { [['checking `luarocks` installation']], [['正在检查 `luarocks` 安装']] },
        { [['no plugins require `luarocks`, so you can ignore any warnings below']], [['没有插件依赖 `luarocks`，下面的警告可以忽略']] },
        { [['you have some plugins that require `luarocks`:\n']], [['以下插件依赖 `luarocks`：\n']] },
        { [['luarocks disabled']], [['luarocks 已禁用']] },
        { [["Lazy won't be able to install plugins that require `luarocks`."]], [["lazy 无法安装依赖 `luarocks` 的插件。"]] },
        { [["Here's what you can do:"]], [['可以尝试：']] },
        { [[' - fix your `luarocks` installation']], [[' - 修复你的 `luarocks` 安装']] },
        { [[' - disable *hererocks* with `opts.rocks.hererocks = false`']], [[' - 用 `opts.rocks.hererocks = false` 禁用 *hererocks*']] },
        { [[' - enable `hererocks` with `opts.rocks.hererocks = true`']], [[' - 用 `opts.rocks.hererocks = true` 启用 `hererocks`']] },
        { [[' - disable `luarocks` support completely with `opts.rocks.enabled = false`']], [[' - 用 `opts.rocks.enabled = false` 完全禁用 `luarocks` 支持']] },
        { [['}: unknown key <']], [['}：未知的配置键 <']] },
      },
    },
  },
}
