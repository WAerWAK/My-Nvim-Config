-- ===== Tree-sitter 语法高亮与缩进 =====
--
-- ⚠️ 本配置使用 nvim-treesitter 的 main 分支（全新 API），因为它要求 Neovim 0.12+，
-- 与本机 Neovim 0.12.5 匹配；旧 master 分支只保证兼容 Neovim 0.11，
-- 在 0.12 上打开 Markdown 等文件会抛 `node:range()` 的 nil 错误。
--
-- main 分支的 API 与旧版完全不同：
--   旧：require('nvim-treesitter.configs').setup{ highlight = {...} }
--   新：高亮由 Neovim 内置提供，用 FileType 自动命令调用 vim.treesitter.start()
-- 详见 https://github.com/nvim-treesitter/nvim-treesitter/tree/main

-- 指定用 gcc 编译解析器（本机 gcc 15.2.0，nc 下还需 cc 别名，见使用指南 Q14）
require('nvim-treesitter.install').compilers = { 'gcc' }

-- 语言列表：升级插件后所有解析器需一起更新（:TSUpdate）
local parsers = {
	'vim', 'vimdoc', 'bash', 'c', 'cpp', 'c_sharp', 'java', 'javascript', 'json',
	'lua', 'python', 'powershell', 'rust', 'css', 'typescript', 'tsx',
	'markdown', 'markdown_inline', 'yaml', 'toml',
}

-- 缺失的解析器自动补装（异步，不阻塞启动；装完需重启 nvim 生效）
local missing = {}
for _, lang in ipairs(parsers) do
	if not vim.treesitter.language.add(lang) then
		table.insert(missing, lang)
	end
end
if #missing > 0 then
	require('nvim-treesitter').install(missing)
end

-- 高亮：Neovim 自带能力，需在每个文件类型上显式开启
vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		-- filetype 与解析器名不一致的情况在此映射
		local alias = { ps1 = 'powershell', pwsh = 'powershell', sh = 'bash', zsh = 'bash' }
		local lang = alias[vim.bo.filetype]
		if lang and vim.treesitter.language.add(lang) then
			vim.treesitter.start(0, lang)
			return
		end
		-- pcall 兜底：该语言尚未安装解析器时静默跳过，不报错
		pcall(vim.treesitter.start)
	end,
})

-- 缩进：插件提供的实验性功能，同样是每个文件类型单独开启
vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

-- 括号彩虹色由 plugins-setup.lua 里的 rainbow-delimiters.nvim 提供，
-- 它会自动对所有已装解析器生效，无需在此重复配置。
