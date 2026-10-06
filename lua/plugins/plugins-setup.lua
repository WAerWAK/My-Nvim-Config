local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
	"folke/tokyonight.nvim", -- 主题
	"nvim-lualine/lualine.nvim",  -- 状态栏
	"nvim-tree/nvim-tree.lua",  -- 文档树
	"nvim-tree/nvim-web-devicons", -- 文档树图标
	"christoomey/vim-tmux-navigator", -- 用ctl-hjkl来定位窗口
	{
		"nvim-treesitter/nvim-treesitter", -- 语法高亮  
		build = ':TSUpdate', -- 安装/更新后同步解析器（原写法 run 不是 lazy.nvim 的字段，不会生效）
		config = function()
			require 'nvim-treesitter.install'.compilers = { "gcc" } -- 只使用gcc作为编译器  
		end,
	},
	'HiPhish/rainbow-delimiters.nvim',
	{
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim", -- 这个相当于mason.nvim和lspconfig的桥梁
		"neovim/nvim-lspconfig"
	},
	-- 自动补全
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	'hrsh7th/cmp-cmdline', -- 命令行补全支持

	"L3MON4D3/LuaSnip", -- snippets引擎，不装这个自动补全会出问题
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"hrsh7th/cmp-path", -- 文件路径

	"numToStr/Comment.nvim", -- gcc和gc注释
	"windwp/nvim-autopairs", -- 自动补全括号
	"akinsho/bufferline.nvim", -- buffer分割线
	{'akinsho/toggleterm.nvim', version = "*", config = true}, -- terminal插件
	-- ⚠️ 已禁用：smear-cursor（光标拖尾动画）
	-- 原因：它会持续创建大量辅助窗口（实测 23~35 个，ft=smear-cursor，高度 1 行），
	--       导致 <C-w>w 循环切换窗口要按很多次，并白占内存。
	--       已升级到上游最新版（含 "skip drawing if animation is lagging" 性能修复）
	--       仍无效，故禁用。它只提供视觉效果，禁用无任何功能损失。
	-- 如需恢复：取消下面一行注释，并恢复 lua/plugins/smear-cursor.lua 的 setup 调用。
	-- {"sphamba/smear-cursor.nvim"},


	-- New
	-- 注：noice 的配置在 plugins/noice.lua 里通过 noice.setup() 应用；
	--     不要在 lazy 的 config 回调里 require 那个模块 —— 会与 init.lua
	--     的 require 链形成循环加载（实测报
	--     "loop or previous error loading module 'plugins.noice'"）。
	{ "folke/noice.nvim",event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }
	},
	-- Dashboard
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	-- render markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
	},

	{ "lukas-reineke/indent-blankline.nvim", main = "ibl",                 event = "BufReadPre" },
	-- aerial
	{
		"stevearc/aerial.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	},
	-- Git
	{ "lewis6991/gitsigns.nvim",   event = "BufReadPre" },

	-- 模糊查找（原仓库 dashboard.lua 的快捷键依赖 Telescope，但插件列表里漏装了，这里补上）
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- 键位提示（按 leader 键弹出可用键位菜单，原仓库未包含，为中文键位提示而补装）
	{
		"folke/which-key.nvim",
		tag = "v3.17.0",
		event = "VeryLazy",
	},
}
local opts = {
	-- 关闭自动检查更新：否则 lazy 会定期联网检查并在界面提示"有更新"，
	-- 手动点一下就可能触发全量更新（2026-10-04 已因此误更新一次）。
	-- 需要更新时手动执行 :Lazy 后再操作。
	checker = { enabled = false },
	-- 启动时不显示更新提示
	change_detection = { enabled = false, notify = false },
}

require("lazy").setup(plugins, opts)
