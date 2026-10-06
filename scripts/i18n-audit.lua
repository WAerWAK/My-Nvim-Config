-- 针对性审计：只扫描配置里实际启用的插件，输出汉化覆盖率与残留明细
local i18n = require("core.i18n")

-- 配置中实际使用、且含界面文本的插件
local targets = {
  "lazy.nvim", "mason.nvim", "mason-lspconfig.nvim", "telescope.nvim",
  "nvim-tree.lua", "which-key.nvim", "noice.nvim", "nvim-notify",
  "lualine.nvim", "bufferline.nvim", "dashboard-nvim", "aerial.nvim",
  "gitsigns.nvim", "toggleterm.nvim", "render-markdown.nvim", "nvim-cmp",
  "LuaSnip", "nvim-autopairs", "Comment.nvim", "nvim-web-devicons",
  "nvim-lspconfig", "rainbow-delimiters.nvim", "plenary.nvim", "nui.nvim",
}

local findings, files = i18n.audit(targets)
local by_plugin, order = {}, {}
for _, f in ipairs(findings) do
  if not by_plugin[f.plugin] then
    by_plugin[f.plugin] = { n = 0 }
    order[#order + 1] = f.plugin
  end
  by_plugin[f.plugin].n = by_plugin[f.plugin].n + 1
end
table.sort(order, function(a, b)
  return by_plugin[a].n > by_plugin[b].n
end)

local out = {
  ("审计：%d 个插件，扫描了 %d 个「尚无中文」的源文件"):format(#targets, files),
  ("剩余英文界面文本 %d 条"):format(#findings),
  "",
  "插件                  剩余条数",
  "--------------------  --------",
}
for _, p in ipairs(order) do
  out[#out + 1] = ("%-20s  %8d"):format(p, by_plugin[p].n)
end

out[#out + 1] = ""
out[#out + 1] = "== 明细（最多 400 条）=="
for i = 1, math.min(#findings, 400) do
  local f = findings[i]
  out[#out + 1] = ("%s:%d  [%s] %s"):format(f.file, f.line, f.field, f.text)
end

local p = vim.fn.stdpath("state") .. "/audit-targeted.txt"
local fd = io.open(p, "w")
fd:write(table.concat(out, "\n"))
fd:close()
print(table.concat(out, "\n"))
print("\n明细已写入: " .. p)
