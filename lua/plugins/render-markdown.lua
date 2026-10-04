local md_render_enabled = false

vim.keymap.set("n", "<leader>mt", function()
  local render = require("render-markdown")
  if md_render_enabled then
    render.disable()
    md_render_enabled = false
  else
    render.enable()
    md_render_enabled = true
  end
end, { desc = "开关 Markdown 渲染" })
