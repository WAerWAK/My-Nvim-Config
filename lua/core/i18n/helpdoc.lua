-- 为配置目录的 doc/ 生成中文帮助索引（tags-cn）
-- 背景：'helplang' 设为 "cn" 后，:help 会先找 doc/tags-cn。nvim 的 :helptags
--       默认只生成 doc/tags，所以这里补一份 tags-cn（内容相同即可）。
-- 用法：手动改完 doc/ 后执行
--   :lua require("core.i18n.helpdoc").sync_tags()
-- 或直接 :I18nHelpTags

local M = {}

--- 同步 doc/tags -> doc/tags-cn
---@return boolean ok, string msg
function M.sync_tags()
  local doc = vim.fn.stdpath("config") .. "/doc"
  if vim.fn.isdirectory(doc) ~= 1 then
    return false, "没有 doc 目录：" .. doc
  end
  -- 先让 nvim 重新生成 tags（会顺带为新增的 .cnx/.txt 建索引）
  pcall(vim.cmd, "helptags " .. vim.fn.fnameescape(doc))

  local tags = doc .. "/tags"
  if vim.fn.filereadable(tags) ~= 1 then
    return false, "没有生成 doc/tags（doc/ 里可能没有帮助文件）"
  end
  local fd = io.open(tags, "rb")
  local data = fd:read("*a")
  fd:close()
  local out = io.open(doc .. "/tags-cn", "wb")
  out:write(data)
  out:close()
  return true, "已生成 doc/tags-cn（中文帮助索引）"
end

function M.setup()
  vim.api.nvim_create_user_command("I18nHelpTags", function()
    local ok, msg = M.sync_tags()
    print((ok and "✔ " or "✘ ") .. msg)
  end, { desc = "重新生成中文帮助索引（doc/tags-cn）" })

  -- 启动时静默同步一次（doc 内容没变时开销可忽略）
  if vim.fn.isdirectory(vim.fn.stdpath("config") .. "/doc") == 1 then
    vim.defer_fn(function()
      M.sync_tags()
    end, 2000)
  end
end

return M
