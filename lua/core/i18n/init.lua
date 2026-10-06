-- =====================================================================
--  i18n —— 插件界面汉化的执行引擎
-- =====================================================================
--  设计要点：
--    1. 规则集中放在 lua/core/i18n/patches.lua，按插件分区，便于增删
--    2. 替换后**必须先通过 Lua 语法校验**才落盘，校验不过自动放弃改写
--       （杜绝"汉化把插件源码改坏导致 nvim 报错"这一类事故）
--    3. 全程二进制读写，不改变文件行尾（CRLF 保持 CRLF）
--    4. 幂等：源码里找不到原文就跳过，反复启动不会重复替换
--    5. 提供 audit() 扫描仍含英文界面文本的插件文件，用于追踪汉化进度
-- =====================================================================

local M = {}

local function logpath()
  return vim.fn.stdpath("state") .. "/i18n.log"
end

local function log(line)
  local fd = io.open(logpath(), "a")
  if fd then
    fd:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. line .. "\n")
    fd:close()
  end
end

-- Lua 模式特殊字符转义（用于 gsub 的 pattern）
local function escape_pat(s)
  return (s:gsub("%p", "%%%0"))
end

-- Lua 替换串特殊字符转义（用于 gsub 的 repl）
local function escape_repl(s)
  return (s:gsub("%%", "%%%%"))
end

-- 校验改写后的 Lua 源码能否编译；不能则整份放弃（fail-safe）
local function syntax_ok(content, chunkname)
  local fn, err = load(content, "@" .. chunkname)
  if fn then
    return true
  end
  return false, err
end

local function apply_rules(content, rules)
  -- 按原文长度降序执行：`opts("Open")` 与 `opts("Open Preview")` 这类
  -- 前缀包含关系下，先替换长串才能避免短串抢先命中导致规则失效。
  local sorted = {}
  for i, r in ipairs(rules) do
    sorted[i] = r
  end
  table.sort(sorted, function(a, b)
    return #a[1] > #b[1]
  end)

  local changed = 0
  for _, r in ipairs(sorted) do
    if content:find(r[1], 1, true) then
      local new, n = content:gsub(escape_pat(r[1]), escape_repl(r[2]))
      if n > 0 then
        content = new
        changed = changed + n
      end
    end
  end
  return content, changed
end

-- 读取整个文件（二进制模式，保留行尾）
local function read_file(path)
  local fd = io.open(path, "rb")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  return content
end

local function write_file(path, content)
  local fd = io.open(path, "wb")
  if not fd then
    return false
  end
  fd:write(content)
  fd:close()
  return true
end

--- 对单个文件应用规则集
---@param path string 绝对路径
---@param rules table {原文, 译文} 列表
---@return integer applied 实际替换条数；nil + string 表示出错
function M.patch_file(path, rules)
  if vim.fn.filereadable(path) ~= 1 then
    return nil, "文件不存在"
  end
  local content = read_file(path)
  if not content then
    return nil, "读取失败"
  end

  local new, count = apply_rules(content, rules)
  if count == 0 then
    return 0 -- 已汉化或规则失配，无需处理
  end

  -- 关键安全网：先用 Lua 语法校验，避免把插件源码改坏
  if path:sub(-4) == ".lua" then
    local ok, err = syntax_ok(new, path)
    if not ok then
      log(("语法校验失败，已放弃改写 %s：%s"):format(path, tostring(err)))
      return nil, "语法校验失败（已跳过，原文件未改动）"
    end
  end

  if not write_file(path, new) then
    return nil, "写入失败"
  end
  return count
end

