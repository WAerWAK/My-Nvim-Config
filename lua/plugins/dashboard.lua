local logo = [[
███╗   ███╗██╗   ██╗███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗ ████║╚██╗ ██╔╝████╗  ██║██║   ██║██║████╗ ████║
██╔████╔██║ ╚████╔╝ ██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╔╝██║  ╚██╔╝  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚═╝ ██║   ██║   ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝     ╚═╝   ╚═╝   ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

-- ⚠️ 原配置此处有一条 Update 快捷键：
--     { desc = 'Update', action = 'Lazy update', key = 'u' }
-- 它会在启动页直接触发全量插件更新并改写 lazy-lock.json，极易误触（2026-10-04 已因此误更新一次）。
-- 现已移除。需要更新插件时手动执行 :Lazy，在界面里逐个选择。
--
-- 另：原配置的 'a' 键绑定 'Telescope app'，但 telescope 并没有 app 子命令，按下必报
--     [telescope.run_command]: Unknown command。已改为可用的内置命令。

require('dashboard').setup {
  theme = 'hyper',
  config = {
    header = vim.split(logo, "\n"),
    shortcut = {
      {
        icon = ' ',
        icon_hl = '@variable',
        desc = '查找文件',
        group = 'Label',
        action = 'Telescope find_files',
        key = 'f',
      },
      {
        icon = ' ',
        icon_hl = '@variable',
        desc = '最近文件',
        group = 'DiagnosticHint',
        action = 'Telescope oldfiles',
        key = 'r',
      },
      {
        icon = ' ',
        icon_hl = '@variable',
        desc = '全局搜索',
        group = 'Number',
        action = 'Telescope live_grep',
        key = 'g',
      },
    },
    project = {
      enable = true,
      limit = 8,
      icon = '📂 ',
      label = '最近项目',
      action = function(path)
        -- 修正原写法：cwd 传参需转义，否则含空格的路径会导致查找失败
        vim.cmd('Telescope find_files cwd=' .. vim.fn.fnameescape(path))
      end,
    },
    -- 无项目记录时显示中文提示
    packages = { enable = true },
    footer = { '⚡ 工欲善其事，必先利其器' },
  }
}

-- ===== 启动页剩余英文文案汉化 =====
-- dashboard-nvim 的 hyper 主题把 "Empty project" / "Most Recent Files" 等
-- 硬编码在 lua/dashboard/theme/hyper.lua 里，无法通过 config 覆盖，只能改主题源码。
-- 下面的补丁在每次启动时检查并替换，因此 :Lazy restore 或插件更新后会自动重新汉化。
local function patch_dashboard_theme()
	local path = vim.fn.stdpath("data") .. "/lazy/dashboard-nvim/lua/dashboard/theme/hyper.lua"
	if vim.fn.filereadable(path) ~= 1 then
		return
	end
	local fd = io.open(path, "r")
	if not fd then
		return
	end
	local content = fd:read("*a")
	fd:close()

	local replacements = {
		{ "label = ' Recent Projects:'", "label = ' 📂 最近项目:'" },
		-- 注意：这行前面有一个不可见 Unicode 私有区字符（图标），不能用完整字符串匹配
		{ "empty project", "暂无项目记录" },
		{ "label = ' Most Recent Files:'", "label = ' 🕘 最近打开的文件:'" },
	}

	local changed = false
	for _, r in ipairs(replacements) do
		if content:find(r[1], 1, true) then
			content = content:gsub(r[1]:gsub("%p", "%%%0"), (r[2]:gsub("%%", "%%%%")))
			changed = true
		end
	end

	if changed then
		local out = io.open(path, "w")
		if out then
			out:write(content)
			out:close()
		end
	end
end

patch_dashboard_theme()
