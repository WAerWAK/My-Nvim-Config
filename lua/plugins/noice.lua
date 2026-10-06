-- noice.nvim 配置：命令行 / 消息界面
--
-- ================== 排查出来的两个关键机制 ==================
-- （2026-10-06 通过读源码 + 实测确认，之前配置没生效就是踩了这两点）
--
-- ① 路由过滤器 `find` 匹配的是 message:content() 的**原始文本**，
--    而汉化（translate）发生在**之后的 format 渲染阶段**。
--    ⇒ 这里必须用英文原文匹配（`find = "written"`）。
--      写中文「已保存」永远匹配不上（这就是之前提示消失的原因）。
--
-- ② noice 的 route 如果**不写 view**，会被内部当成 `skip = true`
--    （见 noice/message/router.lua 的 M.add：
--     `if ret.view == nil then ret.opts.skip = true end`）。
--    ⇒ 想让提示可见，必须显式指定 view。
--    实测 `view = "cmdline"` 会被"命令结束后的清屏"覆盖掉（它本来是给
--    `:!cmd` 输出用的），所以这里用 `view = "mini"`：
--    右下角显示、2 秒后自动消失，常驻可读又不弹卡片。
--    （`mini` 也是 noice 自己给默认视图设的 fallback，见 config/views.lua:68）
--
-- 另外 noice.setup() 内部是「VimEnter 之后再 vim.schedule 执行 load」，
-- 如果调用时机不对（例如插件尚未加载完），配置会静默失效。因此这里
-- 把配置封装为 apply()，既在启动时尝试，也在 VeryLazy 后再兜底尝试一次。
-- =====================================================================

local M = {}

--- 应用 noice 配置（可重复调用，只生效一次）
local function apply()
  if M._applied then
    return true
  end
  local ok, noice = pcall(require, "noice")
  if not ok or type(noice) ~= "table" or type(noice.setup) ~= "function" then
    return false -- 插件还没加载，等下次
  end

  noice.setup({
    -- ⚠️ 为什么不接管 vim.notify（2026-10-06 决定，为消除启动红框）：
    --   noice 有个每秒运行的占用检查（health.checker -> Health.check），
    --   其中一项要求 `vim.notify` **严格等于** noice 自己的实现；
    --   而本配置的汉化模块需要包装 vim.notify 来翻译插件通知，
    --   于是每次检查都会报红框：
    --     `vim.notify` has been overwritten by another plugin?
    --   noice 自己的建议就是设 `config.notify.enabled = false`。
    --   ⇒ 副作用**仅限**：vim.notify 不再由 noice 接管（失去它对该调用的美化），
    --     汉化包装照常生效，那 13 条通知翻译不受影响；红框消失。
    --   想恢复原状：把下面这行删掉即可（红框会回来）。
    notify = { enabled = false },
    routes = {
      -- 保存提示：按用户要求保持**静默**（2026-10-06 决定，不再显示）
      -- 注：noice 的 route 不写 view 就等于 skip = true，这正是想要的静默效果。
      { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      -- 复制（yank）提示同样静默
      { filter = { event = "msg_show", kind = "", find = "yanked" }, opts = { skip = true } },
      -- 下面两条保留显示（搜索类提示有用），用常驻可读的 mini 视图
      {
        filter = { event = "msg_show", kind = "", find = "search wrapped" },
        view = "mini",
      },
      {
        filter = { event = "msg_show", kind = "", find = "Pattern not found" },
        view = "mini",
      },
      -- 参考：想显示保存提示就把上面 written 那条改成
      --   { filter = {...find = "written"}, view = "mini" }（右下角 2 秒）
      --   或 view = "notify"（弹卡片）
    },
  })

  M._applied = true
  return true
end

M.apply = apply

-- 调用时机说明（重要）：
--   · 正常情况下由 lazy.nvim 在 noice 插件加载完成后调用（见 plugins-setup.lua
--     里 noice 条目的 `config = function() require("plugins.noice").apply() end`）。
--   · 这里只做一次「插件已就绪」的即时尝试，不做重试 —— headless 下
--     defer_fn / schedule 不一定跑，靠定时器兜底并不比 lazy 的 config 可靠。
apply()

-- 兜底：VeryLazy 后再试一次，并重装翻译钩子（noice setup 会覆盖 vim.notify）
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    apply()
    pcall(function()
      require("core.chinese").install_notify_hook()
    end)
  end,
})

return M
