#!/usr/bin/env bash
# ============================================================
#  My-Nvim-Config 安装脚本 (Linux / macOS)
#  用法:  bash install.sh
# ============================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; GRAY='\033[0;90m'; NC='\033[0m'

step() { echo -e "\n${CYAN}==> $1${NC}"; }
ok()   { echo -e "    ${GREEN}[OK]${NC} $1"; }
warn() { echo -e "    ${YELLOW}[!]${NC}  $1"; }
err()  { echo -e "    ${RED}[X]${NC}  $1"; }

echo "My-Nvim-Config 安装"
echo "==================="

# ---------- 1. 检查 Neovim ----------
step "检查 Neovim"
if ! command -v nvim >/dev/null 2>&1; then
    err "未找到 nvim，请先安装（apt install neovim / brew install neovim）"
    exit 1
fi
NVIM_VER=$(nvim --version | head -n1)
echo "    $NVIM_VER"
ok "已安装"

# ---------- 2. 检查依赖 ----------
step "检查依赖"
check_dep() {
    if command -v "$1" >/dev/null 2>&1; then
        ok "$1"
    else
        warn "$1 缺失（$2）"
        MISSING="$MISSING $1"
    fi
}
MISSING=""
check_dep git         "下载插件"
check_dep gcc         "编译语法解析器"
check_dep tree-sitter "驱动解析器编译"
check_dep rg          "Telescope 全文搜索"
check_dep fd          "Telescope 文件查找"
check_dep node        "LSP 运行环境"

if echo "$MISSING" | grep -q tree-sitter; then
    echo -e "\n    ${YELLOW}安装 tree-sitter CLI...${NC}"
    echo -e "    ${GRAY}注意: npm 11 起必须加 --allow-scripts${NC}"
    npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
fi

# ---------- 3. 部署配置 ----------
step "部署配置"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$TARGET" != "$SOURCE" ]; then
    if [ -e "$TARGET" ]; then
        BACKUP="${TARGET}.bak-$(date +%Y%m%d-%H%M%S)"
        mv "$TARGET" "$BACKUP"
        ok "已备份原配置到 $BACKUP"
    fi
    mkdir -p "$TARGET"
    for item in init.lua lazy-lock.json lua .gitignore LICENSE README.md; do
        [ -e "$SOURCE/$item" ] && cp -r "$SOURCE/$item" "$TARGET/"
    done
    ok "配置已部署到 $TARGET"
else
    ok "脚本就在配置目录内运行，无需复制"
fi

# ---------- 4. 完成 ----------
step "安装完成"
cat <<'EOF'

后续步骤:
  1. 执行 nvim，等待插件自动下载完成（约 1-3 分钟）
  2. 在 nvim 中执行 :TSUpdate 编译语法解析器
  3. 执行 :checkhealth 验证环境

常用命令:
  :Lazy            插件管理（U 升级单个插件，R 恢复锁定版本）
  :Mason           语言服务器管理
  :TSUpdate        更新语法解析器
  :checkhealth     健康检查

注意:
  - 终端字体需设置为 Nerd Font，否则图标显示为方块
  - 剪贴板功能依赖 xclip (X11) 或 wl-clipboard (Wayland)
EOF