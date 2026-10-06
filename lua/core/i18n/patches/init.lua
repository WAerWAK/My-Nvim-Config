-- =====================================================================
--  汉化规则汇总表
-- =====================================================================
--  每个文件负责一个插件，格式：
--      return {
--        rules = {
--          { path = "插件名/相对 lazy 目录的路径", note = "说明",
--            replacements = { { [[英文原文]], [[中文译文]] }, ... } },
--        },
--      }
--
--  ⚠️ 只替换**显示用**文本（desc / title / prompt / label / 纯提示串）。
--     键名、命令名、字段名、正则、用于比较的常量一律不动。
--     判断方法：这个字符串会不会被回传给插件做判断？会 → 不能动。
-- =====================================================================

local M = {
  rules = {},
}

-- 自动补引号变体：
--   规则里若用单引号包住原文（如 [['foo bar']]），源码可能写成双引号 "foo bar"，
--   手写两种写法容易漏（这坑踩过：lazy/mason 的 health 规则全部失配）。
--   这里统一给「以单引号开头结尾」的规则再补一条双引号版本。
--   注意：只对**完整带引号边界**的规则生效（形如 'xxx'），不会影响
--   [[desc = "xxx"]] 这类已经带具体上下文的规则。
local function expand_quotes(rules)
  local out = {}
  for _, g in ipairs(rules) do
    local reps = {}
    for _, r in ipairs(g.replacements or {}) do
      reps[#reps + 1] = r
      local o, n = r[1], r[2]
      local o1, o2 = o:sub(1, 1), o:sub(-1)
      local n1, n2 = n:sub(1, 1), n:sub(-1)
      if o1 == "'" and o2 == "'" and n1 == "'" and n2 == "'" then
        reps[#reps + 1] = { '"' .. o:sub(2, -2) .. '"', '"' .. n:sub(2, -2) .. '"' }
      elseif o1 == '"' and o2 == '"' and n1 == '"' and n2 == '"' then
        reps[#reps + 1] = { "'" .. o:sub(2, -2) .. "'", "'" .. n:sub(2, -2) .. "'" }
      end
    end
    out[#out + 1] = { path = g.path, note = g.note, replacements = reps }
  end
  return out
end

local loaded = {}

for _, mod in ipairs({
  -- 非汉化：第三方兼容性修复（务必保留，见文件头注释）
  "core.i18n.patches.compat",
  "core.i18n.patches.lazy",
  "core.i18n.patches.mason",
  "core.i18n.patches.telescope",
  "core.i18n.patches.telescope-titles",
  "core.i18n.patches.telescope-msgs",
  "core.i18n.patches.telescope-git",
  "core.i18n.patches.telescope-whichkey",
  "core.i18n.patches.nvim-tree",
  "core.i18n.patches.nvim-tree-keys",
  "core.i18n.patches.nvim-tree-cmds",
  "core.i18n.patches.which-key",
  "core.i18n.patches.aerial",
  "core.i18n.patches.aerial-cmds",
  "core.i18n.patches.aerial-extra",
  "core.i18n.patches.gitsigns",
  "core.i18n.patches.gitsigns-extra",
  "core.i18n.patches.noice",
  "core.i18n.patches.noice-render",
  "core.i18n.patches.lsp-cmds",
  "core.i18n.patches.treesitter",
  "core.i18n.patches.small",
  "core.i18n.patches.small-extra",
  "core.i18n.patches.final",
  "core.i18n.patches.health",
  "core.i18n.patches.health-extra",
  "core.i18n.patches.health-extra2",
  "core.i18n.patches.misc",
}) do
  local ok, part = pcall(require, mod)
  if ok and part and part.rules then
    vim.list_extend(loaded, part.rules)
  else
    vim.notify(("汉化规则加载失败：%s（%s）"):format(mod, tostring(part)), vim.log.levels.ERROR)
  end
end

M.rules = expand_quotes(loaded)

-- =====================================================================
--  :checkhealth 入口
-- =====================================================================
--  nvim 0.12 的 `:checkhealth`（不带参数）会扫描 runtimepath 下所有可 require
--  的模块并调用 `require(name).check()`，缺 check 就会报
--    ERROR Failed to run healthcheck for "core.i18n.patches" plugin
--  所以这里提供一个真实的检查：报规则规模 + 失败日志统计。
function M.check()
  vim.health.start("core.i18n.patches（汉化规则表）")

  local total = 0
  for _, g in ipairs(M.rules) do
    total = total + #g.replacements
  end
  vim.health.ok(("%d 组规则 / %d 条替换"):format(#M.rules, total))

  -- 统计日志里最近一轮的失败项（若有）
  local log = vim.fn.stdpath("state") .. "/i18n.log"
  if vim.fn.filereadable(log) == 1 then
    local fails = {}
    for line in io.lines(log) do
      local n = line:match("^%[.-%]%s*本轮：.-失败%s*(%d+)%s*项")
      if n then
        fails[#fails + 1] = tonumber(n)
      end
    end
    local last = fails[#fails]
    if last == nil then
      vim.health.info("日志里还没有「本轮」记录（首次启动后会出现）")
    elseif last == 0 then
      vim.health.ok("最近一轮汉化：失败 0 项")
    else
      vim.health.warn(("最近一轮汉化失败 %d 项，详见 %s"):format(last, log))
    end
  else
    vim.health.info("还没有汉化日志（启动一次后会生成）")
  end

  vim.health.info("排查命令：:I18nRules 列出规则，:I18nPatch 立即执行")
end

return M
