require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})

require("mason-lspconfig").setup({
	-- ⚠️ 这里必须写 lspconfig 的服务器名（lua_ls），不能写 mason 的包名（lua-language-server），
	-- 否则会报 Server "lua-language-server" is not a valid entry in ensure_installed
	ensure_installed = {
		"lua_ls", -- 写 Neovim 配置必备（原仓库 Five/Six 分支把它注释掉了）
	},
})

-- ⚠️ 原仓库 Three~Six 的 lsp.lua 一直在用未定义的 capabilities 变量，
-- 这里补上定义，否则 LSP 拿不到 nvim-cmp 的补全能力。
local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if cmp_ok then
	capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Lua / Neovim 配置
require'lspconfig'.lua_ls.setup{
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}

-- TypeScript / JavaScript
require'lspconfig'.vtsls.setup{
	capabilities = capabilities
}

-- CSS（原仓库写作 css_ls，按 lspconfig 正确名称修正）
require'lspconfig'.cssls.setup{
	capabilities = capabilities
}

-- Vue
require'lspconfig'.vuels.setup{
	capabilities = capabilities
}

-- HTML
require'lspconfig'.html.setup{
	capabilities = capabilities
}

-- C / C++ 配置
-- 原仓库硬编码 cmd = { "clangd-18" }，该命令名在本机不存在，已移除让 lspconfig 自动探测。
-- 若未安装 clangd，可执行 :MasonInstall clangd，或把下面整段注释掉。
require'lspconfig'.clangd.setup{
	capabilities = {
		offsetEncoding = { "utf-8", "utf-16" },
		textDocument = {
			completion = {
				editsNearCursor = true
			}
		}
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
	root_dir = require'lspconfig'.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
	single_file_support = true,
}

-- Java（Eclipse JDT Language Server）
-- 需要 Java 21+ 运行时，本机为 JDK 24（通过 JEnv 管理）。
-- jdtls 本体由 mason 安装，已在 PATH 中，lspconfig 会自动处理启动参数。
-- 首次在 Java 项目里打开文件时会自动下载 eclipse.jdt.ls，需要联网。
-- 注意：判断服务器是否受支持必须用 require("lspconfig.configs")，
-- 写成 require'lspconfig'.configs 会被 lspconfig 的元表当成服务器名查找并报
-- [lspconfig] config "configs" not found。
pcall(function()
	local configs = require("lspconfig.configs")
	if configs and configs.jdtls then
		require'lspconfig'.jdtls.setup({
			capabilities = capabilities,
			root_dir = require'lspconfig'.util.root_pattern(
				".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle"
			),
			single_file_support = true,
		})
	end
end)
