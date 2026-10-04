vim.g.mapleader = " "

local keymap = vim.keymap

-- 所有键位都带 desc，按空格键（leader）时 which-key 会弹出这些中文说明

-- ---------- 插入模式 ----------
keymap.set("i", "jk", "<ESC>", { desc = "退出插入模式" })

-- ---------- 视觉模式 ----------
-- 单行或多行上下移动（移动后保持选中）
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "选中内容下移" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "选中内容上移" })

-- ---------- 正常模式 ----------
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "垂直分屏（左右）" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "水平分屏（上下）" })
keymap.set("n", "<leader>sc", "<C-w>c", { desc = "关闭当前窗口" })
keymap.set("n", "<C-h>", "<C-w>h", { desc = "跳到左边窗口" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "跳到下边窗口" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "跳到上边窗口" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "跳到右边窗口" })

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "取消搜索高亮" })

-- 文件树
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "开关文件树" })

-- 代码大纲
keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", { desc = "开关代码大纲" })

-- 切换 buffer
keymap.set("n", "<S-L>", ":bnext<CR>", { desc = "下一个缓冲区" })
keymap.set("n", "<S-H>", ":bprevious<CR>", { desc = "上一个缓冲区" })
keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "关闭当前缓冲区" })

-- 查找（Telescope）
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "查找文件" })
keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "最近打开的文件" })
keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "全局搜索内容" })
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "切换缓冲区列表" })
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "搜索帮助文档" })

-- 插件与工具
keymap.set("n", "<leader>ll", "<cmd>Lazy<CR>", { desc = "插件管理（勿用全量更新）" })
keymap.set("n", "<leader>lm", "<cmd>Mason<CR>", { desc = "LSP 与工具管理" })

-- 回到启动页（关闭文件后想回到 MYNVIM 主界面时用）
keymap.set("n", "<leader>d", "<cmd>Dashboard<CR>", { desc = "回到启动页" })

-- ===== 为 Neovim / 插件内置的键位补中文说明 =====
-- 这些映射来自 Neovim 运行时与 Comment.nvim，本身没有中文 desc，
-- which-key 菜单（如按 g）会显示英文。这里只补 desc、不改动原行为。
local cn = {
	{ "n", "gx", "用系统程序打开光标下的文件或链接" },
	{ "n", "gra", "代码操作（快速修复）" },
	{ "n", "grn", "重命名符号" },
	{ "n", "grr", "列出所有引用" },
	{ "n", "gri", "跳转到实现" },
	{ "n", "grt", "跳转到类型定义" },
	{ "n", "grx", "运行代码镜头（Code Lens）" },
	{ "n", "gO", "列出当前文件符号" },
	{ "n", "]d", "跳到下一个诊断" },
	{ "n", "[d", "跳到上一个诊断" },
	{ "n", "]D", "跳到最后一个诊断" },
	{ "n", "[D", "跳到第一个诊断" },
	{ "n", "]q", "下一个 quickfix" },
	{ "n", "[q", "上一个 quickfix" },
	{ "n", "]l", "下一个位置列表项" },
	{ "n", "[l", "上一个位置列表项" },
	{ "n", "]b", "下一个缓冲区" },
	{ "n", "[b", "上一个缓冲区" },
	{ "n", "]t", "下一个标签页" },
	{ "n", "[t", "上一个标签页" },
	-- 注意：gc / gcc / gb / gbc 由 Comment.nvim 以 <Plug> 方式注册，**不要在此表里覆盖**。
	-- 用空 rhs 覆盖会打断 <Plug> 的展开；而重设 rhs 又容易改坏行为。
	-- 这几个键位的说明见文档《Neovim 使用指南》的键位速查表。
	{ "v", "gx", "用系统程序打开选中的链接" },
	{ "v", "gra", "代码操作（快速修复）" },
	{ "v", "]n", "选中下一个节点" },
	{ "v", "[n", "选中上一个节点" },
	{ "v", "]N", "选中下一个同级节点" },
	{ "v", "[N", "选中上一个同级节点" },
}
for _, k in ipairs(cn) do
	pcall(vim.keymap.set, k[1], k[2], "", { desc = k[3], remap = true })
end

-- 注：注释类键位（gc / gcc / gb… ）的说明文字**不在这里改**。
-- 它们是 Lua 回调型映射（rhs 为 nil），在此重设会让注释功能失效。
-- 正确做法是直接汉化 Comment.nvim 源码里的 desc 字符串，
-- 已由 core/chinese.lua 的 patch 机制在启动时自动完成。