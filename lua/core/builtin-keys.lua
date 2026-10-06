-- ===== 为 Neovim 内置命令补中文说明 =====
--
-- 背景：gg / ge / gf 以及 <C-w> 系列的窗口命令，都是 Neovim 的**内置命令**，
--       本身没有映射，which-key 菜单里显示的是命令表的英文描述。
--
-- 策略：只汉化"行为简单、能确保语义完全不变"的键位。
--       涉及计数 / 寄存器的（gJ、gu、g~、gq、gp、<C-w>_、<C-w>| 等）保持英文，
--       因为无法保证行为与原生一致，宁可不动。
--
-- 实现：窗口命令统一用 `wincmd`（等价于原生的 <C-w>x），比 normal! 更可靠。

local function m(mode, lhs, rhs, desc)
	pcall(vim.keymap.set, mode, lhs, rhs, { desc = desc, silent = true })
end

-- ---------- g 系列：纯导航 ----------
m("n", "gg", function()
	vim.cmd("normal! gg")          -- 第一行
end, "跳到文件开头")
m("n", "ge", function()
	vim.cmd("normal! ge")          -- 前一个词尾（无计数）
end, "跳到上一个词尾")
m("n", "gf", function()
	vim.cmd("normal! gf")          -- 打开光标下的文件
end, "打开光标下的文件")

-- ---------- 窗口：跳转 ----------
local function wincmd(keys, desc)
	m("n", "<C-w>" .. keys, function()
		vim.cmd("wincmd " .. keys)
	end, desc)
end

wincmd("h", "跳到左边窗口")
wincmd("j", "跳到下边窗口")
wincmd("k", "跳到上边窗口")
wincmd("l", "跳到右边窗口")
wincmd("w", "在窗口间循环切换")
wincmd("W", "反向循环切换窗口")

-- ---------- 窗口：分屏与关闭 ----------
wincmd("s", "水平分屏（上下）")
wincmd("v", "垂直分屏（左右）")
wincmd("c", "关闭当前窗口")
wincmd("o", "只保留当前窗口（关闭其他）")
wincmd("q", "退出当前窗口")
wincmd("x", "与相邻窗口互换位置")
wincmd("T", "把当前窗口移到新标签页")

-- ---------- 窗口：大小 ----------
wincmd("=", "所有窗口等宽等高")
wincmd("+", "增加高度")
wincmd("-", "减少高度")
wincmd(">", "增加宽度")
wincmd("<", "减少宽度")

-- ---------- 隐藏两个用不到的英文菜单项 ----------
-- <C-w>d / <C-w><C-d>：按 nvim 官方定义（:help CTRL-W_d）是
--   「用浮窗显示光标所在行的 LSP 诊断」= vim.diagnostic.open_float()
--   —— 注意它**不是**"跳转到诊断"（跳转是 ]d / [d，已汉化）。
-- 用户明确不用该功能，且它的 desc 是英文（nvim 内置，无法安全汉化），
-- 所以在这里直接删除映射：既不占位、也不会出现在 which-key 菜单里。
-- 想恢复：把下面三行注释掉，或执行
--   :lua vim.keymap.set('n','<C-w>d', vim.diagnostic.open_float, {desc='查看光标下的诊断'})
for _, lhs in ipairs({ "<C-w>d", "<C-w><C-d>" }) do
	pcall(vim.keymap.del, "n", lhs)
end