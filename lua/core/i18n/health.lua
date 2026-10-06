-- =====================================================================
--  checkhealth（健康检查报告）汉化
-- =====================================================================
--  两条路径：
--    A. **插件**的 health 文件（nvim-lspconfig / nvim-treesitter /
--       render-markdown / LuaSnip 等）→ 直接用 i18n 补丁替换源码文案。
--    B. **本体**的 health 模块（vim.health / vim.lsp / provider / vim.pack /
--       vim.treesitter）→ **不改 nvim 安装目录**，而是在配置目录用同名模块
--       覆盖（`lua/vim/lsp/health.lua` 等）。rtp 里配置目录优先于运行时，
--       所以 `:checkhealth vim.lsp` 会加载我们的中文版。
--       覆盖文件的来源是 `scripts/health-core/`，首次运行时自动部署。
--
--  注：health 报告里的「分组名」（如 `vim.lsp`）保持英文——它们是标识符，
--      在 `:checkhealth vim.lsp` 里当参数用。
-- =====================================================================

local M = {
  rules = {},
}

-- ---------------- A. 插件 health 文案替换规则 ----------------
-- 由 scripts/i18n-health-gen.py 从子代理翻译结果生成，格式：
--   { path = "插件/相对路径", note = "...", replacements = { { [[原文]], [[译文]] } } }
local ok, plugin_rules = pcall(require, "core.i18n.patches.health")
if ok and plugin_rules and plugin_rules.rules then
  vim.list_extend(M.rules, plugin_rules.rules)
end

-- ---------------- B. 本体 health 模块覆盖 ----------------
-- 需要覆盖的本体模块（相对 runtime/lua 的路径）
-- 注：`vim/treesitter/health.lua` 不在列表里——它的输出全是分组名或含 %s 占位符
--     的串，按汉化策略（不改占位符串、不译分组名）没有可替换内容，无需覆盖。
M.core_modules = {
  "vim/health/health.lua",
  "vim/lsp/health.lua",
  "vim/provider/health.lua",
  "vim/pack/health.lua",
}

--- 找到 health-core 源目录（配置目录优先，其次跟随本模块所在仓库）
local function find_src_dir()
  local candidates = {
    vim.fn.stdpath("config") .. "/scripts/health-core",
    -- 本文件位于 <仓库>/lua/core/i18n/health.lua，回推三级得到 <仓库>
    (debug.getinfo(1, "S").source:sub(2):match("^(.*)[/\\]lua[/\\]core[/\\]i18n[/\\][^/\\]*$") or "")
      .. "/scripts/health-core",
  }
  for _, dir in ipairs(candidates) do
    if dir ~= "" and vim.fn.isdirectory(dir) == 1 then
      return dir
    end
  end
  return nil
end

--- 把 scripts/health-core 下的中文健康检查模块部署到配置目录
---@return integer deployed, string[] failed
function M.deploy_core()
  local src_dir = find_src_dir()
  if not src_dir then
    return 0, {}
  end
  local deployed, failed = 0, {}
  for _, rel in ipairs(M.core_modules) do
    local src = src_dir .. "/" .. rel
    local dst = vim.fn.stdpath("config") .. "/lua/" .. rel
    if vim.fn.filereadable(src) == 1 then
      local content = io.open(src, "rb")
      if content then
        local data = content:read("*a")
        content:close()
        vim.fn.mkdir(vim.fn.fnamemodify(dst, ":h"), "p")
        local out = io.open(dst, "wb")
        if out then
          out:write(data)
          out:close()
          deployed = deployed + 1
        else
          failed[#failed + 1] = rel .. "（写入失败）"
        end
      end
    end
  end
  return deployed, failed
end

-- =====================================================================
--  :checkhealth 入口
-- =====================================================================
--  ⚠️ 必须提供 M.check：nvim 0.12 的 `:checkhealth`（无参数）会扫描
--     runtimepath 下所有可 require 的模块并调用 `require(name).check()`。
function M.check()
  vim.health.start("core.i18n.health（本体健康检查汉化）")

  local src_dir = find_src_dir()
  if not src_dir then
    vim.health.warn("找不到 scripts/health-core（本体 health 覆盖源）")
    return
  end

  local deployed, missing = 0, {}
  for _, rel in ipairs(M.core_modules) do
    local dst = vim.fn.stdpath("config") .. "/lua/" .. rel
    if vim.fn.filereadable(dst) == 1 then
      deployed = deployed + 1
    else
      missing[#missing + 1] = rel
    end
  end

  vim.health.ok(("本体 health 覆盖源：%s"):format(src_dir))
  if #missing == 0 then
    vim.health.ok(("已部署 %d/%d 个中文 health 模块（:checkhealth vim.* 显示中文）"):format(
      deployed, #M.core_modules))
  else
    vim.health.warn(("有 %d 个未部署：%s（重新保存配置或执行 :I18nPatch）"):format(
      #missing, table.concat(missing, "、")))
  end

  local pr = M.rules or {}
  vim.health.info(("插件 health 文案规则：%d 组"):format(#pr))
end

return M
