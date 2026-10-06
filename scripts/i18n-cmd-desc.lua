-- 枚举所有用户命令里仍是英文的描述（definition 字段即 :help 中显示的说明）
local cmds = vim.api.nvim_get_commands({})
local rows = {}
for name, c in pairs(cmds) do
  local d = c.definition or ""
  if d ~= "" and d:match("^[%w%(%)'`:/%.,<>%[%]!%?%s%-]*$") and d:match("%a") then
    -- 纯 ASCII 且有英文单词 -> 尚未汉化
    rows[#rows + 1] = { name, d }
  end
end
table.sort(rows, function(a, b)
  return a[1] < b[1]
end)

local out = { ("未汉化的命令描述 = %d 条"):format(#rows), "" }
for _, r in ipairs(rows) do
  out[#out + 1] = ("%-30s %s"):format(r[1], r[2])
end
local f = io.open(vim.fn.stdpath("state") .. "/cmd-desc.txt", "w")
f:write(table.concat(out, "\n"))
f:close()
print(table.concat(out, "\n"))
