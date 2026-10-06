-- =====================================================================
--  mason.nvim 界面汉化
-- =====================================================================
--  覆盖：主界面头部、语言过滤、包列表、帮助页（总览 + LSP/DAP/Linter/Formatter）
--  注：这些规则原本是**手工改源码**且未纳入 patch，插件一更新就会丢；
--      现全部纳入规则表，每次启动自动校验并补齐。
-- =====================================================================

return {
  rules = {
    {
      -- 主界面顶部：搜索模式提示、g? 帮助提示、软件源不可用提示
      path = "mason.nvim/lua/mason/ui/components/header.lua",
      note = "mason 头部提示（7 条）",
      replacements = {
        { [[" (search mode, press <Esc> to clear)"]], [["（搜索模式，按 <Esc> 清除）"]] },
        { [["        press "]], [["        按 "]] },
        { [[" for package list"]], [[" 查看包列表"]] },
        { [["press "]], [["按 "]] },
        { [[" for help"]], [[" 查看帮助"]] },
        { [["Packages from the following registries are unavailable. Press "]], [["以下软件源当前不可用。按 "]] },
        { [[" to install."]], [[" 可安装。"]] },
      },
    },
    {
      -- 语言过滤（/ 键弹出的过滤提示）
      path = "mason.nvim/lua/mason/ui/components/language-filter.lua",
      note = "mason 语言过滤提示（4 条）",
      replacements = {
        { [["Language Filter: "]], [["语言过滤: "]] },
        { [[" press <Esc> to clear"]], [[" 按 <Esc> 清除"]] },
        { [["Language Filter:"]], [["语言过滤:"]] },
        { [[" press %s to apply filter"]], [[" 按 %s 应用过滤"]] },
      },
    },
    {
      -- 包列表：字段标签与状态（已安装 / 可安装 / 安装中 …）
      -- ⚠️ 第 129 行的 "languages" 是 **数据字段名**（用于搜索关键字），不能译；
      --    规则里用带缩进的 p.muted 行做锚点，只改显示那一处。
      path = "mason.nvim/lua/mason/ui/components/main/package_list.lua",
      note = "mason 包列表字段与状态（17 条）",
      replacements = {
        { [["No packages."]], [["暂无包。"]] },
        { [["executables"]], [["可执行文件"]] },
        { [["installed version"]], [["已安装版本"]] },
        { [["version"]], [["版本"]] },
        { [["latest version"]], [["最新版本"]] },
        { [["installed purl"]], [["已安装 purl"]] },
        { [["homepage"]], [["主页"]] },
        { [[        p.muted "languages",]], [[        p.muted "语言",]] },
        { [["categories"]], [["分类"]] },
        { [["This is a read-only overview of the settings this server accepts. Note that some settings might not apply to neovim."]], [["此处只读展示该服务端支持的设置项，部分设置可能对 Neovim 不生效。"]] },
        { [["Installed"]], [["已安装"]] },
        { [["Press "]], [["按 "]] },
        { [[" to update "]], [[" 更新 "]] },
        { [["Installing"]], [["安装中"]] },
        { [["Queued"]], [["排队中"]] },
        { [["Failed"]], [["失败"]] },
        { [["Available"]], [["可安装"]] },
      },
    },
    {
      -- 帮助页总览：快捷键说明、软件源、常见问题、分类切换提示
      path = "mason.nvim/lua/mason/ui/components/help/init.lua",
      note = "mason 帮助页总览（27 条）",
      replacements = {
        { [["Toggle help"]], [["开关帮助"]] },
        { [["Toggle package info"]], [["开关包信息面板"]] },
        { [["Toggle package installation log"]], [["开关安装日志"]] },
        { [["Apply language filter"]], [["应用语言过滤"]] },
        { [["Install package"]], [["安装包"]] },
        { [["Uninstall package"]], [["卸载包"]] },
        { [["Update package"]], [["更新包"]] },
        { [["Update all outdated packages"]], [["更新全部过期包"]] },
        { [["Check for new package version"]], [["检查包的最新版本"]] },
        { [["Check for new versions (all packages)"]], [["检查全部包的最新版本"]] },
        { [["Cancel installation of package"]], [["取消安装"]] },
        { [["Close window"]], [["关闭窗口"]] },
        { [["Mason log: "]], [["Mason 日志: "]] },
        { [["Registries"]], [["软件源"]] },
        { [["Packages are sourced from the following registries:"]], [["包来自以下软件源："]] },
        { [["Keyboard shortcuts"]], [["键盘快捷键"]] },
        { [["Problems installing packages"]], [["安装包出问题"]] },
        { [["Make sure you meet the minimum requirements to install packages. For debugging, refer to:"]], [["请先确认满足安装包的最低要求。排查问题请参考："]] },
        { [["Problems with package functionality"]], [["包功能异常"]] },
        { [["Please refer to each package's own homepage for further assistance."]], [["请查阅对应包的主页获取帮助。"]] },
        {
          [[            { p.Bold "How do I use installed packages?" },
            { p.muted "Mason only makes packages available for use. It does not automatically integrate" },
            { p.muted "these into Neovim. You have multiple different options for using any given" },
            { p.muted "package, and you are free to pick and choose as you see fit." },]],
          [[            { p.Bold "安装好的包怎么用？" },
            { p.muted "Mason 只负责把包准备好，并不会自动接入 Neovim。" },
            { p.muted "接入方式有多种，你可以按需自由选择。" },
            {  },]],
        },
        { [["See "]], [["推荐做法见 "]] },
        { [[" for a recommendation."]], [["。"]] },
        { [["Missing a package?"]], [["缺少某个包？"]] },
        { [["Please consider contributing to mason.nvim:"]], [["欢迎向 mason.nvim 贡献："]] },
        { [["(change view by pressing its number)"]], [["（按数字键切换分类）"]] },
      },
    },
    {
      -- 帮助页：LSP 分类
      path = "mason.nvim/lua/mason/ui/components/help/lsp.lua",
      note = "mason 帮助页 LSP 分类（9 条）",
      replacements = {
        { [["What is LSP?"]], [["什么是 LSP？"]] },
        { [["The "]], [["LSP 全称 "]] },
        { [["rotocol defines the protocol used between an"]], [["rotocol（语言服务器协议），"]] },
        { [["editor or IDE and a language server that provides language features"]], [["它定义了编辑器与语言服务器之间的通信协议。"]] },
        { [["like auto complete, go to definition, find all references etc."]], [["语言服务器可提供自动补全、跳转定义、查找引用等功能。"]] },
        { [["The term "]], [["通常说的 "]] },
        { [[" is often used to reference a server implementation of"]], [[" 也用来指代实现了该协议的服务端程序。"]] },
        {
          [[
        { p.none "the LSP protocol." },]],
          [[]],
        },
        { [["For more information, see:"]], [["更多资料："]] },
      },
    },
    {
      -- 帮助页：DAP 分类
      path = "mason.nvim/lua/mason/ui/components/help/dap.lua",
      note = "mason 帮助页 DAP 分类（8 条）",
      replacements = {
        { [["What is DAP?"]], [["什么是 DAP？"]] },
        { [["The "]], [["DAP 全称 "]] },
        { [["rotocol defines the abstract protocol used"]], [["rotocol（调试适配器协议），"]] },
        { [["between a development tool (e.g. IDE or editor) and a debugger."]], [["它定义了开发工具（IDE 或编辑器）与调试器之间的抽象协议。"]] },
        { [["This provides editors with a standardized interface for enabling debugging"]], [["它为编辑器提供统一的调试接口，例如：暂停执行、单步执行、"]] },
        { [["capabilities - such as pausing execution, stepping through statements,"]], [["查看变量值等。"]] },
        {
          [[
        { p.none "and inspecting variables." },]],
          [[]],
        },
        { [["For more information, see:"]], [["更多资料："]] },
      },
    },
    {
      -- 帮助页：Linter 分类（正文整段重排，用多行块替换）
      path = "mason.nvim/lua/mason/ui/components/help/linter.lua",
      note = "mason 帮助页 Linter 分类（2 条）",
      replacements = {
        { [["What is a linter?"]], [["什么是 linter（检查器）？"]] },
        {
          [[        { p.none "A linter is a static code analysis tool used to provide diagnostics around" },
        { p.none "programming errors, bugs, stylistic errors and suspicious constructs." },
        { p.none "Linters can be executed as a standalone program in a terminal, where it" },
        { p.none "usually expects one or more input files to lint. There are also Neovim plugins" },
        { p.none "that integrate these diagnostics inside the editor." },]],
          [[        { p.none "linter 是一种静态代码分析工具，用于提示编程错误、缺陷、" },
        { p.none "风格问题以及可疑写法。" },
        { p.none "它既可以在终端单独运行（通常需要指定一个或多个待检查的文件），" },
        { p.none "也可以通过相应的 Neovim 插件，把检查结果直接显示在编辑器里。" },]],
        },
      },
    },
    {
      -- 帮助页：Formatter 分类（同上）
      path = "mason.nvim/lua/mason/ui/components/help/formatter.lua",
      note = "mason 帮助页 Formatter 分类（2 条）",
      replacements = {
        { [["What is a formatter?"]], [["什么是 formatter（格式化工具）？"]] },
        {
          [[        { p.none "A code formatter is a tool that reformats code to fit a certain" },
        { p.none "formatting convention. This usually entails things like adjusting" },
        { p.none "indentation, breaking long lines into smaller lines, adding or" },
        { p.none "removing whitespaces. Formatting rules are often included as a" },
        { p.none "separate configuration file within the project." },]],
          [[        { p.none "代码格式化工具会按照既定的风格约定重新排版代码，" },
        { p.none "通常包括：调整缩进、把过长的行拆分成多行、增删空白字符等。" },
        { p.none "格式化规则一般由项目内的独立配置文件来指定。" },]],
        },
      },
    },
  },
}
