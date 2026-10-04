-- ===== 中文界面统一词汇表 =====
-- 其它配置通过 require("core.chinese").t 取用，集中管理便于统一改词
local M = {}

M.t = {
	-- 仪表盘 / 项目
	dashboard_files = "查找文件",
	dashboard_recent = "最近文件",
	dashboard_grep = "全局搜索",
	dashboard_projects = "最近项目",
	dashboard_empty_project = "暂无项目记录",
	dashboard_footer = "⚡ 工欲善其事，必先利其器",

	-- 状态栏
	status_unnamed = "[未命名]",
	status_modified = "已修改",
	status_readonly = "只读",

	-- nvim-tree
	tree_explorer = "文件浏览器",

	-- 终端
	terminal = "终端",

	-- 常用提示语
	msg_saved = "已保存",
	msg_copied = "已复制",
	msg_nohl = "已取消搜索高亮",
}

-- ===== 常用消息中文化 =====
-- 说明：Neovim 核心本身没有中文语言包（运行时目录里没有 zh_CN 翻译文件），
-- Lazy / Mason / Telescope 等插件的界面文本也是硬编码英文，无法汉化。
-- 这里只对最高频的系统消息做一层翻译，覆盖面有限但够日常使用。
local patterns = {
	{ "^written$", M.t.msg_saved },
	{ "^yanked$", M.t.msg_copied },
	{ "^yanked%s+(%d+)%s+lines?$", "已复制 %1 行" },
	{ "^(%d+)%s+lines?%s+yanked$", "已复制 %1 行" },
	{ "^(%d+)%s+more%s+lines?$", "还有 %1 行" },
	{ "^(%d+)%s+fewer%s+lines?$", "减少 %1 行" },
	{ "^(%d+)%s+lines?%s+changed$", "已修改 %1 行" },
	{ "^(%d+)%s+substitutions?%s+on%s+(%d+)%s+lines?$", "%2 行中替换了 %1 处" },
	{ "^search%s+wrapped%s+around%s+the%s+end%s+of%s+file$", "搜索已回到文件开头" },
	{ "^E486:%s+Pattern%s+not%s+found:%s*(.*)$", "E486: 未找到匹配：%1" },
	{ "^E37:%s+No%s+write%s+since%s+last%s+change$", "E37: 自上次修改后尚未写入" },
	{ "^E45:%s+'readonly'%s+option%s+is%s+set.*$", "E45: 文件为只读，无法写入" },
	{ "^No%s+match$", "无匹配项" },
	{ "^Pattern%s+not%s+found$", "未找到匹配" },
}

function M.translate(msg)
	if type(msg) ~= "string" or #msg > 120 then
		return msg
	end
	for _, p in ipairs(patterns) do
		local out, n = msg:gsub(p[1], p[2])
		if n > 0 then
			return out
		end
	end
	return msg
end

-- 把翻译接到通知链路上（noice / notify 都走 vim.notify）
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
	return orig_notify(M.translate(msg), level, opts)
end

