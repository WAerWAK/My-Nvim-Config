require("ibl").setup {
  enabled = true,
  indent = {
    char = "▎",
    -- highlight = highlightLine
  },
  exclude = {
    filetypes = { "help", "dashboard" },
    buftypes = { "terminal", "nofile" },
  },
  -- whitespace = {
  --   highlight = highlight,
  --   remove_blankline_trail = false,
  -- },
}