--- 应用全部补丁规则
---@return table 结果统计 { applied, files, failed = { {path, reason} } }
function M.patch_all()
  local base = vim.fn.stdpath("data") .. "/lazy/"
  local rules = require("core.i18n.patches").rules
  local applied, files, failed = 0, 0, {}

  for _, group in ipairs(rules) do
    local n, err = M.patch_file(base .. group.path, group.replacements)
    if err then
      failed[#failed + 1] = { path = group.path, reason = err }
    elseif n and n > 0 then
      applied = applied + n
      files = files + 1
      log(("替换 %d 处：%s"):format(n, group.path))
    end
  end

  if applied > 0 or #failed > 0 then
    log(("本轮：文件 %d 个，替换 %d 处，失败 %d 项"):format(files, applied, #failed))
    for _, f in ipairs(failed) do
      log(("  失败 %s：%s"):format(f.path, f.reason))
    end
  end

  -- checkhealth 的「本体模块覆盖」：把 scripts/health-core 下的中文 health
  -- 模块部署到配置目录（不改 nvim 安装目录，靠 rtp 优先级生效）
  local hok, health = pcall(require, "core.i18n.health")
  if hok and health then
    local deployed, dfailed = health.deploy_core()
    if deployed > 0 then
      log(("checkhealth 本体模块覆盖 %d 个"):format(deployed))
    end
    for _, f in ipairs(dfailed or {}) do
      failed[#failed + 1] = { path = f, reason = "health 模块部署失败" }
    end
  end

  return { applied = applied, files = files, failed = failed }
end

-- =====================================================================
--  汉化审计：扫描插件源码里是否还有英文界面文本
-- =====================================================================

-- 值是给人看的界面字段
local AUDIT_FIELDS = {
  "desc", "desc_plugin", "title", "prompt", "prompt_title",
  "results_title", "msg", "message", "label", "header", "info",
}

local function is_ui_value(v)
  if #v < 3 or #v > 120 then
    return false
  end
  if v:find("[%w_][%s,;:!%?%.%(%)'\"]+[%a]") == nil then
    return false -- 没有"英文词组"，多半是标识符
  end
  -- 明显是逻辑用的值，排除
  local skip = {
    ["n"] = true, ["v"] = true, ["i"] = true, ["x"] = true, ["t"] = true,
    ["c"] = true, ["s"] = true, ["o"] = true, ["%"] = true, ["lua"] = true,
    ["vim"] = true, ["true"] = true, ["false"] = true, ["nil"] = true,
  }
  if skip[v] then
    return false
  end
  if v:find("^[%w_%.%-/]+$") and not v:find("%s") then
    return false -- 单个词/路径/标识符
  end
  return true
end

local function list_lua_files(dir, out)
  local handle = vim.uv.fs_scandir(dir)
  if not handle then
    return out
  end
  while true do
    local name, t = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end
    local p = dir .. "/" .. name
    if t == "directory" then
      if name ~= "tests" and name ~= "test" then
        list_lua_files(p, out)
      end
    elseif name:sub(-4) == ".lua" then
      out[#out + 1] = p
    end
  end
  return out
end

--- 扫描指定插件目录下剩余的英文界面文本
---@param plugins string[]|nil 插件名列表，nil = 全部已装的插件
---@return table[] { plugin, file, line, text }
function M.audit(plugins)
  local base = vim.fn.stdpath("data") .. "/lazy/"
  local dirs = {}
  if plugins then
    for _, p in ipairs(plugins) do
      dirs[#dirs + 1] = { p, base .. p .. "/lua" }
    end
  else
    local handle = vim.uv.fs_scandir(base)
    if handle then
      while true do
        local name, t = vim.uv.fs_scandir_next(handle)
        if not name then
          break
        end
        if t == "directory" then
          dirs[#dirs + 1] = { name, base .. name .. "/lua" }
        end
      end
    end
  end

  -- 预编译一行里可能出现的所有字段模式
  local patterns = {}
  for _, f in ipairs(AUDIT_FIELDS) do
    patterns[#patterns + 1] = { f, f .. "%s*=%s*[\"']([^\"']+)[\"']" }
  end

  local findings, file_count = {}, 0
  for _, d in ipairs(dirs) do
    local plugin, root = d[1], d[2]
    if vim.fn.isdirectory(root) == 1 then
      local files = list_lua_files(root, {})
      for _, path in ipairs(files) do
        local content = read_file(path)
        if content and content:find("[\228-\233]") == nil then
          -- 整个文件一个中文都没有，才值得逐行扫
          file_count = file_count + 1
          local ln = 0
          for line in content:gmatch("[^\n]+") do
            ln = ln + 1
            if not line:match("^%s*%-%-") then
              for _, p in ipairs(patterns) do
                local v = line:match(p[2])
                if v and is_ui_value(v) then
                  findings[#findings + 1] = {
                    plugin = plugin,
                    file = path:sub(#base + 1),
                    line = ln,
                    field = p[1],
                    text = v,
                  }
                end
              end
            end
          end
        end
      end
    end
  end
  return findings, file_count
end

--- 打印审计结果（配合 :I18nAudit 使用）
---@param plugins string[]|nil
function M.audit_report(plugins)
  local findings, file_count = M.audit(plugins)
  if #findings == 0 then
    print(("汉化审计：扫描 %d 个未含中文的文件，未发现英文界面文本。"):format(file_count))
    return
  end
  local by_plugin, order = {}, {}
  for _, f in ipairs(findings) do
    if not by_plugin[f.plugin] then
      by_plugin[f.plugin] = { n = 0, fields = {} }
      order[#order + 1] = f.plugin
    end
    local e = by_plugin[f.plugin]
    e.n = e.n + 1
    e.fields[f.field] = (e.fields[f.field] or 0) + 1
  end
  table.sort(order, function(a, b)
    return by_plugin[a].n > by_plugin[b].n
  end)

  print(("汉化审计：%d 条英文界面文本，分布在 %d 个插件"):format(#findings, #order))
  print("  插件              条数   字段分布")
  for _, p in ipairs(order) do
    local e = by_plugin[p]
    local parts = {}
    for k, v in pairs(e.fields) do
      parts[#parts + 1] = ("%s=%d"):format(k, v)
    end
    print(("  %-16s %4d   %s"):format(p, e.n, table.concat(parts, " ")))
  end
  print("  明细见 :lua require('core.i18n').write_audit()")
end

--- 把审计明细写到文件，便于逐条处理
function M.write_audit(plugins)
  local findings = M.audit(plugins)
  local path = vim.fn.stdpath("state") .. "/i18n-audit.txt"
  local fd = io.open(path, "w")
  if not fd then
    print("无法写入 " .. path)
    return
  end
  for _, f in ipairs(findings) do
    fd:write(("%s:%d  [%s] %s\n"):format(f.file, f.line, f.field, f.text))
  end
  fd:close()
  print(("已写出 %d 条明细 → %s"):format(#findings, path))
  return path
end

--- 列出所有规则及其目标文件（核对用）
function M.list_rules()
  local rules = require("core.i18n.patches").rules
  local base = vim.fn.stdpath("data") .. "/lazy/"
  local n, miss = 0, 0
  for _, g in ipairs(rules) do
    local ok = vim.fn.filereadable(base .. g.path) == 1
    if not ok then
      miss = miss + 1
    end
    print(("%s %-70s %2d 条  %s"):format(
      ok and "OK " or "!! ",
      g.path,
      #g.replacements,
      g.note or ""
    ))
    n = n + #g.replacements
  end
  print(("共 %d 组规则 / %d 条替换；%d 个目标文件不存在"):format(#rules, n, miss))
end

--- 注册用户命令
function M.setup()
  vim.api.nvim_create_user_command("I18nAudit", function(args)
    M.audit_report(args.fargs and #args.fargs > 0 and args.fargs or nil)
  end, { nargs = "*", desc = "审计插件界面里剩余的英文文本" })

  vim.api.nvim_create_user_command("I18nRules", function()
    M.list_rules()
  end, { desc = "列出全部汉化规则及目标文件" })

  vim.api.nvim_create_user_command("I18nPatch", function()
    local r = M.patch_all()
    print(("汉化补丁：改写 %d 个文件、共 %d 处，失败 %d 项"):format(r.files, r.applied, #r.failed))
    for _, f in ipairs(r.failed) do
      print(("  失败：%s（%s）"):format(f.path, f.reason))
    end
  end, { desc = "立即执行汉化补丁" })
end

-- =====================================================================
--  :checkhealth 入口
-- =====================================================================
--  ⚠️ 必须提供 M.check：nvim 0.12 的 `:checkhealth`（无参数时）会扫描
--     runtimepath 下所有可 require 的模块并调用 `require(name).check()`，
--     没有 check 就会报
--       ERROR Failed to run healthcheck for "core.i18n" plugin
--       attempt to call field 'check' (a nil value)
function M.check()
  vim.health.start("core.i18n（界面汉化）")

  local rules = require("core.i18n.patches").rules
  local count = 0
  for _, g in ipairs(rules) do
    count = count + #g.replacements
  end

  vim.health.ok(("汉化规则：%d 组 / %d 条"):format(#rules, count))
  vim.health.ok(("系统消息规则：%d 条"):format(#require("core.i18n.messages")))

  -- 抽查：是否有目标文件缺失
  local base = vim.fn.stdpath("data") .. "/lazy/"
  local missing = {}
  for _, g in ipairs(rules) do
    if vim.fn.filereadable(base .. g.path) ~= 1 then
      missing[#missing + 1] = g.path
    end
  end
  if #missing == 0 then
    vim.health.ok("全部规则的目标文件都存在")
  else
    vim.health.warn(("有 %d 个规则的目标文件不存在（插件可能已卸载）：%s"):format(
      #missing, table.concat(vim.list_slice(missing, 1, 5), "、")))
  end

  -- 日志文件
  local log = vim.fn.stdpath("state") .. "/i18n.log"
  if vim.fn.filereadable(log) == 1 then
    vim.health.info("汉化日志：" .. log)
  end
end

return M
