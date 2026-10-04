# My-Nvim-Config

个人使用的 Neovim 完整配置，基于 **lazy.nvim** 从零搭建，为 Windows 环境做了适配与汉化。

换电脑时只需克隆本仓库并执行一条安装命令，即可还原完全一致的编辑环境。

---

## 目录

- [特性一览](#特性一览)
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [仓库结构](#仓库结构)
- [配置详解](#配置详解)
- [键位速查](#键位速查)
- [日常维护](#日常维护)
- [常见问题](#常见问题)
- [更新日志](#更新日志)

---

## 特性一览

| 能力 | 实现 | 说明 |
|------|------|------|
| 插件管理 | lazy.nvim | 34 个插件，版本锁定在 `lazy-lock.json` |
| 语法高亮 | nvim-treesitter（**main 分支**） | 20 个语言解析器，含 Java / PowerShell / C# |
| 代码补全 | nvim-cmp + LuaSnip | LSP、代码片段、文件路径、缓冲区多源补全 |
| 语言服务器 | mason + nvim-lspconfig | 7 个 LSP：Lua、TypeScript、CSS、Vue、HTML、C/C++、Java |
| 文件查找 | Telescope | 标题已汉化，覆盖 35 个 picker |
| 文件树 | nvim-tree | 快捷键 `<空格>e` |
| 代码大纲 | aerial | 快捷键 `<空格>a` |
| 状态栏 | lualine | 未命名文件等标记已汉化 |
| Git | gitsigns | 左侧改动标记 |
| Markdown | render-markdown | 开启即渲染（标题放大、表格画框） |
| **界面汉化** | 自研补丁机制 | 启动页、`:Lazy`、`:Mason`、Telescope、键位提示等 |
| 内置键位汉化 | 自研映射 | `<C-w>` 窗口系列 18 个 + `g` 系列 3 个 |

### 界面汉化说明

Neovim 本身没有中文语言包，插件的界面文本也全部硬编码在源码里。本配置通过 `lua/core/chinese.lua` 的 **patch 机制**解决：

- 在启动后延迟检查并替换插件源码中的界面文本
- **幂等**：文本已替换则跳过，不会重复处理
- **抗更新**：插件更新后下次启动自动重新汉化

已汉化范围：启动页、`:Lazy` 主界面、`:Mason` 主界面与帮助页、Telescope 标题与预览窗、nvim-tree 输入提示、Comment.nvim 注释键位、`<C-w>` 与 `g` 内置键位菜单、常用系统消息。

---

## 环境要求

### 必需

| 组件 | 版本 | 用途 |
|------|------|------|
| Neovim | **0.12.0+** | 配置使用了 0.12 的 API |
| git | 任意 | 下载插件 |
| gcc | 任意 | 编译 treesitter 解析器 |
| tree-sitter CLI | 0.27+ | **驱动解析器编译流程**（与 gcc 缺一不可）|
| ripgrep | 任意 | Telescope 全文搜索 |
| fd | 任意 | Telescope 文件查找 |
| Node.js | 18+ | vtsls / css-lsp 等所需 |
| Nerd Font | 任意 | 图标显示（推荐 JetBrainsMono NF）|

### 可选

| 组件 | 用途 | 缺失影响 |
|------|------|----------|
| Java 21+ | jdtls（Java LSP）| Java 智能提示不可用 |
| win32yank | Windows 剪贴板互通 | 复制粘贴报错 |
| lazygit | Git 终端界面 | 无影响 |
| PowerShell 7 | toggleterm 的 shell | `Alt+p` 终端打不开 |

> **gcc 与 tree-sitter CLI 的分工**：gcc 把 C 源码编译成 `.so`，tree-sitter CLI 驱动整个编译流程（生成 `parser.c` 并调用 gcc）。只装 gcc 会报 `ENOENT: 'tree-sitter'`。

---

## 快速开始

### Windows

```powershell
# 1. 安装 Neovim 与依赖（以 scoop 为例）
scoop install neovim gcc ripgrep fd lazygit win32yank

# 2. 安装 tree-sitter CLI
#    注意：npm 11 起默认拦截安装脚本，必须加 --allow-scripts
npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli

# 3. 让 cc 命令可用（nvim-treesitter 查找的是 cc，scoop 的 gcc 只提供 gcc.exe）
Copy-Item "$(scoop prefix gcc)\bin\gcc.exe" "$(scoop prefix gcc)\bin\cc.exe"

# 4. 备份已有配置（如有）
Move-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.bak" -ErrorAction SilentlyContinue

# 5. 克隆本仓库到配置目录
git clone https://github.com/WAerWAK/My-Nvim-Config.git "$env:LOCALAPPDATA\nvim"

# 6. 首次启动，等待插件自动下载
nvim
```

启动后执行一次 `:TSUpdate` 编译语法解析器（**首次必须**）。

### Linux / macOS

```bash
# 1. 依赖（以 apt 为例，macOS 用 brew）
sudo apt install neovim gcc ripgrep fd-find nodejs npm
npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli

# 2. 克隆配置
git clone https://github.com/WAerWAK/My-Nvim-Config.git ~/.config/nvim

# 3. 首次启动
nvim
```

> Linux 上需安装 Nerd Font，并在终端设置中启用。`clipboard` 依赖 `xclip` 或 `wl-clipboard`。

### 验证安装

```vim
:checkhealth          " 全面健康检查
:Lazy                 " 查看插件状态（应为 34 个）
:TSInstall lua        " 测试解析器编译
```

---

## 仓库结构

```
.
├── init.lua                    # 入口：按顺序加载各模块
├── lazy-lock.json              # 插件版本锁定（重要，勿随意改写）
├── lua/
│   ├── core/                   # 基础配置
│   │   ├── options.lua         # 编辑器选项（行号、缩进、剪贴板、主题）
│   │   ├── keymaps.lua         # 自定义快捷键（含中文说明）
│   │   ├── builtin-keys.lua    # 为 Neovim 内置键位补中文说明
│   │   └── chinese.lua         # 汉化核心：词汇表 + 消息翻译 + 插件界面 patch
│   └── plugins/                # 各插件独立配置
│       ├── plugins-setup.lua   # lazy.nvim 初始化与插件清单（最常改）
│       ├── lsp.lua             # 语言服务器
│       ├── cmp.lua             # 补全
│       ├── treesitter.lua      # 语法高亮
│       ├── telescope.lua       # 文件查找（标题汉化）
│       ├── which-key.lua       # 键位提示菜单
│       ├── dashboard.lua       # 启动页（含主题文本自动汉化）
│       ├── lualine.lua         # 状态栏
│       ├── nvim-tree.lua       # 文件树
│       ├── aerial.lua          # 代码大纲
│       ├── render-markdown.lua # Markdown 渲染
│       ├── toggleterm.lua      # 内置终端
│       ├── gitsigns.lua        # Git 标记
│       ├── bufferline.lua      # 缓冲区标签
│       ├── comment.lua         # 注释
│       ├── autopairs.lua       # 括号配对
│       ├── indent-blankline.lua# 缩进线
│       ├── notify.lua          # 通知
│       ├── noice.lua           # 命令行美化
│       ├── smear-cursor.lua    # 光标动画（当前已禁用，见常见问题）
│       └── ...
├── scripts/
│   └── windiag.lua             # 窗口诊断脚本（排查幽灵窗口用）
└── docs/
    └── HUAHUANVIM-移植说明.md   # 本配置的来源与移植过程记录
```

---

## 配置详解

### 编辑器选项（`lua/core/options.lua`）

```lua
opt.relativenumber = true    -- 相对行号
opt.number = true            -- 显示行号
opt.tabstop = 4              -- Tab 宽度
opt.shiftwidth = 4           -- 缩进宽度
opt.expandtab = false        -- false = 使用真实制表符
opt.wrap = false             -- 不自动折行
opt.clipboard:append("unnamedplus")  -- 与系统剪贴板互通
opt.ignorecase = true        -- 搜索忽略大小写
opt.smartcase = true         -- 含大写时区分大小写
vim.cmd[[colorscheme tokyonight-moon]]  -- 主题
```

**可选主题**：`tokyonight`、`tokyonight-moon`、`tokyonight-night`、`tokyonight-storm`、`tokyonight-day`。

### 插件清单（`lua/plugins/plugins-setup.lua`）

新增插件的写法：

```lua
local plugins = {
    -- 简单插件：只写仓库名
    { "tpope/vim-surround" },

    -- 需要配置的插件
    {
        "作者/仓库名",
        event = "VeryLazy",              -- 延迟加载时机
        dependencies = { "依赖插件" },
        build = ":TSUpdate",             -- 安装/更新后执行的构建命令
    },
}
```

延迟加载字段：

| 字段 | 含义 |
|------|------|
| `event = "VeryLazy"` | 启动完成后加载 |
| `event = "BufReadPre"` | 打开文件前加载 |
| `ft = { "markdown" }` | 仅在指定文件类型加载 |
| `cmd = "SomeCommand"` | 仅在使用该命令时加载 |

### 语言服务器（`lua/plugins/lsp.lua`）

当前配置 7 个 LSP，均通过 mason 安装：

| 服务器 | 语言 | 额外依赖 |
|--------|------|----------|
| lua-language-server | Lua | — |
| vtsls | TypeScript / JavaScript | Node.js |
| css-lsp | CSS / SCSS / LESS | Node.js |
| vue-language-server | Vue | Node.js |
| html-lsp | HTML | Node.js |
| clangd | C / C++ | — |
| jdtls | Java | Java 21+ |

**新增语言支持**：

```vim
:MasonInstall pyright        " 1. 安装语言服务器
```

```lua
-- 2. 在 lsp.lua 中追加配置（capabilities 变量已在该文件开头定义）
require'lspconfig'.pyright.setup{
    capabilities = capabilities,
}
```

```vim
:TSInstall python            " 3. 安装语法解析器
```

### 语法解析器（`lua/plugins/treesitter.lua`）

共 20 个：`bash` `c` `c_sharp` `cpp` `css` `java` `javascript` `json` `lua` `markdown` `markdown_inline` `powershell` `python` `rust` `toml` `tsx` `typescript` `vim` `vimdoc` `yaml`

增删语言时修改文件中的 `parsers` 列表，缺失的会在启动时自动补装。

### 汉化机制（`lua/core/chinese.lua`）

三个部分：

1. **词汇表** `M.t` —— 统一管理界面用词
2. **消息翻译** `patterns` —— 正则替换高频系统消息（如 `written` → `已保存`）
3. **插件界面 patch** `plugin_patches` —— 改写插件源码中的界面文本

新增汉化规则的写法：

```lua
{
    path = "插件名/lua/路径/文件.lua",
    replacements = {
        { [[原文]], [[译文]] },
    },
},
```

> **注意**：`patch` 只替换界面提示文本（`desc` / `title` / `prompt`），**不要**替换逻辑用的字符串。

---

## 键位速查

leader 键为**空格**。按下空格停约 0.3 秒会弹出 which-key 菜单（中文）。

### 基础编辑

| 键位 | 模式 | 功能 |
|------|------|------|
| `jk` | 插入 | 退出插入模式 |
| `:w` / `:wq` / `:q!` | 普通 | 保存 / 保存退出 / 强制退出 |
| `J` / `K` | 可视 | 选中内容下移 / 上移 |
| `gc` / `gcc` | 可视 / 普通 | 注释选中行 / 注释当前行 |
| `gb` / `gbc` | 可视 / 普通 | 块注释 / 注释当前块 |

### 窗口与分屏

| 键位 | 功能 |
|------|------|
| `<空格>sv` / `<空格>sh` | 垂直 / 水平分屏 |
| `<空格>sc` | 关闭当前窗口 |
| `Ctrl+h/j/k/l` | 跳到左 / 下 / 上 / 右窗口 |
| `<C-w>s` / `<C-w>v` | 水平 / 垂直分屏 |
| `<C-w>c` / `<C-w>o` | 关闭当前窗口 / 只保留当前窗口 |
| `<C-w>=` | 所有窗口等宽等高 |
| `<C-w>+` / `<C-w>-` | 增加 / 减少高度 |
| `<C-w>>` / `<C-w><` | 增加 / 减少宽度 |
| `<C-w>x` | 与相邻窗口互换位置 |
| `<C-w>T` | 把当前窗口移到新标签页 |
| `Shift+L` / `Shift+H` | 下一个 / 上一个缓冲区 |
| `<空格>x` | 关闭当前缓冲区 |

### 查找与浏览

| 键位 | 功能 |
|------|------|
| `<空格>ff` | 查找文件 |
| `<空格>fr` | 最近打开的文件 |
| `<空格>fg` | 全局搜索内容 |
| `<空格>fb` | 缓冲区列表 |
| `<空格>fh` | 搜索帮助文档 |
| `<空格>e` | 开关文件树 |
| `<空格>a` | 开关代码大纲 |
| `<空格>nh` | 取消搜索高亮 |

### 代码导航（LSP）

| 键位 | 功能 |
|------|------|
| `gd` | 跳转到定义 |
| `grn` | 重命名符号 |
| `gra` | 代码操作（快速修复） |
| `grr` | 列出所有引用 |
| `gri` | 跳转到实现 |
| `grt` | 跳转到类型定义 |
| `]d` / `[d` | 跳到下 / 上一个诊断 |
| `]q` / `[q` | 下 / 上一个 quickfix |

### 其他

| 键位 | 功能 |
|------|------|
| `gg` / `ge` / `gf` | 文件开头 / 上一个词尾 / 打开光标下的文件 |
| `<空格>ll` / `<空格>lm` | 打开插件管理 / LSP 工具管理 |
| `Alt+p` | 开关浮动终端 |
| `<空格>mt` | 开关 Markdown 渲染 |

---

## 日常维护

### 更新插件（重要）

本配置**刻意关闭了自动更新检查**，原因是全量更新会把 `nvim-lspconfig` 等升级到新版 API，导致 `lsp.lua` 的写法失效。

**推荐做法**：只按需更新单个插件。

```vim
:Lazy                    " 打开界面，光标移到插件后按 U 升级它
:Lazy update 插件名       " 或命令行方式
```

**出问题就回退**：

```vim
:Lazy restore            " 按 lazy-lock.json 把所有插件恢复到记录版本
```

> `lazy-lock.json` 是版本基准。**只要它没被改写，任何插件更新都能回退** —— 建议定期把它复制一份留档。

### 备份与迁移

| 内容 | 路径 | 是否需要备份 |
|------|------|--------------|
| 配置 | `%LOCALAPPDATA%\nvim`（本仓库）| ✅ 核心，仅 50 KB |
| 插件本体 | `nvim-data\lazy\` | ❌ 可自动重新下载 |
| LSP 服务器 | `nvim-data\mason\` | ❌ 可自动重新安装 |
| 历史记录 | `nvim-data\shada\` | ❌ 无必要 |

**迁移到新机器**：按[快速开始](#快速开始)执行即可，插件会依据 `lazy-lock.json` 自动还原到完全相同的版本。

### 卸载

```powershell
# 1. 卸载程序
scoop uninstall neovim

# 2. 删除配置与数据
#    %LOCALAPPDATA%\nvim        （即本仓库）
#    %LOCALAPPDATA%\nvim-data   （插件、LSP、历史记录，约 150 MB+）
```

仅重置插件：删除 `nvim-data\lazy` 即可，配置与锁定文件保留。

---

## 常见问题

### Q1：窗口数异常多，`<C-w>w` 要按很多次？

执行诊断脚本查看窗口构成：

```vim
:luafile ~/windiag.lua
```

**原因**：`smear-cursor`（光标拖尾动画）失控，每帧创建一个辅助窗口却未回收，实测堆积 23~35 个。已升级到上游最新版仍无效，故**本配置已禁用它**（`plugins-setup.lua` 中该行已注释）。

**如需恢复**：取消该行注释。它只提供视觉效果，禁用无功能损失。

### Q2：打开 Markdown 报 `attempt to call method 'range' (a nil value)`？

nvim-treesitter 分支选错。**必须用 `main` 分支**（要求 Neovim 0.12+），`master` 分支只兼容 0.11。

```powershell
git -C $env:LOCALAPPDATA\nvim-data\lazy\nvim-treesitter rev-parse --abbrev-ref HEAD
# 应输出 main
```

切换分支后必须执行 `:TSUpdate` 重新编译全部解析器。

### Q3：解析器编译失败，报 `ENOENT: 'tree-sitter'`？

缺 tree-sitter CLI：

```powershell
npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
```

注意 `--allow-scripts` 不能省 —— npm 11 起默认拦截依赖的安装脚本，不加则二进制不会下载。

### Q4：复制粘贴报错？

`options.lua` 启用了 `clipboard=unnamedplus`，Windows 上依赖 win32yank：

```powershell
scoop install win32yank
```

### Q5：不小心执行了全量更新，配置报错？

```vim
:Lazy restore
```

按 `lazy-lock.json` 恢复所有插件版本。**前提是该文件没被一并破坏**，所以建议定期备份它。

### Q6：文件树/状态栏图标显示成方块？

终端字体不是 Nerd Font。改为 `JetBrainsMono NF` 或其它 Nerd Font 即可。

### Q7：Java 的 LSP 起不来？

jdtls 需要 **Java 21+**。检查：

```powershell
java -version
```

### Q8：插件界面又变回英文了？

说明该插件更新后源码文本有变动，导致汉化规则失配。查看启动通知里提示的文件，在 `lua/core/chinese.lua` 的 `plugin_patches` 中按新文本更新对应规则即可。

### Q9：想让 `gc`/`gcc`/`gb` 的说明变中文？

已汉化。做法是**直接改 Comment.nvim 源码里的 `desc` 字符串**（由 patch 机制自动完成）—— 注意**不要**在 `keymaps.lua` 里重设这些键位：它们是 Lua 回调型映射（`rhs` 为 `nil`），重设会导致注释功能失效。

### Q10：修改配置后没生效？

```vim
:source $MYVIMRC       " 重载配置（部分插件需重启）
:Lazy reload 插件名     " 重载指定插件
```

最稳妥的方式是重启 nvim。

---

## 更新日志

### 2026-10-04

**初始版本**

- 从 [HUAHUANVIM](https://github.com/huahuaid/HUAHUANVIM) 的 One~Six 六分支合并移植（详见 `docs/`）
- 修复上游 7 处 bug：`capabilities` 未定义、`css_ls` 名称错误、`clangd` 硬编码路径、dashboard 依赖缺失、`rainbow-delimiters` 与 nvim 0.12 不兼容等
- Windows 与 Neovim 0.12 适配：gcc 编译器、`cc` 别名、`win32yank` 剪贴板、`vim.uv` API
- nvim-treesitter 升级到 **main 分支**（适配 Neovim 0.12），20 个解析器
- 界面汉化：启动页、`:Lazy`、`:Mason`（含帮助页）、Telescope、nvim-tree、Comment 键位
- 内置键位汉化：`<C-w>` 窗口系列 18 个 + `g` 系列 3 个
- 精简 mason 包：48 个（2.1 GB）→ 9 个（416 MB）
- 禁用 `smear-cursor`（窗口泄漏问题）

---

## 致谢

- 配置基础来自 [huahuaid/HUAHUANVIM](https://github.com/huahuaid/HUAHUANVIM)
- 各插件作者与 [lazy.nvim](https://github.com/folke/lazy.nvim) 生态

## 许可

MIT License，详见 [LICENSE](LICENSE)。