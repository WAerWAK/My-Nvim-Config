local opt = vim.opt

-- 行号（相对行号便于用计数跳转：5j 下移 5 行、12k 上移 12 行、d3j 删除含当前行 4 行）
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 4        -- 制表符显示为4个空格宽
opt.shiftwidth = 4     -- 用于自动缩进的宽度
opt.expandtab = false  -- 使用制表符进行缩进
opt.autoindent = true

-- 防止包裹
opt.wrap = false

-- 光标行
opt.cursorline = false

-- 启用鼠标
opt.mouse:append("a")

-- 系统剪贴板
opt.clipboard:append("unnamedplus")

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"

-- 设置主题
vim.cmd[[colorscheme tokyonight-moon]]

-- ===== 中文优先 =====
-- 'helplang'：`:help` 查找帮助时优先中文（help.cnx / tags-cn）。
--   官方 nvim 只自带英文帮助，但：
--     · `:Tutor` 有官方中文教程（runtime/tutor/zh/），设了它才会默认用中文；
--     · 以后若在 doc/ 放入中文帮助页（help.cnx + helptags 生成的 tags-cn），
--       会自动优先显示中文，找不到时回退英文，无副作用。
opt.helplang = "cn,en"
