# HUAHUANVIM 六分支合并移植说明

**移植日期**：2026-10-04
**来源仓库**：<https://github.com/huahuaid/HUAHUANVIM>
**来源分支**：One / Two / Three / Four / Five / Six（六分支合并为一份配置）
**落点**：`C:\Users\tgx59\AppData\Local\nvim`
**插件数据**：`C:\Users\tgx59\AppData\Local\nvim-data`

---

## 一、合并策略

该仓库的六个分支是**递进式教学系列**，逐分支累加功能。经逐文件 hash 比对确认：

| 关系 | 结论 |
|---|---|
| `init.lua` | 逐分支累加 require（One 4 行 → Six 20 行） |
| `lua/core/options.lua` | 六分支**完全一致** |
| `lua/core/keymap(s).lua` | One→Two→Three→Six 逐分支累加键位；Four 与 Five 起改名为 `keymaps.lua` |
| `lua/plugins/*.lua` | 各分支新增文件，同名文件在后续分支中只做增强（无功能回退） |
| `plugins-setup.lua` | 插件清单逐分支累加 |

**因此 Six 分支 = One~Five 的功能超集**，合并结果直接以 Six 为基线，并将各分支被误删/回退的项恢复。合并后共 **34 个插件、21 个配置文件**。

---

## 二、基线修正（恢复上游误删项）

| 项目 | 原状 | 合并后 | 依据 |
|---|---|---|---|
| treesitter `tsx` 解析器 | Five 分支把它从 `ensure_installed` 中删掉 | 已恢复 | Five→Six 的误删，tsx 与 typescript 配套 |
| `lua_ls` LSP | Three 启用 → Five/Six 被注释掉 | 已恢复 | 写 Neovim 配置必备，且是教程本身的语言 |
| 彩虹括号 | Two 用 `p00f/nvim-ts-rainbow`，Three 换成 `rainbow-delimiters.nvim` | 保留新版 | 已废弃插件，后者是维护中的继承者 |
| `keymap.lua` / `keymaps.lua` | 分支间改名 | 采用 `keymaps.lua`（Six 版） | 后者是超集（多 Aerial 键位） |

---

## 三、上游 Bug 修复

### 1. `capabilities` 变量未定义（严重）

原仓库 `lua/plugins/lsp.lua` 从 Three 分支起写了 5 处 `capabilities = capabilities`，但**从未定义该变量**，LSP 拿到的补全能力实际是 `nil`。

修复：在文件开头按标准方式构造能力表。

```lua
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
```

### 2. `css_ls` 不是合法服务器名

原仓库写作 `require'lspconfig'.css_ls.setup{}`，正确名称是 `cssls`（`css_ls` 属于已废弃的别名）。已修正。

### 3. `clangd` 硬编码了不存在的命令

原仓库写死 `cmd = { "clangd-18" }`，本机无此命令，会导致 C/C++ 的 LSP 永远起不来。已移除该行改为自动探测。

### 4. `dashboard.lua` 依赖未安装的 Telescope

原仓库启动页的 `f`（Files）、`a`（Apps）快捷键与项目列表都调用 `Telescope`，但插件清单里**根本没有 telescope**，按下即报错。已在插件清单补装：

```lua
{ "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
```

### 5. `rainbow-delimiters.nvim` 与 Neovim 0.12 不兼容（严重）

作者锁定的提交里 `lib.lua:200` 直接调用 `parser:register_cbs`，而在 Neovim 0.12 上遇到无解析器的 buffer 时 `parser` 为 `nil`，实际渲染时抛异常并弹出错误框。

上游已在 2026-09 修复（新增 `pcall` + nil 检查）。本机已把该插件升级到修复版，并**同步更新了 `lazy-lock.json`**：

```
旧 commit: 97bf4b8ef9298644a29fcd9dd41a0210cf08cac7
新 commit: 3a0fc08dd39e8bf034a4cfef3f2845bd5f565a2e
```

### 6. `run = ':TSUpdate'` 不是 lazy.nvim 的字段

