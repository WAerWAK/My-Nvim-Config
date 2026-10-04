# ============================================================
#  My-Nvim-Config 安装脚本 (Windows)
#  用法:  powershell -ExecutionPolicy Bypass -File install.ps1
# ============================================================
$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Warn2($msg){ Write-Host "    [!]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "    [X]  $msg" -ForegroundColor Red }

Write-Host "My-Nvim-Config 安装" -ForegroundColor White
Write-Host "===================" -ForegroundColor White

# ---------- 1. 检查 Neovim 版本 ----------
Write-Step "检查 Neovim"
$nvim = Get-Command nvim -ErrorAction SilentlyContinue
if (-not $nvim) {
    Write-Err "未找到 nvim，请先安装: scoop install neovim"
    exit 1
}
$verOut = (& nvim --version | Select-Object -First 1) -join ''
Write-Host "    $verOut"
if ($verOut -match 'v(\d+)\.(\d+)') {
    $major = [int]$Matches[1]; $minor = [int]$Matches[2]
    if ($major -lt 1 -and $minor -lt 12) {
        Write-Err "需要 Neovim 0.12.0 或更高（当前 $major.$minor），请升级"
        exit 1
    }
    Write-Ok "版本满足要求"
}

# ---------- 2. 检查必需依赖 ----------
Write-Step "检查依赖"
$deps = @{
    'git'         = '下载插件'
    'gcc'         = '编译语法解析器'
    'tree-sitter' = '驱动解析器编译'
    'rg'          = 'Telescope 全文搜索'
    'fd'          = 'Telescope 文件查找'
    'node'        = 'vtsls 等 LSP 运行环境'
}
$missing = @()
foreach ($d in $deps.Keys) {
    if (Get-Command $d -ErrorAction SilentlyContinue) {
        Write-Ok "$d"
    } else {
        Write-Warn2 "$d 缺失（$($deps[$d])）"
        $missing += $d
    }
}

if ($missing -contains 'tree-sitter') {
    Write-Host "`n    安装 tree-sitter CLI..." -ForegroundColor Yellow
    Write-Host "    注意: npm 11 起必须加 --allow-scripts，否则二进制不会下载" -ForegroundColor DarkGray
    npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
}

if ($missing -contains 'gcc' -or $missing -contains 'rg' -or $missing -contains 'fd') {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "`n    通过 scoop 安装缺失依赖..." -ForegroundColor Yellow
        $toInstall = @()
        if ($missing -contains 'gcc') { $toInstall += 'gcc' }
        if ($missing -contains 'rg')  { $toInstall += 'ripgrep' }
        if ($missing -contains 'fd')  { $toInstall += 'fd' }
        if ($toInstall.Count -gt 0) { scoop install @toInstall }
    } else {
        Write-Warn2 "未检测到 scoop，请手动安装: $($missing -join ', ')"
    }
}

# ---------- 3. 处理 cc 别名 ----------
Write-Step "配置 cc 编译器别名"
Write-Host "    nvim-treesitter 需要 'cc' 命令，而 scoop 的 gcc 只提供 gcc.exe" -ForegroundColor DarkGray
$gccDir = $null
$gccCmd = Get-Command gcc -ErrorAction SilentlyContinue
if ($gccCmd) { $gccDir = Split-Path $gccCmd.Source -Parent }
if ($gccDir -and (Test-Path "$gccDir\gcc.exe")) {
    if (-not (Test-Path "$gccDir\cc.exe")) {
        Copy-Item "$gccDir\gcc.exe" "$gccDir\cc.exe"
        Write-Ok "已创建 cc.exe 于 $gccDir"
    } else {
        Write-Ok "cc.exe 已存在"
    }
} else {
    Write-Warn2 "未找到 gcc.exe，跳过（解析器编译可能失败）"
}

# ---------- 4. 部署配置 ----------
Write-Step "部署配置到 %LOCALAPPDATA%\nvim"
$target = "$env:LOCALAPPDATA\nvim"
$source = $PSScriptRoot

if ($target -ne $source) {
    if (Test-Path $target) {
        $backup = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Move-Item $target $backup
        Write-Ok "已备份原配置到 $backup"
    }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    foreach ($item in @('init.lua', 'lazy-lock.json', 'lua', '.gitignore', 'LICENSE', 'README.md')) {
        $src = Join-Path $source $item
        if (Test-Path $src) { Copy-Item $src $target -Recurse -Force }
    }
    Write-Ok "配置已部署到 $target"
} else {
    Write-Ok "脚本就在配置目录内运行，无需复制"
}

# ---------- 5. 完成 ----------
Write-Step "安装完成"
Write-Host @"

后续步骤:
  1. 重新打开终端（让 PATH 变更生效）
  2. 执行 nvim，等待插件自动下载完成（约 1-3 分钟）
  3. 在 nvim 中执行 :TSUpdate 编译语法解析器
  4. 执行 :checkhealth 验证环境

常用命令:
  :Lazy            插件管理（U 升级单个插件，R 恢复锁定版本）
  :Mason           语言服务器管理
  :TSUpdate        更新语法解析器
  :checkhealth     健康检查

配置文件位置: $target
数据目录位置: $env:LOCALAPPDATA\nvim-data
"@ -ForegroundColor Gray