-- ===== 插件界面文本汉化 =====
-- 背景：lazy.nvim / mason.nvim / nvim-tree 等插件的界面文本全部硬编码在源码里，
--       没有 i18n 开关（Neovim 本身也不含中文语言包），只能改插件源码。
-- 做法：每次启动时检查并替换，因此插件更新后会自动重新汉化，不会丢失。
-- 注意：只替换界面提示文本（desc / title / prompt），不动任何逻辑用的字符串。
local plugin_patches = {
	{
		-- lazy.nvim 主界面：操作说明
		path = "lazy.nvim/lua/lazy/view/config.lua",
		replacements = {
			{ [[desc = "Go back to plugin list"]], [[desc = "返回插件列表"]] },
			{ [[desc = "Install missing plugins"]], [[desc = "安装缺失的插件"]] },
			{ [[desc_plugin = "Install a plugin"]], [[desc_plugin = "安装该插件"]] },
			{ [[desc = "Update plugins. This will also update the lockfile"]], [[desc = "更新全部插件（会改写 lazy-lock.json，慎用）"]] },
			{ [[desc_plugin = "Update a plugin. This will also update the lockfile"]], [[desc_plugin = "更新该插件（会改写 lazy-lock.json）"]] },
			{ [[desc = "Run install, clean and update"]], [[desc = "依次执行 安装 → 清理 → 更新"]] },
			{ [[desc_plugin = "Run install, clean and update"]], [[desc_plugin = "依次执行 安装 → 清理 → 更新"]] },
			{ [[desc = "Clean plugins that are no longer needed"]], [[desc = "清理不再需要的插件"]] },
			{ [[desc_plugin = "Delete a plugin. WARNING: this will delete the plugin even if it should be installed!"]], [[desc_plugin = "删除该插件。警告：即使它应当被安装也会被删除！"]] },
			{ [[desc = "Check for updates and show the log (git fetch)"]], [[desc = "检查更新并显示日志（git fetch）"]] },
			{ [[desc_plugin = "Check for updates and show the log (git fetch)"]], [[desc_plugin = "检查该插件更新并显示日志（git fetch）"]] },
			{ [[desc = "Show recent updates"]], [[desc = "查看最近的更新记录"]] },
			{ [[desc_plugin = "Show recent updates"]], [[desc_plugin = "查看该插件的更新记录"]] },
			{ [[desc = "Updates all plugins to the state in the lockfile. For a single plugin: restore it to the state in the lockfile or to a given commit under the cursor"]], [[desc = "按 lazy-lock.json 恢复全部插件版本（出问题就用这个）"]] },
			{ [[desc_plugin = "Restore a plugin to the state in the lockfile or to a given commit under the cursor"]], [[desc_plugin = "将该插件恢复到锁定版本或光标处的提交"]] },
			{ [[desc = "Show detailed profiling"]], [[desc = "查看加载耗时分析"]] },
			{ [[desc = "Show debug information"]], [[desc = "查看调试信息"]] },
			{ [[desc = "Toggle this help page"]], [[desc = "开关本帮助页"]] },
			{ [[desc = "Clear finished tasks"]], [[desc = "清除已完成的任务"]] },
			{ [[desc = "Load a plugin that has not been loaded yet. Similar to `:packadd`. Like `:Lazy load foo.nvim`. Use `:Lazy! load` to skip `cond` checks."]], [[desc = "手动加载尚未加载的插件（类似 :packadd）"]] },
			{ [[desc = "Run `:checkhealth lazy`"]], [[desc = "运行 :checkhealth lazy"]] },
			{ [[desc = "Rebuild a plugin"]], [[desc = "重新构建该插件"]] },
			{ [[desc = "Reload a plugin (experimental!!)"]], [[desc = "重新加载该插件（实验性）"]] },
		},
	},
	{
		-- lazy.nvim 主界面：分组标题
		path = "lazy.nvim/lua/lazy/view/sections.lua",
		replacements = {
			{ [[title = "Failed"]], [[title = "失败"]] },
			{ [[title = "Working"]], [[title = "进行中"]] },
			{ [[title = "Build"]], [[title = "构建"]] },
			{ [[title = "Breaking Changes"]], [[title = "破坏性变更"]] },
			{ [[title = "Updated"]], [[title = "已更新"]] },
			{ [[title = "Installed"]], [[title = "已安装"]] },
			{ [[title = "Updates"]], [[title = "可更新"]] },
			{ [[title = "Log"]], [[title = "日志"]] },
			{ [[title = "Clean"]], [[title = "待清理"]] },
			{ [[title = "Not Installed"]], [[title = "未安装"]] },
			{ [[title = "Outdated"]], [[title = "已过期"]] },
			{ [[title = "Loaded"]], [[title = "已加载"]] },
			{ [[title = "Not Loaded"]], [[title = "未加载"]] },
			{ [[title = "Disabled"]], [[title = "已禁用"]] },
		},
	},
	{
		-- lazy.nvim 主界面：键位说明与输入提示
		path = "lazy.nvim/lua/lazy/view/init.lua",
		replacements = {
			{ [[desc = "Abort"]], [[desc = "中止"]] },
			{ [[end, "Details")]], [[end, "详情")]] },
			{ [[end, "Next Plugin")]], [[end, "下一个插件")]] },
			{ [[end, "Prev Plugin")]], [[end, "上一个插件")]] },
			{ [[end, "Sort Profile")]], [[end, "排序方式")]] },
			{ [[prompt = "Enter time threshold in ms: "]], [[prompt = "输入耗时阈值（毫秒）："]] },
		},
	},
	{
		-- nvim-tree：文件操作提示
		path = "nvim-tree.lua/lua/nvim-tree/marks/init.lua",
		replacements = {
			{ [[prompt = "Move to: "]], [[prompt = "移动到："]] },
			{ [[prompt = "Select a file to open or a folder to focus"]], [[prompt = "选择要打开的文件或要聚焦的文件夹"]] },
		},
	},
	{
		path = "nvim-tree.lua/lua/nvim-tree/actions/fs/create-file.lua",
		replacements = {
			{ [[prompt = "Create file "]], [[prompt = "新建文件 "]] },
		},
	},
	{
		path = "nvim-tree.lua/lua/nvim-tree/actions/fs/rename-file.lua",
		replacements = {
			{ [[prompt = "Rename to "]], [[prompt = "重命名为 "]] },
		},
	},
	{
		path = "nvim-tree.lua/lua/nvim-tree/actions/fs/clipboard.lua",
		replacements = {
			{ [[prompt = "Rename to "]], [[prompt = "重命名为 "]] },
		},
	},
	{
		-- mason.nvim 主界面
		path = "mason.nvim/lua/mason/ui/components/header.lua",
		replacements = {
			{ [[p.none " for help"]], [[p.none " 查看帮助"]] },
		},
	},
	{
		-- mason.nvim 帮助菜单（渲染在主界面底部的那一行提示）
		path = "mason.nvim/lua/mason/ui/components/help/init.lua",
		replacements = {
			{ [["Toggle help"]], [["开关帮助"]] },
		},
	},
	{
		-- lazy.nvim 顶部按钮标题
		-- 这些标题由 mode.name（命令键名）首字母大写生成，与上面的 desc 字段无关，
		-- 所以单独替换渲染逻辑，加一张中文名映射表。
		path = "lazy.nvim/lua/lazy/view/render.lua",
		replacements = {
			{
				[[      local title = " " .. mode.name:sub(1, 1):upper() .. mode.name:sub(2) .. " (" .. mode.key .. ") "]],
				table.concat({
					[[      local btn_cn = {]],
					[[        home = "主页", install = "安装", update = "更新", sync = "同步",]],
					[[        clean = "清理", check = "检查", log = "日志", restore = "恢复",]],
					[[        profile = "性能", debug = "调试", help = "帮助", clear = "清空",]],
					[[        load = "加载", health = "体检", build = "构建", reload = "重载",]],
					[[      }]],
					[[      local bn = btn_cn[mode.name] or (mode.name:sub(1, 1):upper() .. mode.name:sub(2))]],
					[[      local title = " " .. bn .. " (" .. mode.key .. ") "]],
				}, "\n"),
			},
			{
				-- 插件清单上方的统计行
				[[self:append("Total: ", "LazyH2")]],
				[[self:append("插件总数: ", "LazyH2")]],
			},
		},
	},
	{
		-- Comment.nvim 的键位说明（gc / gcc / gb / gcO / gco / gcA）
		-- 这些是为了兼容 <Plug> 与回调型映射，其 desc 全写在插件源码里。
		-- 直接改字符串不影响任何功能，比在 keymaps.lua 里覆盖映射安全得多。
		path = "Comment.nvim/lua/Comment/init.lua",
		replacements = {
			{ [[desc = 'Comment toggle linewise']], [[desc = '注释（按行）']] },
			{ [[desc = 'Comment toggle blockwise']], [[desc = '注释（按块）']] },
			{ [[desc = 'Comment toggle current line']], [[desc = '注释当前行']] },
			{ [[desc = 'Comment toggle current block']], [[desc = '注释当前块']] },
			{ [[desc = 'Comment toggle linewise (visual)']], [[desc = '注释选中内容']] },
			{ [[desc = 'Comment toggle blockwise (visual)']], [[desc = '块注释选中内容']] },
			{ [[desc = 'Comment insert below']], [[desc = '在下方插入注释行']] },
			{ [[desc = 'Comment insert above']], [[desc = '在上方插入注释行']] },
			{ [[desc = 'Comment insert end of line']], [[desc = '在行尾插入注释']] },
		},
	},
	{
		-- telescope 兼容性修复（非汉化）
		-- nvim-treesitter 升级到 main 分支后移除了 ft_to_lang / is_enabled / get_module，
		-- telescope 预览器仍调用它们，取文件预览时会抛 ft_to_lang (a nil value)。
		-- 这里改为探测式调用，缺失时优雅降级到普通语法高亮。
		path = "telescope.nvim/lua/telescope/previewers/utils.lua",
		replacements = {
			{
				table.concat({
					[[  local lang = ts_parsers.ft_to_lang(ft)]],
					[[  if not ts_configs.is_enabled("highlight", lang, bufnr) then]],
					[[    return false]],
					[[  end]],
					[[]],
					[[  local config = ts_configs.get_module "highlight"]],
					[[  vim.treesitter.highlighter.new(ts_parsers.get_parser(bufnr, lang))]],
				}, "\n"),
				table.concat({
					[[  -- 兼容 nvim-treesitter main 分支：ft_to_lang / is_enabled / get_module 均已移除，]],
					[[  -- 探测不到就返回 false，回退到普通语法高亮（仅影响预览高亮）]],
					[[  local ok, lang = pcall(ts_parsers.ft_to_lang, ft)]],
					[[  if not ok or not lang then]],
					[[    return false]],
					[[  end]],
					[[  if type(ts_configs.is_enabled) == "function" and not ts_configs.is_enabled("highlight", lang, bufnr) then]],
					[[    return false]],
					[[  end]],
					[[]],
					[[  local config = type(ts_configs.get_module) == "function" and ts_configs.get_module "highlight" or {}]],
					[[  local okp, parser = pcall(ts_parsers.get_parser, bufnr, lang)]],
					[[  if not okp or not parser then]],
					[[    return false]],
					[[  end]],
					[[  vim.treesitter.highlighter.new(parser)]],
				}, "\n"),
			},
		},
	},
	{
		-- telescope 兼容性修复（非汉化）：同上，另一个调用点
		path = "telescope.nvim/lua/telescope/builtin/__files.lua",
		replacements = {
			{
				table.concat({
					[[  local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")]],
					[[  if ts_ok then]],
					[[    filetype = ts_parsers.ft_to_lang(filetype)]],
					[[  end]],
				}, "\n"),
				table.concat({
					[[  local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")]],
					[[  if ts_ok and type(ts_parsers.ft_to_lang) == "function" then]],
					[[    -- 兼容 nvim-treesitter main 分支：ft_to_lang 已移除，取不到就沿用原 filetype]],
					[[    local lang_ok, lang = pcall(ts_parsers.ft_to_lang, filetype)]],
					[[    if lang_ok and lang then]],
					[[      filetype = lang]],
					[[    end]],
					[[  end]],
				}, "\n"),
			},
		},
	},
}

-- 带记忆的替换：某条规则已生效（源码里已找不到原文）就跳过，避免重复替换
local function apply_replacements(content, rules)
	local changed = false
	for _, r in ipairs(rules) do
		if content:find(r[1], 1, true) then
			-- 转义 Lua 模式中的特殊字符后再替换
			content = content:gsub(r[1]:gsub("%p", "%%%0"), (r[2]:gsub("%%", "%%%%")))
			changed = true
		end
	end
	return content, changed
end

function M.patch_plugins()
	local base = vim.fn.stdpath("data") .. "/lazy/"
	local applied, failed = 0, {}
	for _, p in ipairs(plugin_patches) do
		local path = base .. p.path
		if vim.fn.filereadable(path) == 1 then
			local fd = io.open(path, "r")
			if fd then
				local content = fd:read("*a")
				fd:close()
				local new, changed = apply_replacements(content, p.replacements)
				if changed then
					local out = io.open(path, "w")
					if out then
						out:write(new)
						out:close()
						applied = applied + 1
					else
						table.insert(failed, p.path .. "（写入失败）")
					end
				end
			end
		else
			table.insert(failed, p.path .. "（文件不存在）")
		end
	end
	-- telescope 预览窗口的固定标题（"File Preview" 在源码里出现两次，单独处理）
	for _, rel in ipairs({
		"telescope.nvim/lua/telescope/previewers/buffer_previewer.lua",
		"telescope.nvim/lua/telescope/previewers/term_previewer.lua",
	}) do
		local path = base .. rel
		if vim.fn.filereadable(path) == 1 then
			local fd = io.open(path, "r")
			if fd then
				local content = fd:read("*a")
				fd:close()
				if content:find([[title = "File Preview"]], 1, true) then
					content = content:gsub([[title = "File Preview"]], [[title = "文件预览"]])
					local out = io.open(path, "w")
					if out then
						out:write(content)
						out:close()
						applied = applied + 1
					end
				end
			end
		end
	end
	return applied, failed
end

vim.defer_fn(function()
	local applied, failed = M.patch_plugins()
	-- 有失败时给出提示，便于排查（正常情况下不会有）
	if #failed > 0 then
		vim.notify("插件界面汉化有 " .. #failed .. " 项未生效：\n" .. table.concat(failed, "\n"), vim.log.levels.WARN)
	end
end, 1500)

return M
