-- =====================================================================
--  界面汉化入口
-- =====================================================================
--  本文件只做三件事：
--    1. 装载消息翻译，把 vim.notify 接到翻译链路上
--    2. 启动后延迟执行插件界面 patch（规则见 core/i18n/patches/）
--    3. 注册 :I18nPatch / :I18nAudit / :I18nRules 三个命令
--
--  具体实现与规则都拆到了 core/i18n/ 下：
--    core/i18n/init.lua          执行引擎（含语法校验 + 自动放弃改写）
--    core/i18n/words.lua         统一词汇表
--    core/i18n/messages.lua      系统消息正则翻译
--    core/i18n/patches/*.lua     按插件分组的界面文本规则
--
--  为什么本体消息只能用正则：Neovim 把 E/W 消息写死在编译期，官方 Windows
--  构建未链接 libintl，gettext 路径被编译掉，无法通过语言包整体切换。
-- =====================================================================

local M = {}

local i18n = require("core.i18n")

-- 词汇表对外暴露（其它配置用 require("core.chinese").t 取用）
M.t = require("core.i18n.words")

-- 系统消息翻译
local patterns = require("core.i18n.messages")

function M.translate(msg)
  if type(msg) ~= "string" or #msg > 120 then
    return msg
  end
  for _, p in ipairs(patterns) do
    local out, n = msg:gsub(p[1], p[2])
    if n > 0 then
      return out
    end
  end
  return msg
end

-- 把翻译接到通知链路上（noice / notify 都走 vim.notify）
-- ⚠️ 与 noice.nvim 的冲突（2026-10-06 实测）：
--     noice 会检查 `vim.notify` 是否被别的插件顶掉（noice/health.lua 的
--     `vim.notify has been overwritten by another plugin?`），而本模块包装
--     vim.notify 正好会触发这个告警。
--   处理办法：**不在启动早期包装**，改为在 noice 完成初始化之后再包一层。
--     1) 等 VimEnter 之后延迟 1.2s（noice 的 setup 挂在 VimEnter 后 schedule）
--     2) 支持 VeryLazy 事件再补一次
--     3) 用弱键表保证同一个原函数只包一层（不会层层嵌套）
--   若某天想彻底避免该告警，可在 plugins/noice.lua 里设 notify.enabled = false
--   （代价：失去 noice 的通知美化）。
local wrapped_of = setmetatable({}, { __mode = "k" })
local function install_notify_hook()
  local inner = vim.notify
  if type(inner) ~= "function" then
    return
  end
  local existing = wrapped_of[inner]
  if existing then
    vim.notify = existing
    return
  end
  local wrapped = function(msg, level, opts)
    return inner(M.translate(msg), level, opts)
  end
  wrapped_of[inner] = wrapped
  vim.notify = wrapped
end

--- 延迟安装：等 noice 接管完 vim.notify 之后再包
--- @param delay? number 默认 1500ms（noice 的 setup 挂在 VimEnter 后 schedule，
---        实测启动流程跑完通常 <1.5s，太早包会触发 noice 的覆盖告警）
function M.install_notify_hook_later(delay)
  vim.defer_fn(function()
    install_notify_hook()
  end, delay or 1500)
end

M.install_notify_hook = install_notify_hook
M.install_notify_hook_later()

-- =====================================================================
--  命令行消息（:E492 这类）也走一遍翻译
-- =====================================================================
--  vim.notify 只覆盖"通知"路径；用户在命令行输错命令时，消息是 nvim 用
--  nvim_echo 直接打到消息区的（noice 会接管渲染，但同样经过这个 API）。
--  这里保守地包一层：只翻译「第一个块是字符串」的简单形态，参数结构、
--  历史记录、错误标志全部原样透传；任何异常都回退到原始调用。
--  可用 `vim.g.i18n_echo_hook = false` 关闭。
local function install_echo_hook()
  if vim.g.i18n_echo_hook == false or vim.g._i18n_echo_installed then
    return
  end
  vim.g._i18n_echo_installed = true
  local orig = vim.api.nvim_echo
  vim.api.nvim_echo = function(chunks, history, opts)
    local ok, out = pcall(function()
      if type(chunks) ~= "table" then
        return chunks
      end
      local copy = nil
      for i, c in ipairs(chunks) do
        if type(c) == "table" and type(c[1]) == "string" then
          local t = M.translate(c[1])
          if t ~= c[1] then
            copy = copy or vim.deepcopy(chunks)
            copy[i][1] = t
          end
        end
      end
      return copy or chunks
    end)
    return orig(ok and out or chunks, history, opts)
  end
end
M.install_echo_hook = install_echo_hook
install_echo_hook()

-- 对外保留旧接口，避免其它配置调用失效
M.patch_plugins = function()
  local r = i18n.patch_all()
  return r.files, vim.tbl_map(function(f)
    return f.path .. "（" .. f.reason .. "）"
  end, r.failed)
end

i18n.setup()

-- 中文帮助：为 doc/ 生成 tags-cn（'helplang' 已设为 cn，见 core/options.lua）
pcall(function()
  require("core.i18n.helpdoc").setup()
end)

vim.defer_fn(function()
  local r = i18n.patch_all()
  -- 只在真的有失败时提示；正常情况（已汉化）静默通过
  if #r.failed > 0 then
    local lines = { ("界面汉化有 %d 项未生效："):format(#r.failed) }
    for _, f in ipairs(r.failed) do
      lines[#lines + 1] = ("  %s（%s）"):format(f.path, f.reason)
    end
    lines[#lines + 1] = "排查：:I18nRules 查看规则，:messages 看历史"
    vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN)
  end
end, 1500)

return M
