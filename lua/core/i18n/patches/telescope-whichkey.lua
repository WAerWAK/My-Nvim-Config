-- =====================================================================
--  telescope.nvim 的 which_key 菜单汉化（按 <C-/> 弹出的键位表）
-- =====================================================================
--  机制：telescope 注册映射时把 action 名写进 desc（形如 "telescope|close"），
--        which_key 菜单显示时用 actions/utils.lua 的 get_registered_mappings
--        取 desc 并去掉前 10 个字符（"telescope|"）直接当菜单文字 —— 所以
--        菜单里看到的是 move_selection_next 这类**函数名**。
--
--  做法：在 get_registered_mappings 里加一张 action 名 -> 中文 的映射表，
--        查不到就回退显示原名（自定义映射/新 action 不会因此空白）。
--        只影响这一个函数的输出，不动映射本身，功能零风险。
--        组合动作（"toggle_selection + move_selection_better"）按 " + " 拆开
--        逐段翻译再拼回。
-- =====================================================================

return {
  rules = {
    {
      path = "telescope.nvim/lua/telescope/actions/utils.lua",
      note = "telescope which_key 菜单 action 名汉化（1 条，含 40+ 词条）",
      replacements = {
        {
          table.concat({
            [[--- Utility to collect mappings of prompt buffer in array of `{mode, keybind, name}`.]],
            [[---@param prompt_bufnr number: The prompt bufnr]],
            [[function utils.get_registered_mappings(prompt_bufnr)]],
          }, "\n"),
          table.concat({
            [[-- 汉化：which_key 菜单显示的 action 名 -> 中文（查不到则显示原名）]],
            [[-- 由 core/i18n/patches/telescope-whichkey.lua 维护]],
            [[local action_cn = {]],
            [[  close = "关闭",]],
            [[  nop = "无操作",]],
            [[  select_default = "打开选中项",]],
            [[  select_horizontal = "水平分屏打开",]],
            [[  select_vertical = "垂直分屏打开",]],
            [[  select_tab = "在新标签页打开",]],
            [[  move_selection_next = "选中下一项",]],
            [[  move_selection_previous = "选中上一项",]],
            [[  move_selection_worse = "移到分数更低处",]],
            [[  move_selection_better = "移到分数更高处",]],
            [[  move_to_top = "移到顶部",]],
            [[  move_to_middle = "移到中间",]],
            [[  move_to_bottom = "移到底部",]],
            [[  toggle_selection = "多选/取消多选",]],
            [[  preview_scrolling_up = "预览窗上翻",]],
            [[  preview_scrolling_down = "预览窗下翻",]],
            [[  results_scrolling_up = "结果列表上翻",]],
            [[  results_scrolling_down = "结果列表下翻",]],
            [[  send_to_qflist = "加入快速修复列表",]],
            [[  send_selected_to_qflist = "把选中项加入快速修复列表",]],
            [[  open_qflist = "打开快速修复列表",]],
            [[  complete_tag = "补全标签",]],
            [[  which_key = "显示本键位表",]],
            [[  delete_buffer = "删除缓冲区",]],
            [[  add_to_qflist = "加入快速修复列表",]],
            [[  insert_symbol = "插入符号",]],
            [[  insert_value = "插入取值",]],
            [[  edit_command = "编辑命令",]],
            [[  paste = "粘贴",]],
            [[  cycle_history_next = "下一条历史",]],
            [[  cycle_history_prev = "上一条历史",]],
            [[  toggle_prompt = "切换搜索框",]],
            [[  center = "居中",]],
            [[  smart_send_to_qflist = "智能加入快速修复列表",]],
            [[  open = "打开",]],
            [[  file_edit = "编辑文件",]],
            [[  file_split = "分屏打开文件",]],
            [[  file_vsplit = "垂直分屏打开",]],
            [[  file_tab = "新标签页打开",]],
            [[  git_switch = "切换 Git 目标",]],
            [[  run_builtin = "执行内置命令",]],
            [[}]],
            [[]],
            [[-- 把一个 action 名翻译成中文；支持 "a + b" 组合形式]],
            [[]],
            [[local function cn_action(name)]],
            [[  if action_cn[name] ~= nil then]],
            [[    return (action_cn[name])]],
            [[  end]],
            [[  local parts = vim.split(name, " + ", { plain = true })]],
            [[  if #parts > 1 then]],
            [[    for i, p in ipairs(parts) do]],
            [[      parts[i] = action_cn[p] or p]],
            [[    end]],
            [[    return table.concat(parts, " + ")]],
            [[  end]],
            [[  return name]],
            [[end]],
            [[]],
            [[--- Utility to collect mappings of prompt buffer in array of `{mode, keybind, name}`.]],
            [[---@param prompt_bufnr number: The prompt bufnr]],
            [[function utils.get_registered_mappings(prompt_bufnr)]],
          }, "\n"),
        },
        {
          [[          table.insert(ret, { mode = mode, keybind = mapping.lhs, desc = mapping.desc:sub(11) })]],
          [[          table.insert(ret, { mode = mode, keybind = mapping.lhs, desc = cn_action(mapping.desc:sub(11)) })]],
        },
        {
          table.concat({
            [[            mode = mode,]], 
            [[            keybind = mapping.lhs,]], 
            [[            desc = fname,]], 
          }, "\n"),
          table.concat({
            [[            mode = mode,]], 
            [[            keybind = mapping.lhs,]], 
            [[            desc = cn_action(fname),]], 
          }, "\n"),
        },
      },
    },
  },
}
