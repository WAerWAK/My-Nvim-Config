-- ⚠️ 该插件已在 plugins-setup.lua 中禁用（它会持续创建大量辅助窗口）。
-- 这里用 pcall 包住，即使插件不存在也不会因 require 失败而报错。
pcall(function()
	require('smear_cursor').setup({
		cursor_color = "#fff3b0",
		stiffness = 0.3,
		trailing_stiffness = 0.1,
		trailing_exponent = 5,
		gamma = 1,
	})
end)