`run` 在 lazy.nvim 中不生效，已改为 `build = ':TSUpdate'`，使解析器在插件安装/更新后自动同步。

### 7. `automatic_installation` 已弃用

`mason-lspconfig` 的该选项已废弃，已移除，改为只用 `ensure_installed`。

---

## 四、Windows 环境适配

| 项目 | 说明 |
|---|---|
| `vim.loop.fs_stat` → `(vim.uv or vim.loop).fs_stat` | `vim.loop` 在 0.10+ 已弃用 |
| gcc 编译器 | treesitter 编译解析器必需。已 `scoop install gcc`（15.2.0），并在 `treesitter.lua` 显式声明 `compilers = { "gcc" }` |
| `cc` 命令别名 | nvim-treesitter 查找的是 `cc`，而 scoop 的 gcc 只提供 `gcc.exe`。已在 `D:\Apps\Scoop\apps\gcc\current\bin\` 放置 `cc.exe` 副本（scoop 更新 gcc 后若丢失需重建） |
| `win32yank` | `options.lua` 设置了 `clipboard=unnamedplus`，Windows 上需要它才能与系统剪贴板互通。已 `scoop install win32yank` |
| toggleterm 的 shell | 配置指向 `C:\Program Files\PowerShell\7\pwsh.exe`，本机该路径**存在**，无需修改 |
| 剪贴板验证 | `nvim --version` 的 `+clipboard` 与 win32yank 均已确认可用 |

---

## 五、已安装内容清单

### 插件（34 个，按作者锁定版本安装）

主题 tokyonight；状态栏 lualine；文件树 nvim-tree + web-devicons；语法 nvim-treesitter + rainbow-delimiters；LSP mason + mason-lspconfig + nvim-lspconfig；补全 nvim-cmp + cmp-nvim-lsp + cmp-cmdline + cmp-path + cmp_luasnip + LuaSnip + friendly-snippets；编辑 Comment + nvim-autopairs + bufferline；终端 toggleterm；动效 smear-cursor；UI noice + nui + nvim-notify + dashboard；Markdown render-markdown + mini.nvim；缩进线 indent-blankline；大纲 aerial；Git gitsigns；窗口导航 vim-tmux-navigator；查找 telescope + plenary。

### LSP 服务器（mason 统一管理，8 个）

`lua-language-server`、`vtsls`、`css-lsp`、`vue-language-server`、`html-lsp`、`clangd`，外加格式化工具 `stylua`、`shfmt`。

### treesitter 解析器（16 个已编译）

`vim`、`vimdoc`、`bash`、`c`、`cpp`、`javascript`、`json`、`lua`、`python`、`typescript`、`tsx`、`css`、`rust`、`markdown`、`markdown_inline`

---

## 六、键位速查

leader 键为**空格**。

| 键位 | 功能 |
|---|---|
| `jk`（插入模式） | 退出插入模式 |
| `<leader>e` | 开关文件树 nvim-tree |
| `<leader>a` | 开关代码大纲 aerial |
| `<leader>nh` | 取消搜索高亮 |
| `<leader>sv` / `<leader>sh` | 水平 / 垂直分屏 |
| `<leader>x` | 关闭当前 buffer |
| `<S-L>` / `<S-H>` | 下一个 / 上一个 buffer |
| `<A-p>` | 开关浮动终端（toggleterm） |
| `gc` / `gcc` | 注释（可视模式 / 当前行） |
| `Ctrl-hjkl` | 窗口间跳转（vim-tmux-navigator） |
| `<Tab>` / `<S-Tab>` | 补全菜单上下选择 |
| `<CR>` | 确认补全 |
| `<C-e>` | 取消补全 |

---

## 七、验证结果

全部经 `nvim --headless` 实测，无任何报错：

```
插件总数/已加载      34 / 32（2 个按 filetype/event 懒加载）
colorscheme          tokyonight-moon
19 个关键模块        全部加载 OK
LSP 注册             lua_ls, vtsls, cssls, vuels, html, clangd 全部已注册
treesitter 解析器    16 个
mason 工具           8 个
键位                 全部注册
剪贴板               win32yank 可用
```

另经窗口模式实测：语法高亮、彩虹括号、状态栏、行号、图标全部正常渲染，无错误弹窗。

---

## 八、日常使用

```vim
:Lazy            " 插件管理（S 同步 / U 更新 / X 清理）
:Mason           " 管理 LSP 与格式化工具
:TSInstall xxx   " 额外安装某语言解析器
:checkhealth     " 排查环境问题
```

**注意事项**

1. **新开终端**才能让 `nvim` 找到 gcc（scoop 刚写入的 PATH 需要新终端生效）。
2. `lazy-lock.json` 已按作者锁定版本安装。若执行 `:Lazy update` 全量更新，`nvim-lspconfig` 会升到新版并**废弃 `require'lspconfig'.xxx.setup{}` 写法**，届时 `lsp.lua` 需要改写为新版 `vim.lsp.config()` 风格。建议只按需更新单个插件。
3. `nvim-treesitter` 当前使用 **master 分支**（作者锁定），该分支已被上游冻结，只做必要维护。若将来要迁到 main 分支，`treesitter.lua` 的配置写法需要整体重写。
4. 原 LazyVim 配置已移入**回收站**（可从回收站还原）；六个分支的原始配置备份在 `D:\Apps\nvim-configs\HUAHUANVIM-branches\`。

---

## 九、后续改动记录（2026-10-04 下午）

### 1. 移除误触更新的入口

起因：在启动页误按 `u` 触发了 `Lazy update`，24 个插件被升级并改写 `lazy-lock.json`（已全部回退）。

处理：

- `dashboard.lua` 删除 `{ desc = 'Update', action = 'Lazy update', key = 'u' }` 快捷键
- `plugins-setup.lua` 的 lazy 配置关闭自动检查与变更提示：

```lua
local opts = {
	checker = { enabled = false },
	change_detection = { enabled = false, notify = false },
}
```

**现在没有任何按键会触发全量更新**，更新插件需手动执行 `:Lazy`。

### 2. 修复启动页 `a` 键报错

原配置的 `a` 键绑定 `Telescope app`，但 telescope 并无 `app` 子命令，按下必报 `[telescope.run_command]: Unknown command`。

启动页快捷键现已改为（全部为存在的内置命令）：

| 键 | 功能 | 命令 |
|---|---|---|
| `f` | 查找文件 | `Telescope find_files` |
| `r` | 最近文件 | `Telescope oldfiles` |
| `g` | 全局搜索 | `Telescope live_grep` |

项目列表的 `action` 也修好了 `cwd` 传参（原写法在含空格的路径下会失败）。

### 3. 界面汉化

| 范围 | 状态 |
|---|---|
| 启动页全部文案 | ✅ 已汉化（含 hyper 主题内硬编码的 `Empty project` / `Most Recent Files`）|
| 状态栏未命名标记 | ✅ 显示 `[未命名]` |
| 键位提示 | ✅ 20 个键位带中文说明，按空格键由 which-key 弹出 |
| 常用消息 | ✅ 已保存 / 已复制 / 已复制 N 行 / 搜索已回到文件开头 等 |
| 新增文件 | `lua/core/chinese.lua`（词汇表 + 消息翻译 + notify 包装）|

**汉化的客观边界**（实测确认，不是配置问题）：

- Neovim 运行时目录**不含中文语言包**（`runtime/lang/` 下无 `zh_CN`），核心消息无法整体切换语言
- `Lazy` / `Mason` / `Telescope` / `nvim-tree` 等插件的界面文本**硬编码英文**，没有 i18n 接口，只能改插件源码（会在更新时丢失，不值得）
- 因此"深度汉化"的实际上限是：**你日常直接接触的界面（启动页、键位提示、状态栏、高频消息）全中文**；插件自身的管理界面保持英文

启动页的汉化补丁写在 `dashboard.lua` 末尾，每次启动会检查并重新应用，所以 `:Lazy restore` 或插件更新后不会丢失。

