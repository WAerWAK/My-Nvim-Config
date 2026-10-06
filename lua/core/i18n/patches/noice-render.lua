-- =====================================================================
--  noice.nvim 消息渲染时的翻译注入
-- =====================================================================
--  为什么必须在这里做：
--    noice **完全接管**消息显示 —— 实测 `:w` 之后 `:messages` 为空、
--    `vim.notify` / `nvim.api.nvim_echo` 调用次数均为 0（不走 Lua 侧）。
--    所以 core/chinese.lua 的两个钩子都到不了 noice 渲染的消息，
--    「已保存」「E492: 不是编辑器命令」这类文案只能在这一层翻。
--
--  ⚠️ 曾经踩的坑（2026-10-06）：**不能在 message 层替换 content()**。
--     nui 的文本渲染按 chunk 走，用的是 **Text 自己的 `_length`**：
--        nui/text/init.lua: Text:render    → col_end = byte_start + self:length()
--                           Text:highlight → extmark.end_col = byte_start + self:length()
--     只把 message.content() 换成中文、而 Text 的 _length 还是英文长度时，
--     若中文更长（全角标点常见），end_col 就越界：
--        Invalid 'end_col': out of range（nui/text/init.lua:73）
--
--  ✔ 正确做法：遍历 message._lines（NuiLine）→ _texts（NuiText），
--     对每个 Text 用 `Text:set(译文)`。set() 内部会同步重算
--        _content / _length = strlen(译文) / _width = strwidth(译文)
--     长度与实际显示一致，nui 算区间就不会越界。
--     译文与原文相同（没命中规则）时不做任何改动。
-- =====================================================================

return {
  rules = {
    {
      path = "noice.nvim/lua/noice/text/format/init.lua",
      note = "noice 消息渲染翻译注入（1 条，Text 层同步长度）",
      replacements = {
        {
          table.concat({
            [[function M.format(message, format, opts)]],
            [[  opts = vim.tbl_deep_extend("force", vim.deepcopy(Config.options.format), opts or {})]],
          }, "\n"),
          table.concat({
            [[--- 汉化注入：在 NuiText 层翻译，用 Text:set() 同步 _length/_width，]],
            [[--- 避免 nui 用旧的英文长度算高亮区间而越界。]],
            [[--- 详见 lua/core/i18n/patches/noice-render.lua 的说明。]],
            [[local function i18n_translate_texts(message)]],
            [[  if type(message) ~= "table" then]],
            [[    return]],
            [[  end]],
            [[  local lines = message._lines]],
            [[  if type(lines) ~= "table" then]],
            [[    return]],
            [[  end]],
            [[  local chinese = package.loaded["core.chinese"] or require("core.chinese")]],
            [[  if type(chinese) ~= "table" or type(chinese.translate) ~= "function" then]],
            [[    return]],
            [[  end]],
            [[  for _, line in ipairs(lines) do]],
            [[    local texts = type(line) == "table" and line._texts]],
            [[    if type(texts) == "table" then]],
            [[      for _, text in ipairs(texts) do]],
            [[        local raw = type(text) == "table" and text._content]],
            [[        if type(raw) == "string" and raw ~= "" then]],
            [[          local out = chinese.translate(raw)]],
            [[          if out ~= raw and type(text.set) == "function" then]],
            [[            text:set(out) -- 同步 _content / _length / _width]],
            [[          end]],
            [[        end]],
            [[      end]],
            [[    end]],
            [[  end]],
            [[end]],
            [[]],
            [[function M.format(message, format, opts)]],
            [[  pcall(i18n_translate_texts, message)]],
            [[  opts = vim.tbl_deep_extend("force", vim.deepcopy(Config.options.format), opts or {})]],
          }, "\n"),
        },
      },
    },
  },
}
