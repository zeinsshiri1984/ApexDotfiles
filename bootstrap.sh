#!/bin/bash
set -e # 遇到错误立即停止

# --- 检测系统类型 ---
IS_IMMUTABLE=0
if [ -f /run/ostree-booted ]; then
    IS_IMMUTABLE=1
    echo "🛡️ 检测到不可变系统 (Immutable OS)"
fi

echo "📦 更新Base OS基础依赖(仅在可变系统执行) ..."
if [ "$IS_IMMUTABLE" -eq 0 ]; then
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y build-essential curl file git procps
    elif command -v dnf &>/dev/null; then
        sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y curl file git procps-ng
    fi
else
    echo "⚠️  跳过系统包安装。若缺少依赖，请使用 rpm-ostree install <pkg> 并重启。"
fi

echo "🍺 安装 Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "brew安装核心工具..."
brew install gcc gh git chezmoi age

# ---  身份认证---
if ! gh auth status &>/dev/null; then
    echo "🔑 请登录 GitHub (支持 HTTPS/SSH)..."
    # -p ssh: 强制使用 SSH 协议
    # -w: 使用 Web 浏览器登录
    # --git-protocol ssh: 确保后续 git clone 操作默认用 git@github.com
    gh auth login -p ssh -w --git-protocol ssh
    
    if [ $? -ne 0 ]; then
        echo "❌ 登录失败或被取消，脚本终止。"
        exit 1
    fi
fi

# 安装 gh-copilot
if gh extension list | grep -q "github/gh-copilot"; then
    echo "   -> gh-copilot 扩展已安装，尝试更新..."
    gh extension upgrade github/gh-copilot || true
else
    echo "   -> 正在安装 gh-copilot..."
    gh extension install github/gh-copilot
fi

echo "🐳 配置 Rootless Podman 容器环境..."
if ! command -v podman &>/dev/null; then
    brew install podman podman-compose
fi

# 许多工具直接寻找 PATH 中的 docker 二进制文件，Alias 对它们无效
DOCKER_BIN="$HOME/.local/bin/docker"
mkdir -p "$(dirname "$DOCKER_BIN")"

if [ ! -f "$DOCKER_BIN" ]; then
    cat << 'EOF' > "$DOCKER_BIN"
#!/bin/sh
# 转发所有命令给 podman，但对一些不支持的参数做过滤（如果需要）
exec podman "$@"
EOF
    chmod +x "$DOCKER_BIN"
    echo "✅ Docker -> Podman Shim 已建立"
fi

# 设置 DOCKER_HOST 环境变量的持久化将在 zsh 配置中完成
# 在不可变系统上通常不需要做这一步，靠 alias 即可
echo "🐳 启用 Podman Socket (Rootless)(欺骗依赖 Docker Socket 的工具如 Devbox)..."
if ! systemctl --user is-active podman.socket &>/dev/null; then
    systemctl --user enable --now podman.socket
fi

# 写入兼容性环境变量 (供 Testcontainers/Java/Go 等库使用)
# 这一步在 .zshenv 中持久化，这里是为了当前脚本后续步骤有效
export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="${XDG_RUNTIME_DIR}/podman/podman.sock"

# --- Age 密钥恢复&生成 ---
KEY_DIR="$HOME/.config/sops/age"
KEY_FILE="$KEY_DIR/keys.txt"

if [ ! -f "$KEY_FILE" ]; then
    echo "⚠️  未检测到 Age 密钥！"
    echo "1. 生成新密钥 (仅限第一台设备)"
    echo "2. 手动粘贴已有密钥 (用于同步/恢复)"
    read -p "请选择 [1/2]: " choice
    
    mkdir -p "$KEY_DIR"
    
    if [ "$choice" == "1" ]; then
        age-keygen -o "$KEY_FILE"
        echo "✅ 新密钥已生成，请务必备份！"
    else
        echo "请粘贴 keys.txt 的内容 (AGE-SECRET-KEY-xxx):"
        read -s secret_key
        echo "$secret_key" > "$KEY_FILE"
        # 验证密钥格式
        if grep -q "AGE-SECRET-KEY" "$KEY_FILE"; then
            echo "✅ 密钥已恢复。"
        else
            echo "❌ 密钥格式错误，请检查。" && rm "$KEY_FILE" && exit 1
        fi
    fi
    chmod 600 "$KEY_FILE"
fi

export AGE_PUBLIC_KEY=$(grep "public key" ~/.config/sops/age/keys.txt | cut -d: -f2 | tr -d ' ')

echo "⚡️ 拉取并应用配置..."
# --apply 会自动触发 run_onchange 脚本安装剩余软件
chezmoi init --apply --ssh zeinsshiri1984/ApexDotfiles

echo "🐚 切换默认 Shell 到 Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo usermod --shell "$(which zsh)" "$USER"
fi

echo "🎉 系统就绪！请重启终端。"