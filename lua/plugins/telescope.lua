-- Telescope 模糊查找配置
-- 目的：把搜索窗口边框上的标题（picker 的 prompt_title）改成中文。
--
-- 说明：Telescope 有 47 处 builtin 在源码里写死了 prompt_title，但标题是**可配置**的——
-- pickers.lua 中 `opts.prompt_title` 优先于全局默认值，因此无需改插件源码。
-- 注意 defaults.prompt_title 只对"没有自设标题"的 picker 生效，
-- 所以要改具体某个 picker，必须在 pickers 表里单独指定。

require("telescope").setup({
	defaults = {
		prompt_title = "搜索",
		results_title = "结果",
	},
	pickers = {
		-- 本配置里绑定了快捷键的（见 core/keymaps.lua）
		find_files = { prompt_title = "查找文件" },
		live_grep = { prompt_title = "全局搜索内容" },
		oldfiles = { prompt_title = "最近打开的文件" },
		buffers = { prompt_title = "缓冲区列表" },
		help_tags = { prompt_title = "帮助文档" },
		-- 其它常用 picker 一并汉化，避免按到英文标题
		grep_string = { prompt_title = "搜索光标下的词" },
		current_buffer_fuzzy_find = { prompt_title = "在当前文件中搜索" },
		git_files = { prompt_title = "Git 文件" },
		git_status = { prompt_title = "Git 状态" },
		git_commits = { prompt_title = "Git 提交记录" },
		git_bcommits = { prompt_title = "当前文件的提交记录" },
		git_branches = { prompt_title = "Git 分支" },
		git_stash = { prompt_title = "Git 储藏" },
		diagnostics = { prompt_title = "诊断信息" },
		lsp_references = { prompt_title = "LSP 引用" },
		lsp_definitions = { prompt_title = "LSP 定义" },
		lsp_implementations = { prompt_title = "LSP 实现" },
		lsp_document_symbols = { prompt_title = "当前文件符号" },
		lsp_workspace_symbols = { prompt_title = "工作区符号" },
		lsp_dynamic_workspace_symbols = { prompt_title = "工作区符号（动态）" },
		commands = { prompt_title = "命令" },
		command_history = { prompt_title = "命令历史" },
		search_history = { prompt_title = "搜索历史" },
		quickfix = { prompt_title = "快速修复列表" },
		loclist = { prompt_title = "位置列表" },
		marks = { prompt_title = "标记" },
		registers = { prompt_title = "寄存器" },
		keymaps = { prompt_title = "键位映射" },
		colorscheme = { prompt_title = "切换配色" },
		filetypes = { prompt_title = "文件类型" },
		highlights = { prompt_title = "高亮组" },
		spell_suggest = { prompt_title = "拼写建议" },
		jumplist = { prompt_title = "跳转列表" },
		man_pages = { prompt_title = "手册页" },
		autocommands = { prompt_title = "自动命令" },
		reloader = { prompt_title = "重新加载模块" },
		resume = { prompt_title = "继续上次搜索" },
		pickers = { prompt_title = "所有 picker" },
	},
})
