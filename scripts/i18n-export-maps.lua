-- 导出当前仍未汉化的英文键位映射（供阶段 3 使用）
local modes = { "n", "v", "x", "s", "o", "i", "t", "c" }
local lines = {}
local total, cn, en = 0, 0, 0
for _, m in ipairs(modes) do
  for _, mp in ipairs(vim.api.nvim_get_keymap(m)) do
    local d = mp.desc
    if d and d ~= "" then
      total = total + 1
      if d:find("[\228-\233]") then
        cn = cn + 1
      else
        en = en + 1
        lines[#lines + 1] = table.concat({
          m,
          mp.lhs or "",
          mp.rhs or "<Lua>",
          mp.callback and "callback" or "rhs",
          d,
        }, "\t")
      end
    end
  end
end
local f = io.open(vim.fn.stdpath("state") .. "/en-maps.txt", "w")
f:write(("总数=%d 中文=%d 英文=%d\n"):format(total, cn, en))
f:write(table.concat(lines, "\n"))
f:close()
print(("总数=%d 中文=%d 英文=%d -> %s"):format(total, cn, en, vim.fn.stdpath("state") .. "/en-maps.txt"))
