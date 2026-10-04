-- 键位提示：按下 leader（空格）后弹出可用键位菜单
-- 菜单里每一项的说明文字，来自 lua/core/keymaps.lua 中各个映射的 desc 字段
local wk = require("which-key")

wk.setup({
	-- 按下后等待多久弹出（毫秒）。300 兼顾"手快不弹"与"稍停即现"
	delay = 300,
	-- 在命令行区域回显当前已按下的键
	show_keys = true,
	icons = {
		breadcrumb = "»",
		separator = "➜",
		group = "+",
	},
	win = {
		border = "rounded",
		padding = { 1, 2 },
		wo = { winblend = 10 },
	},
	layout = {
		width = { min = 20 },
		spacing = 3,
	},
})

-- ⚠️ which-key v3 不会自动为 leader 注册触发键，必须在这里显式声明，
-- 否则按下空格不会有任何反应。
wk.add({
	-- 触发器：按下空格后列出所有 <leader> 开头的键位
	{ "<leader>", group = "快捷键", mode = { "n", "v" } },

	-- 分组标签：把同一前缀的键位归类并显示中文组名
	{ "<leader>s", group = "窗口与分屏" },
	{ "<leader>f", group = "查找（Telescope）" },
	{ "<leader>l", group = "插件与工具" },
	{ "<leader>m", group = "Markdown" },
	{ "<leader>n", group = "显示控制" },
})
