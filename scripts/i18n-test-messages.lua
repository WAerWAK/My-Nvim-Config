-- 消息翻译全量自检：官方消息命中率 + 误伤检查
-- 用法：
--   nvim --headless -u NONE \
--     --cmd "lua package.path=[[<配置>/lua/?.lua;<配置>/lua/?/init.lua;]]..package.path" \
--     -c "luafile <仓库>/scripts/i18n-test-messages.lua" -c "qa!"
local m = require("core.i18n.messages")
local c = require("core.chinese")

local out = { ("消息规则总数 = %d"):format(#m), "" }

-- ---------- 1) 误伤检查：正文/正常文本必须原样返回 ----------
local passive = {
  "local x = 1",
  "function M.foo() return 42 end",
  "ERROR: something failed in user code",
  "The written word is powerful",
  "3 lines changed in the document body",
  "Press ENTER to continue reading this novel",
  "E486 pattern appears in this sentence",
  "Some unrelated English text",
  "Interrupted by a signal handler in C code",
  "return a + b * (c - d)",
  "E471 is mentioned in the docs but not here",
  "git commit -m 'fix: E13 file exists'",
  "let line = lines[i]",
  "E905x not a message",
  "  line  ",
}
local hurt = 0
out[#out + 1] = "== 误伤检查（应全部「未改动」）=="
for _, s in ipairs(passive) do
  local t = c.translate(s)
  local ok = (t == s)
  if not ok then
    hurt = hurt + 1
  end
  out[#out + 1] = ("  %-52s -> %s  %s"):format(s, t, ok and "未改动 ✔" or "被改 ✘")
end

-- ---------- 2) 典型命中检查 ----------
local samples = {
  "written",
  "yanked",
  "search wrapped around the end of file",
  "E486: Pattern not found: foo",
  "E37: No write since last change",
  "E470: Command aborted",
  "E13: File exists (add ! to override)",
  'E158: Invalid buffer name: foo',
  "E475: Invalid argument: xx",
  'E15: Invalid expression: "1 +"',
  'E17: "some/dir" is a directory',
  "E685: Internal error: boom",
  "Interrupted",
  "E171: Missing :endif",
  "E588: :endwhile without :while",
  "E964: Invalid column number: 42",
  "E966: Invalid line number: 7",
}
out[#out + 1] = ""
out[#out + 1] = "== 典型命中检查（应全部译成中文）=="
local miss = 0
for _, s in ipairs(samples) do
  local t = c.translate(s)
  local ok = (t ~= s) and t:find("[\228-\233]") ~= nil
  if not ok then
    miss = miss + 1
  end
  out[#out + 1] = ("  %-46s -> %s  %s"):format(s, t, ok and "已翻译 ✔" or "未命中 ✘")
end

-- ---------- 3) 官方 191 条逐条命中率 ----------
-- 原文清单来自 scripts/i18n-msg-list.lua（由 nvim v0.12.5 的 src/nvim/errors.h 提取）
-- 用本文件自身所在目录定位清单，无论脚本放在配置目录还是仓库都能找到
local this = debug.getinfo(1, "S").source:sub(2)
local dir = this:match("^(.*)[/\\][^/\\]*$") or "."
local listpath = dir .. "/i18n-msg-list.lua"
local hit, total = 0, 0
local missed = {}
local okList, msgs = pcall(dofile, listpath)
if okList and type(msgs) == "table" then
  for _, txt in ipairs(msgs) do
    total = total + 1
    -- 把 C 的 printf 占位符换成样例值：数字类 -> 42，文本类 -> xx
    -- 顺序要紧：先换 %ld/%d 这类数字占位符，再换 %s / %.*s
    local sample = txt:gsub("%%%-?[%d%.lhz]*[diufxX]", "42")
    sample = sample:gsub("%%%.[^%s]*s", "xx"):gsub("%%s", "xx")
    if c.translate(sample) ~= sample then
      hit = hit + 1
    elseif #missed < 10 then
      missed[#missed + 1] = txt
    end
  end
else
  out[#out + 1] = "（清单文件读取失败：" .. tostring(listpath) .. "，跳过命中率统计）"
end
out[#out + 1] = ""
if total > 0 then
  out[#out + 1] = ("官方消息命中率：%d / %d"):format(hit, total)
  if #missed > 0 then
    out[#out + 1] = "未命中示例："
    for _, s in ipairs(missed) do
      out[#out + 1] = "  " .. s:gsub("\n", "\\n")
    end
  end
end
out[#out + 1] = ("误伤条数：%d      典型漏译：%d"):format(hurt, miss)

local w = io.open(vim.fn.stdpath("state") .. "/msg-full-test.txt", "w")
w:write(table.concat(out, "\n"))
w:close()
print(table.concat(out, "\n"))
