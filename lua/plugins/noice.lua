require("noice").setup({
	routes = {
		-- 屏蔽保存（:w 写入成功的提示）
		{
			filter = {
				event = "msg_show",
				kind = "",
				find = "written",
			},
			opts = { skip = true },
		},
		-- 屏蔽复制（yank 提示）
		{
			filter = {
				event = "msg_show",
				kind = "",
				find = "yanked",
			},
			opts = { skip = true },
		},
	},
})
