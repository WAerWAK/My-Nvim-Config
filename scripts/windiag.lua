-- 窗口诊断脚本：在 nvim 中执行  :luafile ~/windiag.lua
local wins = vim.api.nvim_list_wins()
local byft, byplugin = {}, {}
for _, w in ipairs(wins) do
  local buf = vim.api.nvim_win_get_buf(w)
  local ft = vim.bo[buf].filetype
  if ft == "" then ft = "(无)" end
  byft[ft] = (byft[ft] or 0) + 1
end
-- 按名称推断来源插件
for ft, n in pairs(byft) do
  local owner = "?"
  if ft:find("smear") then owner = "smear-cursor"
  elseif ft:find("NvimTree") then owner = "nvim-tree"
  elseif ft:find("aerial") then owner = "aerial"
  elseif ft:find("noice") then owner = "noice"
  elseif ft:find("notify") or ft:find("notify") then owner = "nvim-notify"
  elseif ft:find("Telescope") then owner = "telescope"
  elseif ft:find("toggleterm") or ft == "toggleterm" then owner = "toggleterm"
  elseif ft:find("markdown") then owner = "render-markdown"
  elseif ft == "lua" or ft == "vim" or ft == "markdown" then owner = "正常编辑窗口"
  end
  byplugin[owner] = (byplugin[owner] or 0) + n
end
local out = { "窗口总数: " .. #wins, "", "按 filetype 统计:" }
for k, v in pairs(byft) do out[#out+1] = string.format("  %-20s %d", k, v) end
out[#out+1] = ""
out[#out+1] = "按来源插件统计:"
for k, v in pairs(byplugin) do out[#out+1] = string.format("  %-20s %d", k, v) end
vim.notify(table.concat(out, "\n"))
print(table.concat(out, "\n"))