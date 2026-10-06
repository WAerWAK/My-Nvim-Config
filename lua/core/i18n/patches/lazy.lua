-- =====================================================================
--  lazy.nvim 界面汉化
-- =====================================================================
--  覆盖：插件列表主界面、顶部按钮、分组标题、操作说明、输入提示
--  原为自研 patch 机制中的核心规则，此处按插件归位
-- =====================================================================

return {
  rules = {
    {
      -- 主界面：光标所在插件的操作说明（desc = 全局说明，desc_plugin = 单个插件）
      path = "lazy.nvim/lua/lazy/view/config.lua",
      note = "lazy 操作说明（21 条）",
      replacements = {
        { [[desc = "Go back to plugin list"]], [[desc = "返回插件列表"]] },
        { [[desc = "Install missing plugins"]], [[desc = "安装缺失的插件"]] },
        { [[desc_plugin = "Install a plugin"]], [[desc_plugin = "安装该插件"]] },
        { [[desc = "Update plugins. This will also update the lockfile"]], [[desc = "更新全部插件（会改写 lazy-lock.json，慎用）"]] },
        { [[desc_plugin = "Update a plugin. This will also update the lockfile"]], [[desc_plugin = "更新该插件（会改写 lazy-lock.json）"]] },
        { [[desc = "Run install, clean and update"]], [[desc = "依次执行 安装 → 清理 → 更新"]] },
        { [[desc_plugin = "Run install, clean and update"]], [[desc_plugin = "依次执行 安装 → 清理 → 更新"]] },
        { [[desc = "Clean plugins that are no longer needed"]], [[desc = "清理不再需要的插件"]] },
        { [[desc_plugin = "Delete a plugin. WARNING: this will delete the plugin even if it should be installed!"]], [[desc_plugin = "删除该插件。警告：即使它应当被安装也会被删除！"]] },
        { [[desc = "Check for updates and show the log (git fetch)"]], [[desc = "检查更新并显示日志（git fetch）"]] },
        { [[desc_plugin = "Check for updates and show the log (git fetch)"]], [[desc_plugin = "检查该插件更新并显示日志（git fetch）"]] },
        { [[desc = "Show recent updates"]], [[desc = "查看最近的更新记录"]] },
        { [[desc_plugin = "Show recent updates"]], [[desc_plugin = "查看该插件的更新记录"]] },
        { [[desc = "Updates all plugins to the state in the lockfile. For a single plugin: restore it to the state in the lockfile or to a given commit under the cursor"]], [[desc = "按 lazy-lock.json 恢复全部插件版本（出问题就用这个）"]] },
        { [[desc_plugin = "Restore a plugin to the state in the lockfile or to a given commit under the cursor"]], [[desc_plugin = "将该插件恢复到锁定版本或光标处的提交"]] },
        { [[desc = "Show detailed profiling"]], [[desc = "查看加载耗时分析"]] },
        { [[desc = "Show debug information"]], [[desc = "查看调试信息"]] },
        { [[desc = "Toggle this help page"]], [[desc = "开关本帮助页"]] },
        { [[desc = "Clear finished tasks"]], [[desc = "清除已完成的任务"]] },
        { [[desc = "Load a plugin that has not been loaded yet. Similar to `:packadd`. Like `:Lazy load foo.nvim`. Use `:Lazy! load` to skip `cond` checks."]], [[desc = "手动加载尚未加载的插件（类似 :packadd）"]] },
        { [[desc = "Run `:checkhealth lazy`"]], [[desc = "运行 :checkhealth lazy"]] },
        { [[desc = "Rebuild a plugin"]], [[desc = "重新构建该插件"]] },
        { [[desc = "Reload a plugin (experimental!!)"]], [[desc = "重新加载该插件（实验性）"]] },
      },
    },
    {
      -- 主界面：窗口标题栏与底部输入提示
      path = "lazy.nvim/lua/lazy/view/init.lua",
      note = "lazy 窗口标题与输入提示（6 条）",
      replacements = {
        { [[desc = "Abort"]], [[desc = "中止"]] },
        { [["Details"]], [["详情"]] },
        { [["Next Plugin"]], [["下一个插件"]] },
        { [["Prev Plugin"]], [["上一个插件"]] },
        { [["Sort Profile"]], [["排序方式"]] },
        { [[prompt = "Enter time threshold in ms: "]], [[prompt = "输入耗时阈值（毫秒）："]] },
      },
    },
    {
      -- 顶部按钮标题：由 mode.name 首字母大写生成，先查中文映射表再回退英文
      -- 统计行 "Total: " 也在此文件
      path = "lazy.nvim/lua/lazy/view/render.lua",
      note = "lazy 顶部按钮中文名映射 + 统计行（2 条）",
      replacements = {
        {
          [[      local title = " " .. mode.name:sub(1, 1):upper() .. mode.name:sub(2) .. " (" .. mode.key .. ") "]],
          table.concat({
            [[      local btn_cn = {]],
            [[        home = "主页", install = "安装", update = "更新", sync = "同步",]],
            [[        clean = "清理", check = "检查", log = "日志", restore = "恢复",]],
            [[        profile = "性能", debug = "调试", help = "帮助", clear = "清空",]],
            [[        load = "加载", health = "体检", build = "构建", reload = "重载",]],
            [[      }]],
            [[      local bn = btn_cn[mode.name] or (mode.name:sub(1, 1):upper() .. mode.name:sub(2))]],
            [[      local title = " " .. bn .. " (" .. mode.key .. ") "]],
          }, "\n"),
        },
        { [["Total: "]], [["插件总数: "]] },
      },
    },
    {
      -- 插件列表里的分组标题（失败 / 已安装 / 可更新 …）
      path = "lazy.nvim/lua/lazy/view/sections.lua",
      note = "lazy 分组标题（14 条）",
      replacements = {
        { [[title = "Failed"]], [[title = "失败"]] },
        { [[title = "Working"]], [[title = "进行中"]] },
        { [[title = "Build"]], [[title = "构建"]] },
        { [[title = "Breaking Changes"]], [[title = "破坏性变更"]] },
        { [[title = "Updated"]], [[title = "已更新"]] },
        { [[title = "Installed"]], [[title = "已安装"]] },
        { [[title = "Updates"]], [[title = "可更新"]] },
        { [[title = "Log"]], [[title = "日志"]] },
        { [[title = "Clean"]], [[title = "待清理"]] },
        { [[title = "Not Installed"]], [[title = "未安装"]] },
        { [[title = "Outdated"]], [[title = "已过期"]] },
        { [[title = "Loaded"]], [[title = "已加载"]] },
        { [[title = "Not Loaded"]], [[title = "未加载"]] },
        { [[title = "Disabled"]], [[title = "已禁用"]] },
      },
    },
    {
      -- profile（:Lazy profile）页面：启动耗时说明与按键提示
      path = "lazy.nvim/lua/lazy/view/render.lua",
      note = "lazy profile 页面（8 条）",
      replacements = {
        { [[self:append("Startuptime: ", "LazyH2")]], [[self:append("启动耗时: ", "LazyH2")]] },
        { [[self:append("Based on the actual CPU time of the Neovim process till ")]], [[self:append("基于 Neovim 进程的实际 CPU 时间，统计到 ")]] },
        { [[self:append("This is more accurate than ")]], [[self:append("这比 ")]] },
        { [[self:append("An accurate startuptime based on the actual CPU time of the Neovim process is not available.")]], [[self:append("无法获取基于实际 CPU 时间的精确启动耗时。")]] },
        { [[:append("Startuptime is instead based on a delta with a timestamp when lazy started till ")]], [[:append("这里改用懒加载启动时刻到 ")]] },
        { [[self:append("You can press "):append("<CR>", "LazySpecial"):append(" on a plugin to show its details.")]], [[self:append("在插件上按 "):append("<CR>", "LazySpecial"):append(" 可查看它的详情。")]] },
        { [[:append(" to change sorting between chronological order & time taken.")]], [[:append(" 可在「按时间顺序」与「按耗时」之间切换排序。")]] },
        { [[:append(" to filter profiling entries that took more time than a given threshold")]], [[:append(" 可过滤出耗时超过指定阈值的条目")]] },
        { [[self:append("Profile", "LazyH2")]], [[self:append("性能分析", "LazyH2")]] },
      },
    },
    {
      -- 其它窗口标题与提示
      path = "lazy.nvim/lua/lazy/util.lua",
      note = "lazy 命令失败提示（1 条）",
      replacements = {
        { [[{ title = "Command Failed (" .. code .. ")" }]], [[{ title = "命令执行失败（" .. code .. "）" }]] },
      },
    },
    {
      path = "lazy.nvim/lua/lazy/core/config.lua",
      note = "lazy 插件详情窗口标题（1 条）",
      replacements = {
        { [[title = "Inspect " .. plugin.name]], [[title = "查看 " .. plugin.name]] },
      },
    },
    {
      path = "lazy.nvim/lua/lazy/view/commands.lua",
      note = "lazy 重载插件提示（1 条）",
      replacements = {
        { [[Util.warn("Reloading **" .. plugin.name .. "**")]], [[Util.warn("正在重新加载 **" .. plugin.name .. "**")]] },
      },
    },
  },
}
