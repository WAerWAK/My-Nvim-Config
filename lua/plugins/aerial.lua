require("aerial").setup({
  -- Prioritize backends for symbol extraction
  backends = { "treesitter", "lsp", "markdown", "man" },
  
  -- Layout settings
  layout = {
    default_direction = "prefer_right",
    placement = "window",
    max_width = { 40, 0.2 },
    min_width = 10,
    resize_to_content = true,
  },
  
  -- Show only relevant symbol types
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Method",
    "Struct",
  },
  
  -- Highlight settings
  highlight_mode = "split_width",
  highlight_closest = true,
  highlight_on_jump = 300,
  
  -- Auto-open settings
  open_automatic = false,
  attach_mode = "window",
  
  -- Performance settings
  disable_max_lines = 10000,
  disable_max_size = 2000000,
  
  -- Keymaps (using defaults)
  keymaps = {
    ["<CR>"] = "actions.jump",
    ["<C-v>"] = "actions.jump_vsplit",
    ["<C-s>"] = "actions.jump_split",
    ["p"] = "actions.scroll",
    ["{"] = "actions.prev",
    ["}"] = "actions.next",
    ["q"] = "actions.close",
    ["o"] = "actions.tree_toggle",
    ["l"] = "actions.tree_open",
    ["h"] = "actions.tree_close",
  },
  
  -- Floating window settings
  float = {
    border = "rounded",
    relative = "cursor",
    max_height = 0.9,
    min_height = { 8, 0.1 },
  },
})
