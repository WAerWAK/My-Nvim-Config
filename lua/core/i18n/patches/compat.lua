-- =====================================================================
--  非汉化类补丁：第三方兼容性修复
-- =====================================================================
--  ⚠️ 这里放的不是翻译，而是**必需的兼容修复**。它们原来写在旧的
--     core/chinese.lua 里（混在汉化规则中），2026-10-05 重构时漏迁，
--     导致 telescope 预览 Markdown 等文件时报：
--       attempt to call field 'ft_to_lang' (a nil value)
--
--  背景：nvim-treesitter 切到 main 分支后移除了
--        `nvim-treesitter.parsers.ft_to_lang` 与
--        `nvim-treesitter.configs.is_enabled / get_module`，
--        而 telescope（0.1.x，2024-05 版本）仍在调用它们。
--  做法：改成探测式调用，缺失时优雅降级为普通语法高亮（只影响预览窗高亮）。
--        规则是幂等的——补丁成功后源码里不再有原文，重复启动会跳过。
-- =====================================================================

return {
  rules = {
    {
      path = "telescope.nvim/lua/telescope/previewers/utils.lua",
      note = "【兼容修复】预览窗 treesitter 高亮适配 main 分支（1 条）",
      replacements = {
        {
          table.concat({
            [[local treesitter_attach = function(bufnr, ft)]],
            [[  local lang = ts_parsers.ft_to_lang(ft)]],
            [[  if not ts_configs.is_enabled("highlight", lang, bufnr) then]],
            [[    return false]],
            [[  end]],
            [[]],
            [[  local config = ts_configs.get_module "highlight"]],
            [[  vim.treesitter.highlighter.new(ts_parsers.get_parser(bufnr, lang))]],
          }, "\n"),
          table.concat({
            [[local treesitter_attach = function(bufnr, ft)]],
            [[  -- 兼容 nvim-treesitter main 分支：ft_to_lang / is_enabled / get_module 均已移除，]],
            [[  -- 探测不到就返回 false，由调用方回退到普通语法高亮（仅影响预览窗高亮）]],
            [[  if type(ts_parsers.ft_to_lang) ~= "function" then]],
            [[    return false]],
            [[  end]],
            [[  local ok, lang = pcall(ts_parsers.ft_to_lang, ft)]],
            [[  if not ok or not lang then]],
            [[    return false]],
            [[  end]],
            [[  if type(ts_configs.is_enabled) == "function" and not ts_configs.is_enabled("highlight", lang, bufnr) then]],
            [[    return false]],
            [[  end]],
            [[]],
            [[  local config = type(ts_configs.get_module) == "function" and ts_configs.get_module "highlight" or {}]],
            [[  local okp, parser = pcall(ts_parsers.get_parser, bufnr, lang)]],
            [[  if not okp or not parser then]],
            [[    return false]],
            [[  end]],
            [[  vim.treesitter.highlighter.new(parser)]],
          }, "\n"),
        },
      },
    },
    {
      path = "telescope.nvim/lua/telescope/builtin/__files.lua",
      note = "【兼容修复】grep 结果高亮适配 main 分支（2 条）",
      replacements = {
        {
          table.concat({
            [[  local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")]],
            [[  if ts_ok then]],
            [[    filetype = ts_parsers.ft_to_lang(filetype)]],
            [[  end]],
          }, "\n"),
          table.concat({
            [[  local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")]],
            [[  if ts_ok and type(ts_parsers.ft_to_lang) == "function" then]],
            [[    -- 兼容 nvim-treesitter main 分支：ft_to_lang 已移除，取不到就沿用原 filetype]],
            [[    local lang_ok, lang = pcall(ts_parsers.ft_to_lang, filetype)]],
            [[    if lang_ok and lang then]],
            [[      filetype = lang]],
            [[    end]],
            [[  end]],
          }, "\n"),
        },
        {
          [[if parser_ok and query_ok and ts_ok and ts_configs.is_enabled("highlight", filetype, opts.bufnr) then]],
          [[if
    parser_ok
    and query_ok
    and ts_ok
    and type(ts_configs.is_enabled) == "function"
    and ts_configs.is_enabled("highlight", filetype, opts.bufnr)
  then]],
        },
      },
    },
  },
}
