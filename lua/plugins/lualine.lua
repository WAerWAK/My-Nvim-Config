-- 状态栏配置（中文版）
require('lualine').setup({
	options = {
		theme = "tokyonight",
		globalstatus = true,
		section_separators = { left = '', right = '' },
		component_separators = { left = '', right = '' },
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diff' },
		lualine_c = {
			{
				'filename',
				path = 1,
				symbols = {
					modified = ' ●',  -- 有未保存修改
					readonly = ' ',   -- 只读
					unnamed = '[未命名]',
				},
			},
		},
		lualine_x = { 'diagnostics', 'filetype', 'encoding' },
		lualine_y = { 'progress' },
		lualine_z = { 'location' },
	},
	inactive_sections = {
		lualine_c = {
			{ 'filename', path = 1, symbols = { unnamed = '[未命名]' } },
		},
	},
})
