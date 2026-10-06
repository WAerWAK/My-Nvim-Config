# My-Nvim-Config

> 一套可直接使用的 **Neovim 完整配置**，基于 lazy.nvim 搭建，开箱即用。
>
> 它不只是插件列表 —— 还包含 **Windows / Neovim 0.12 环境适配**、**界面中文化**、**版本锁定** 与 **一键安装脚本**，让你跳过反复试错，几分钟内得到一套稳定的编辑环境。

![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-0078D4)
![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-57A143?logo=neovim&logoColor=white)
![lazy.nvim](https://img.shields.io/badge/plugin%20manager-lazy.nvim-2C3E50)
![Shell](https://img.shields.io/badge/shell-PowerShell%207-5391FE)
![Terminal](https://img.shields.io/badge/terminal-WezTerm%20nightly-4E49EE)
![Prompt](https://img.shields.io/badge/prompt-Oh%20My%20Posh-3B82F6)
![Localization](https://img.shields.io/badge/UI-%E4%B8%AD%E6%96%87%E6%B1%89%E5%8C%96-E67E22)
![License](https://img.shields.io/badge/license-MIT-green)

<p align="center">
  本仓库配置由 <a url="https://github.com/huahuaid/HUAHUANVIM">huahuaid/HUAHUANVIM</a> 使用 DeepSeek V4.1 Flash 修改而来
</p>
<p align="center">
	可能存在未知问题，介意勿用
</p>

---

## 界面预览

<div align="center">
  <img src="docs/%E7%95%8C%E9%9D%A2%E9%A2%84%E8%A7%88.png" alt="My-Nvim-Config 界面预览" width="900">
  <p><em>左侧文件树 · 中间汉化启动页</em></p>
</div>

---

## 这套配置适合谁

**适合你，如果**：

- 想直接用一套能跑的 Neovim 配置，而不是从零折腾插件
- 在 **Windows** 上用 Neovim，被 `gcc` / `cc` / 剪贴板 / treesitter 编译等问题卡住过
- 使用 **Neovim 0.12+**，发现网上的配置因 API 变更而报错
- 希望界面是**中文**的，而不是满屏英文
- 想在不同电脑间**快速同步**同一套配置

**可能不适合你，如果**：

- 偏好 Vimscript 而非 Lua
- 需要极致精简（本配置含 34 个插件）
- 使用 Neovim 0.11 或更早（见 [环境要求](#环境要求)）

---

## 核心特性

| 能力 | 实现 | 说明 |
|------|------|------|
| 插件管理 | lazy.nvim | **34 个插件**，版本锁定于 `lazy-lock.json` |
| 语法高亮 | nvim-treesitter（**main 分支**） | **20 个语言**解析器，含 Java / PowerShell / C# |
| 代码补全 | nvim-cmp + LuaSnip | LSP、代码片段、文件路径、缓冲区多源补全 |
| 语言服务器 | mason + nvim-lspconfig | **7 个 LSP**：Lua、TypeScript、CSS、Vue、HTML、C/C++、Java |
| 文件查找 | Telescope | 标题已汉化，覆盖 51 个 picker（含 `<C-/>` 键位表） |
| 文件树 / 大纲 | nvim-tree / aerial | 快捷键 `<空格>e` / `<空格>a`，键位提示已汉化 |
| 状态栏 | lualine | 中文化标记 |
| Git | gitsigns | 左侧改动标记，操作提示已汉化 |
| Markdown | render-markdown | 打开即渲染（标题放大、表格画框）|
| 内置终端 | toggleterm | `Alt+p` 浮动终端 |
| **界面汉化** | 自研 i18n 引擎 | **115 组 / 924 条**规则 + 266 条消息正则 |
| **checkhealth 汉化** | 补丁 + 模块覆盖 | 插件 63 条 + 本体 208 条（不改 nvim 安装目录） |
| **键位菜单汉化** | 补丁 + 映射 | `<空格>` / `g` / `z` / `<C-w>` / 操作符 / 文本对象全中文 |

### 为什么选这套，而不是从零配置

从零搭建 Neovim 时最耗时的往往不是"装插件"，而是踩这些坑 —— 本配置已经处理完并记录在案：

| 坑 | 表现 | 本配置的处理 |
|----|------|--------------|
| treesitter 分支选错 | 打开 Markdown 报 `range (a nil value)` | 固定使用 **main 分支**（适配 0.12）|
| 缺 tree-sitter CLI | 解析器编译报 `ENOENT: 'tree-sitter'` | 文档说明 + 安装脚本自动处理 |
| `cc` 命令缺失 | Windows 上解析器编译失败 | 安装脚本自动创建 `cc.exe` 别名 |
| LSP 配置变量未定义 | 补全能力为 `nil`，LSP 形同虚设 | 已修复上游 7 处 bug |
| npm 11 拦截安装脚本 | tree-sitter CLI 装了但不可用 | 文档强调 `--allow-scripts` 参数 |
| 全量更新打断配置 | `:Lazy update` 后 `lsp.lua` 报错 | 关闭自动检查 + 提供 `:Lazy restore` 回退 |
| 插件界面全英文 | 看不懂菜单 | 自研 i18n 引擎汉化（**115 组 / 924 条**规则），含语法校验与失败回滚 |

---

## 环境要求

### 必需

| 组件 | 版本 | 用途 |
|------|------|------|
| **Neovim** | **0.12.0+** | 配置使用了 0.12 的 API（treesitter main 分支要求）|
| git | 任意 | 下载插件 |
| gcc | 任意 | 编译 treesitter 解析器 |
| **tree-sitter CLI** | 0.27+ | **驱动解析器编译流程**（与 gcc 缺一不可）|
| ripgrep | 任意 | Telescope 全文搜索 |
| fd | 任意 | Telescope 文件查找 |
| Node.js | 18+ | vtsls / css-lsp 等 LSP 所需 |
| Nerd Font | 任意 | 图标显示（推荐 JetBrainsMono NF）|

### 可选

| 组件 | 用途 | 缺失影响 |
|------|------|----------|
| Java 21+ | jdtls（Java LSP）| Java 智能提示不可用 |
| win32yank | Windows 剪贴板互通 | 复制粘贴报错 |
| lazygit | Git 终端界面 | 无影响 |
| PowerShell 7 | toggleterm 的 shell | `Alt+p` 终端打不开 |

> **gcc 与 tree-sitter CLI 的分工**：gcc 负责把 C 源码编译成 `.so`，tree-sitter CLI 负责驱动整个编译流程（生成 `parser.c` 并调用 gcc）。**只装 gcc 会报 `ENOENT: 'tree-sitter'`。**

---

## 快速开始

### Windows

```powershell
# 1. 安装 Neovim 与依赖（以 scoop 为例）
scoop install neovim gcc ripgrep fd lazygit win32yank

# 2. 安装 tree-sitter CLI
#    注意：npm 11 起默认拦截安装脚本，必须加 --allow-scripts，否则二进制不会下载
npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli

# 3. 克隆本仓库到配置目录（先备份已有配置）
Move-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.bak" -ErrorAction SilentlyContinue
git clone https://github.com/WAerWAK/My-Nvim-Config.git "$env:LOCALAPPDATA\nvim"

# 4. 运行安装脚本（自动检查依赖、创建 cc 别名、处理备份）
powershell -ExecutionPolicy Bypass -File "$env:LOCALAPPDATA\nvim\install.ps1"

# 5. 首次启动，等待插件自动下载（约 1-3 分钟）
nvim
```

启动后执行一次 `:TSUpdate` 编译语法解析器（**首次必须**）。

### Linux / macOS

```bash
# 1. 依赖（Debian/Ubuntu 示例，macOS 用 brew install）
sudo apt install neovim gcc ripgrep fd-find nodejs npm
npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli

# 2. 克隆配置
git clone https://github.com/WAerWAK/My-Nvim-Config.git ~/.config/nvim

# 3. 运行安装脚本
bash ~/.config/nvim/install.sh

# 4. 首次启动
nvim
```

> Linux 下 `clipboard` 依赖 `xclip`（X11）或 `wl-clipboard`（Wayland）；`fd` 在部分发行版中命令名为 `fdfind`，需自行建立软链接。

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
├── lazy-lock.json              # 插件版本锁定（35 条，勿随意改写）
├── install.ps1 / install.sh     # 一键安装脚本（Windows / Unix）
├── lua/
│   ├── core/                   # 基础配置
│   │   ├── options.lua         # 编辑器选项（行号、缩进、剪贴板、主题、helplang）
│   │   ├── keymaps.lua         # 自定义快捷键（含中文说明）
│   │   ├── builtin-keys.lua    # 为 Neovim 内置键位补中文说明
│   │   ├── chinese.lua         # 汉化入口：消息翻译 + notify/echo 钩子 + 启动时 patch
│   │   └── i18n/               # 汉化引擎（详见「界面汉化」一节）
│   │       ├── init.lua        #   执行引擎（替换 + 语法校验 + 审计）
│   │       ├── words.lua       #   统一词汇表
│   │       ├── messages.lua    #   系统消息正则（266 条）
│   │       ├── health.lua      #   checkhealth 本体模块覆盖部署
│   │       ├── helpdoc.lua     #   中文帮助索引生成
│   │       └── patches/        #   按插件分组的界面文本规则（18 个文件）
│   └── plugins/                # 各插件独立配置（20 个文件）
│       ├── plugins-setup.lua   # lazy.nvim 初始化与插件清单（最常改）
│       ├── lsp.lua             # 语言服务器
│       ├── cmp.lua             # 补全
│       ├── treesitter.lua      # 语法高亮
│       ├── telescope.lua       # 文件查找（51 个 picker 标题汉化）
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
│       ├── noice.lua           # 命令行美化（消息路由 / 视图配置）
│       └── smear-cursor.lua    # 光标动画（插件已禁用，文件保留以便恢复）
├── doc/
│   ├── nvim-cn.txt             # 中文帮助页（:help nvim-cn）
│   └── noice-diag.txt          # noice 消息显示排查步骤（:help i18n-noice-diag）
├── scripts/
│   ├── windiag.lua             # 窗口诊断脚本（排查幽灵窗口用）
│   ├── health-core/            # checkhealth 本体中文模块（启动时部署到配置目录）
│   └── i18n-*.lua              # 汉化维护工具（审计 / 消息自检 / 命令与映射清单）
└── docs/
    ├── 界面预览.png             # 界面截图
    └── HUAHUANVIM-移植说明.md   # 本配置的来源与移植过程
```

---

## 配置详解

### 编辑器选项（`lua/core/options.lua`）

```lua
local opt = vim.opt

-- 行号
opt.relativenumber = true    -- 相对行号（配合计数跳转，如 5j 下移 5 行）
opt.number = true            -- 显示当前行号

-- 缩进
opt.tabstop = 4              -- Tab 显示宽度
opt.shiftwidth = 4           -- 自动缩进宽度
opt.expandtab = false        -- false = 使用真实制表符
opt.autoindent = true        -- 继承上一行缩进

opt.wrap = false             -- 不自动折行
opt.cursorline = false       -- 不整行高亮光标行
opt.mouse:append("a")        -- 启用鼠标
opt.clipboard:append("unnamedplus")  -- 与系统剪贴板互通（Windows 需 win32yank）

opt.splitright = true        -- 新窗口开在右侧
opt.splitbelow = true        -- 新窗口开在下方

opt.ignorecase = true        -- 搜索忽略大小写
opt.smartcase = true         -- 但含大写字母时区分大小写

opt.termguicolors = true     -- 真彩色
opt.signcolumn = "yes"       -- 常驻符号列（避免文本抖动）

vim.cmd[[colorscheme tokyonight-moon]]  -- 主题
```

**可选主题**：`tokyonight`、`tokyonight-moon`、`tokyonight-night`、`tokyonight-storm`、`tokyonight-day`

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

延迟加载字段（影响启动速度）：

| 字段 | 含义 |
|------|------|
| `event = "VeryLazy"` | 启动完成后加载 |
| `event = "BufReadPre"` | 打开文件前加载 |
| `ft = { "markdown" }` | 仅在指定文件类型加载 |
| `cmd = "SomeCommand"` | 仅在使用该命令时加载 |

> 本配置**关闭了自动更新检查**（`checker = { enabled = false }`），避免误触发全量更新，原因见[日常维护](#更新插件重要)。

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

**新增语言支持**（以 Python 为例）：

```vim
" 1. 安装语言服务器
:MasonInstall pyright
```

```lua
-- 2. 在 lua/plugins/lsp.lua 中追加配置
--    capabilities 变量已在该文件开头定义，直接引用
require'lspconfig'.pyright.setup{
    capabilities = capabilities,
}
```

```vim
" 3. 安装对应语法解析器
:TSInstall python
```

### 语法解析器（`lua/plugins/treesitter.lua`）

共 **20 个**：

```
bash  c  c_sharp  cpp  css  java  javascript  json  lua  markdown
markdown_inline  powershell  python  rust  toml  tsx  typescript
vim  vimdoc  yaml
```

增删语言时修改文件中的 `parsers` 列表，缺失的会在启动时自动补装（异步，装完重启生效）。

> **重要**：本配置使用 nvim-treesitter 的 **main 分支**（要求 Neovim 0.12+）。升级该插件后**必须执行 `:TSUpdate`** 重新编译全部解析器，否则新旧 ABI 不匹配。

### 界面汉化（`lua/core/i18n/`）

Neovim 本身不含中文语言包（官方 Windows 构建连 `libintl` 都没链接，放 `.mo` 也不生效），
插件界面文本也全部硬编码在源码里。本配置通过一套自研机制解决，共 **115 组规则 / 924 条替换**，
外加 **266 条系统消息正则**。

#### 模块结构

```
lua/core/i18n/
├── init.lua               执行引擎：识字规则、替换、语法校验、审计
├── words.lua              统一词汇表（改词只改这里）
├── messages.lua           系统消息正则翻译（266 条）
├── health.lua             checkhealth 本体模块的覆盖部署
├── helpdoc.lua            中文帮助索引（doc/tags-cn）生成
└── patches/               按插件分组的界面文本规则
    ├── init.lua           汇总表（含"引号变体"自动展开）
    ├── compat.lua         ⚠️ 非汉化：第三方兼容性修复（务必保留）
    ├── lazy.lua  mason.lua  telescope*.lua  nvim-tree*.lua
    ├── which-key.lua  aerial*.lua  gitsigns*.lua  noice*.lua
    ├── health.lua  health-extra.lua  health-extra2.lua
    └── small*.lua  lsp-cmds.lua  treesitter.lua  final.lua  misc.lua
```

#### 三条技术路径（按安全性排序）

| 方式 | 适用场景 | 例子 |
|------|----------|------|
| ① **配置覆盖** | 插件把文本做成可配置项时首选 | Telescope 的 `pickers.*.prompt_title`、nvim-tree 的 `mappings` |
| ② **补 desc** | 键位说明类（原映射非回调型时安全） | `core/builtin-keys.lua`、`core/keymaps.lua` |
| ③ **改写源码** | 插件硬编码文本时唯一可行（本配置主力） | Lazy / Mason / nvim-tree / which-key 的界面文案 |

#### 引擎的安全设计（都是踩坑后加的）

| 机制 | 作用 |
|------|------|
| **语法校验 + 自动放弃** | 替换后先用 `load()` 校验 Lua 语法，不通过就整份放弃改写并记日志 —— 杜绝"汉化把插件改坏导致 nvim 崩" |
| **幂等** | 源码里找不到原文就跳过，反复启动不会重复替换 |
| **二进制读写** | 不改动文件行尾（CRLF 保持 CRLF） |
| **长度降序执行** | 避免 `opts("Open")` 抢在 `opts("Open Preview")` 前导致失配 |
| **引号变体自动展开** | 规则写 `'foo'`，引擎自动补 `"foo"` 版本，不用手动对齐引号风格 |
| **失败日志** | 改写记录写入 `stdpath("state")/i18n.log` |

#### 新增一条汉化

```lua
-- lua/core/i18n/patches/<插件>.lua
return {
  rules = {
    {
      path = "插件名/lua/路径/文件.lua",
      note = "用途说明",
      replacements = {
        { [[英文原文]], [[中文译文]] },
      },
    },
  },
}
```

> ⚠️ 只替换**显示用**文本（`desc` / `title` / `prompt` / 消息串）。
> 键名、命令名、正则、参与逻辑判断的常量一律不动。
> **判断方法**：这个字符串会不会被回传给插件做判断？会 → 不能动。
>
> ⚠️ 规则必须带**引号边界**（`'文本'` 而非裸文本）。
> 我们踩过这个坑：早期用裸文本替换，把 `state.validate()` 里的 `valid` 也换成中文，
> 直接把 render-markdown 的 health.lua 改成了非法 Lua。

#### 自查命令

| 命令 | 作用 |
|------|------|
| `:I18nPatch` | 立即执行汉化（正常显示"改写 0 个文件"） |
| `:I18nRules` | 列出全部规则与目标文件（`!!` 表示目标不存在） |
| `:I18nAudit` | 扫描插件里剩余的英文界面文本 |
| `:I18nHelpTags` | 重建中文帮助索引 |
| `:help nvim-cn` | 中文帮助页（入门 / 键位 / 汉化说明） |
| `:help i18n-noice-diag` | noice 消息显示问题的排查步骤 |

配套脚本（`scripts/`）：`i18n-audit.lua`、`i18n-test-messages.lua`、
`i18n-cmd-desc.lua`、`i18n-export-maps.lua`、`i18n-msg-list.lua`。

#### 汉化覆盖面

| 范围 | 内容 |
|------|------|
| 界面规则 | **115 组 / 924 条**，覆盖 lazy、Mason、Telescope、nvim-tree、which-key、aerial、gitsigns、noice、notify、toggleterm、render-markdown、treesitter、LuaSnip、nvim-autopairs 等 |
| 系统消息 | **266 条**正则（含官方 `errors.h` 全部 191 条消息） |
| 键位菜单 | `<空格>` / `g` / `z` / `<C-w>` / 操作符 / 文本对象全中文；Telescope 内按 `<C-/>` 的键位表也中文 |
| checkhealth | 插件 63 条 + 本体 208 条（本体用"配置目录同名模块覆盖"实现，**不改 nvim 安装目录**） |
| 中文帮助 | `doc/nvim-cn.txt`（入门 / 键位速查 / 汉化说明）+ `'helplang' = cn,en` |
| 中文教程 | 直接 `:Tutor zh/vim-01-beginner`（nvim 官方自带） |

#### 有意保留英文的部分

| 项目 | 原因 |
|------|------|
| nvim 本体错误消息**整体**切换 | 消息写死在编译期；官方 Windows 构建未链接 `libintl`（实测 `nvim.exe` 里 `libintl`/`bindtextdomain`/`nvim.mo` 出现次数均为 0），放 `.mo` 无效。只能靠 266 条正则逐条翻 |
| 含 `%s`/`%d` 的动态串 | 改了要同步改参数，风险高 |
| 技术标识 | `libuv-watch`、`inotify`、health 分组名、命令名 / 选项名 |
| `<Plug>` 映射说明 | LuaSnip / Comment 的注释型映射，which-key 默认不显示 |
| LSP 服务器自身消息 | 不属于 Neovim |

> **两处已知取舍**（都在源码注释里写明了原因）：
> 1. Comment.nvim 的 `gc`/`gcc` 等是**回调型映射**（`rhs` 为 nil），不能用 `vim.keymap.set`
>    重设 desc（会让注释功能失效），所以改为直接汉化插件源码里的 desc 字符串。
> 2. noice 的路由过滤器 `find` 匹配的是**原始英文**（翻译发生在之后的渲染阶段），
>    写中文永远匹配不上 —— 配置里统一用英文原文匹配。


---

## 键位速查

leader 键为**空格**。按下空格停约 0.3 秒会弹出 which-key 菜单（中文）。

> 提示：在 nvim 中执行 `:map` 可查看全部映射；按 `<空格>` 或 `g`、`<C-w>` 会直接弹出分类菜单。

### 基础编辑

| 键位 | 模式 | 功能 |
|------|------|------|
| `jk` | 插入 | 退出插入模式 |
| `:w` / `:wq` / `:q!` | 普通 | 保存 / 保存退出 / 强制退出 |
| `J` / `K` | 可视 | 选中内容下移 / 上移（保持选中）|
| `gc` / `gcc` | 可视 / 普通 | 注释选中行 / 注释当前行 |
| `gb` / `gbc` | 可视 / 普通 | 块注释 / 注释当前块 |

### 窗口与分屏

| 键位 | 功能 |
|------|------|
| `<空格>sv` / `<空格>sh` | 垂直 / 水平分屏 |
| `<空格>sc` | 关闭当前窗口 |
| `Ctrl+h/j/k/l` | 跳到左 / 下 / 上 / 右窗口（由 vim-tmux-navigator 提供）|
| `<C-w>h/j/k/l` | 同上（Neovim 原生方式）|
| `<C-w>w` / `<C-w>W` | 在窗口间循环切换 / 反向循环 |
| `<C-w>s` / `<C-w>v` | 水平 / 垂直分屏 |
| `<C-w>c` / `<C-w>o` | 关闭当前窗口 / 只保留当前窗口 |
| `<C-w>q` | 退出当前窗口 |
| `<C-w>=` | 所有窗口等宽等高 |
| `<C-w>+` / `<C-w>-` | 增加 / 减少高度 |
| `<C-w>>` / `<C-w><` | 增加 / 减少宽度 |
| `<C-w>x` | 与相邻窗口互换位置 |
| `<C-w>T` | 把当前窗口移到新标签页 |
| `Shift+L` / `Shift+H` | 下一个 / 上一个缓冲区 |
| `<空格>x` | 关闭当前缓冲区 |

> `Ctrl+h/j/k/l` 由 `vim-tmux-navigator` 注册。**没有 tmux 时行为与 `<C-w>h/j/k/l` 相同**；若在 tmux 内运行，它会自动把边界处的按键透传给 tmux 用于切换面板。

### 查找与浏览

| 键位 | 功能 |
|------|------|
| `<空格>ff` | 查找文件（Telescope）|
| `<空格>fr` | 最近打开的文件 |
| `<空格>fg` | 全局搜索内容（需 ripgrep）|
| `<空格>fb` | 切换缓冲区列表 |
| `<空格>fh` | 搜索帮助文档 |
| `<空格>e` | 开关文件树（nvim-tree）|
| `<空格>a` | 开关代码大纲（aerial）|
| `<空格>nh` | 取消搜索高亮 |

### 代码导航（LSP）

> 下表键位**均为 Neovim 内置**，无需本配置注册，但需当前文件已连接 LSP 才有效。

| 键位 | 功能 |
|------|------|
| `gd` | 跳转到定义 |
| `grn` | 重命名符号 |
| `gra` | 代码操作（快速修复）|
| `grr` | 列出所有引用 |
| `gri` | 跳转到实现 |
| `grt` | 跳转到类型定义 |
| `grx` | 运行代码镜头（Code Lens）|
| `gO` | 列出当前文件符号 |
| `]d` / `[d` | 跳到下 / 上一个诊断 |
| `]D` / `[D` | 跳到最后一个 / 第一个诊断 |
| `]q` / `[q` | 下 / 上一个 quickfix |
| `]b` / `[b` | 下 / 上一个缓冲区 |
| `]t` / `[t` | 下 / 上一个标签页 |

### 其他

| 键位 | 功能 |
|------|------|
| `gg` / `ge` / `gf` | 跳到文件开头 / 上一个词尾 / 打开光标下的文件 |
| `gx` | 用系统程序打开光标下的文件或链接 |
| `<空格>ll` / `<空格>lm` | 打开插件管理（lazy）/ LSP 工具管理（mason）|
| `<空格>d` | 回到启动页 |
| `Alt+p` | 开关浮动终端（toggleterm）|
| `<空格>mt` | 开关 Markdown 渲染（默认开启）|

---

## 日常维护

### 更新插件（重要）

本配置**刻意关闭了自动更新检查**，原因是全量更新会把 `nvim-lspconfig` 等升级到新版 API，导致 `lsp.lua` 的既有写法失效。

**推荐做法**：只按需更新单个插件。

```vim
:Lazy                    " 打开界面，光标移到目标插件后按 U 升级它
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
| **配置** | `%LOCALAPPDATA%\nvim`（Windows）/ `~/.config/nvim`（Unix）| ✅ **核心，本仓库即是** |
| 插件本体 | `nvim-data\lazy\` | ❌ 可自动重新下载 |
| LSP 服务器 | `nvim-data\mason\` | ❌ 可自动重新安装 |
| 历史记录 | `nvim-data\shada\` | ❌ 无必要 |

**迁移到新机器**：按[快速开始](#快速开始)执行即可，插件会依据 `lazy-lock.json` 自动还原到**完全相同的版本**。

### 卸载

```powershell
# 1. 卸载程序
scoop uninstall neovim

# 2. 删除配置与数据
#    %LOCALAPPDATA%\nvim        （配置，即本仓库）
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

**原因**：`smear-cursor`（光标拖尾动画）失控，每帧创建一个辅助窗口却未回收，实测堆积 23~35 个 `ft=smear-cursor`、高度 1 行的幽灵窗口。

**本配置的处理**：升级到上游最新版仍无效，故**已禁用该插件**（`plugins-setup.lua` 中该行已注释）。

**如需恢复**：取消该行注释，并恢复 `lua/plugins/smear-cursor.lua` 的 setup 调用。它只提供视觉效果，禁用无功能损失。

### Q2：打开 Markdown 报 `attempt to call method 'range' (a nil value)`？

nvim-treesitter 分支选错。**必须用 `main` 分支**（要求 Neovim 0.12+），`master` 分支只兼容 0.11。

```powershell
git -C $env:LOCALAPPDATA\nvim-data\lazy\nvim-treesitter rev-parse --abbrev-ref HEAD
# 应输出 main
```

切换分支后**必须执行 `:TSUpdate`** 重新编译全部解析器。

### Q3：解析器编译失败，报 `ENOENT: 'tree-sitter'`？

缺 tree-sitter CLI：

```powershell
npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
```

`--allow-scripts` **不能省** —— npm 11 起默认拦截依赖的安装脚本，不加则二进制不会下载，装完命令仍不可用。

### Q4：复制粘贴报错？

`options.lua` 启用了 `clipboard=unnamedplus`，Windows 上依赖 win32yank：

```powershell
scoop install win32yank
```

Linux 下需安装 `xclip`（X11）或 `wl-clipboard`（Wayland）。

### Q5：不小心执行了全量更新，配置报错？

```vim
:Lazy restore
```

按 `lazy-lock.json` 恢复所有插件版本。**前提是该文件没被一并破坏**，所以建议定期备份它。

### Q6：文件树/状态栏图标显示成方块？

终端字体不是 Nerd Font。改为 `JetBrainsMono NF` 或其它 Nerd Font 即可。

### Q7：Java 的 LSP 起不来？

jdtls 需要 **Java 21+**：

```powershell
java -version
```

### Q8：插件界面又变回英文了？

说明该插件更新后源码文本有变动，导致汉化规则失配。排查顺序：

1. 先跑 `:I18nRules` —— 输出里带 `!!` 的是目标文件不存在（插件被卸载或路径变了）
2. 再跑 `:I18nPatch` —— 会打印本轮改写与失败项
3. 看日志 `stdpath("state")/i18n.log`（Windows：`%LOCALAPPDATA%\nvim-data\i18n.log`）
4. 定位到新文本后，改 `lua/core/i18n/patches/<插件>.lua` 里对应的规则

> 启动时若有失败项会弹通知提示具体文件。规则写法与注意事项见「界面汉化」一节。

### Q9：`:checkhealth` 里的中文是怎么实现的？

两套路径：

- **插件**（nvim-lspconfig / nvim-treesitter / render-markdown / LuaSnip 等）：直接用汉化规则替换源码文案
- **nvim 本体**（`vim.health` / `vim.lsp` / `vim.provider` / `vim.pack`）：**不改 nvim 安装目录**，
  而是在配置目录放同名模块覆盖（rtp 优先级更高）。源文件在 `scripts/health-core/`，启动时自动部署

> 注：health 报告里的**分组名**（如 `vim.lsp`）和含 `%s` 的格式化串保留英文
> —— 前者是命令参数，后者改了要同步改参数，风险高。

### Q10：`gc`/`gcc`/`gb` 的说明怎么变成中文的？

做法是**直接汉化 Comment.nvim 源码里的 `desc` 字符串**（由 patch 机制自动完成）。

**注意**：不要试图在 `keymaps.lua` 里重设这些键位 —— 它们是 Lua 回调型映射（`rhs` 为 `nil`），重设会导致注释功能失效。

### Q11：`:w` 保存后没有提示？

这是**有意为之**：`plugins/noice.lua` 里把 `written` / `yanked` 消息路由为 `skip = true`（静默）。

想看到提示就把对应路由改成视图，例如：

```lua
{ filter = { event = "msg_show", kind = "", find = "written" }, view = "mini" }
```

> ⚠️ 两个已踩过的坑（都写在 `noice.lua` 注释里）：
> 1. 路由的 `find` 匹配的是**原始英文**消息，写中文（如 `find = "已保存"`）永远匹配不上
> 2. **不要用 `view = "cmdline"`** —— 它会被命令结束后的清屏覆盖，看起来像"没生效"

### Q12：修改配置后没生效？

```vim
:source $MYVIMRC       " 重载配置（部分插件需重启才生效）
:Lazy reload 插件名     " 重载指定插件
```

最稳妥的方式是重启 nvim。

### Q13：启动变慢了怎么排查？

```vim
:Lazy profile          " 查看各插件加载耗时
:checkhealth           " 检查异常
```

启动耗时也会显示在启动页上，正常约 300 ms 以内。本配置已关闭联网检查更新，这也是启动速度的保证之一。

### Q14：关掉一个文件时 nvim 一起退出了，怎么只关文件？

`:q` 关闭的是**窗口**，而只剩一个窗口时 nvim 就会随之退出。想"关闭文件但留在 nvim 里"应该操作**缓冲区**：

| 命令 / 键位 | 效果 |
|-------------|------|
| `:bd` | **关闭当前文件，nvim 不退出**（推荐）|
| `<空格>x` | 同上（本配置已绑定）|
| `:bnext` / `:bprev` | 切到下一个 / 上一个文件 |
| `Shift+L` / `Shift+H` | 同上（本配置已绑定）|
| `:e 文件名` | 在当前窗口打开另一个文件 |
| `:q` | 关闭当前**窗口**，最后一个窗口时退出 nvim |
| `:qa` | 退出所有窗口（即退出 nvim）|
| `:qa!` | 强制退出 nvim，不保存 |

**已经用 `:q` 退出了怎么办？** 没有损失 —— 文件仍在磁盘上（前提是保存过）。重开 nvim 后用 `<空格>fr`（最近打开的文件）就能快速找回。

> **容易混淆的一点**：Vim/Neovim 中"窗口 / 缓冲区 / 标签页"是三个不同概念 ——
> **缓冲区**是打开的文件，**窗口**是它的显示区域，**标签页**是一组窗口的集合。
> 编辑多个文件推荐用**缓冲区**（`:bd` 关闭、`Shift+L/H` 切换），而不是开一堆窗口。

### Q15：关闭文件后想回到启动页（MYNVIM 主界面）？

启动页只在 **nvim 启动时**自动出现一次。关掉文件后它不会自动回来，手动唤出即可：

| 方式 | 操作 |
|------|------|
| **`<空格>d`** | 回到启动页（本配置已绑定）|
| `:Dashboard` | 同上（命令方式）|

> 启动页上的「最近打开的文件」可以让你快速回到刚才关掉的文件 —— 这也是它比空白缓冲区更实用的地方。
>
> 反过来，在启动页上按 `q` 即可关闭它，回到普通编辑状态。

---

## 更新日志

### 2026-10-06

**汉化全面升级：从"部分汉化"到"完整汉化"**

- **引擎重构**：`core/chinese.lua`（358 行单文件）→ `core/i18n/` 模块化
  - 新增**替换后语法校验**：改写前先 `load()` 验证，不通过就自动放弃（杜绝把插件改坏）
  - 新增**引号变体自动展开**：规则写 `'foo'` 自动补 `"foo"` 版本
  - 规则按原文长度降序执行，避免前缀规则抢先命中
  - 改为二进制读写，不再改动文件行尾
- **规则规模**：13 组 → **115 组 / 924 条**；消息正则 14 条 → **266 条**
- **补齐遗漏**：Mason 帮助页 6 个文件、启动页主题原为手工改源码未纳入规则（插件更新即失效），现已全部纳入
- **键位菜单**：which-key 内置说明 156 条、nvim-tree 键位提示 59 条、Telescope `<C-/>` 键位表、
  `<C-w>`/`g`/`z`/操作符/文本对象全部汉化；隐藏了 `<C-w>d`/`<C-w><C-d>`（功能为浮窗显示诊断，用户不用）
- **checkhealth 汉化**：插件 63 条 + 本体 208 条（本体用"配置目录同名模块覆盖"，**不改 nvim 安装目录**）
- **中文帮助**：新增 `doc/nvim-cn.txt` 与 `'helplang' = cn,en`，自动生成 `doc/tags-cn`
- **新增命令**：`:I18nPatch` / `:I18nRules` / `:I18nAudit` / `:I18nHelpTags`
- **新增维护工具**：`scripts/i18n-*.lua`（审计、消息自检、命令与映射清单）、`scripts/health-core/`
- **修复两个真实缺陷**：
  1. `mason/package_list.lua` 里数据字段 `"languages"` 被误译成 `"语言"`，导致按语言搜索失效
  2. telescope 的 `ft_to_lang` 兼容补丁在重构时丢失，导致预览 Markdown 报 `attempt to call field 'ft_to_lang'`
     （现统一放在 `patches/compat.lua`）
- **noice 配置修正**：路由 `find` 必须用英文原文匹配（翻译发生在渲染阶段）；`view = "cmdline"` 会被清屏覆盖；
  渲染层翻译需用 nui 的 `Text:set()` 同步长度，否则报 `Invalid 'end_col'`

### 2026-10-04

**初始版本**

- 从 [HUAHUANVIM](https://github.com/huahuaid/HUAHUANVIM) 的 One~Six 六分支合并移植（详见 `docs/`）
- 修复上游 7 处 bug：`capabilities` 未定义、`css_ls` 名称错误、`clangd` 硬编码路径、dashboard 依赖缺失、`rainbow-delimiters` 与 nvim 0.12 不兼容等
- Windows 与 Neovim 0.12 适配：gcc 编译器、`cc` 别名、`win32yank` 剪贴板、`vim.uv` API
- nvim-treesitter 升级到 **main 分支**（适配 Neovim 0.12），配置 20 个解析器
- 界面汉化：启动页、`:Lazy`、`:Mason`（含帮助页）、Telescope、nvim-tree、Comment 键位
- 内置键位汉化：`<C-w>` 窗口系列 18 个 + `g` 系列 3 个
- 精简 mason 包：48 个（2.1 GB）→ 9 个（416 MB）
- 禁用 `smear-cursor`（窗口泄漏问题）

### 2026-10-04（文档与键位增补）

- 新增 `<空格>d` 快捷键：回到启动页（`:Dashboard`）
- README 补充「退出与返回」相关说明：Q12（`:bd` 关闭文件而保留 nvim）、Q13（回到启动页）
- README 徽章去掉锚点跳转；新增「适合谁 / 为什么选这套」章节与界面预览图
- 逐项核对配置详解与键位速查，修正 8 处描述偏差

---

## 致谢

- 配置基础来自 [huahuaid/HUAHUANVIM](https://github.com/huahuaid/HUAHUANVIM)
- 各插件作者与 [lazy.nvim](https://github.com/folke/lazy.nvim) 生态

## 许可

MIT License，详见 [LICENSE](LICENSE)。