#!/bin/bash
set -e

echo "更新软件包列表..."
sudo apt update

echo "安装 nala..."
sudo apt install nala -y

# echo "配置：测试并选择最快的https镜像源,默认写入配置文件..."
# sudo nala fetch --auto --https-only -y

echo "执行软件包同步与升级..."
sudo nala update
sudo nala upgrade -y

echo "安装系统基础依赖和服务..."
sudo nala install -y \
  build-essential \
  ca-certificates \
  wget curl \
  unzip \
  git \
  file \
  tar gzip \
  xdg-user-dirs \
  uidmap slirp4netns fuse-overlayfs \
  podman podman-docker

echo "获取 Mihomo & Metacubexd最新版本下载链接..."
MIHOMO_URL=$(
  curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | grep -v compatible \
  | grep '.gz"' \
  | head -n 1 \
  | cut -d '"' -f 4
)

META_UI_URL=$(
  curl -s https://api.github.com/repos/MetaCubeX/metacubexd/releases/latest \
  | grep browser_download_url \
  | grep compressed-dist.tgz \
  | head -n 1 \
  | cut -d '"' -f 4
)

echo "下载安装 Mihomo..."
wget -qO /tmp/mihomo.gz "$MIHOMO_URL"
gunzip -f /tmp/mihomo.gz
chmod +x /tmp/mihomo
sudo mv -f /tmp/mihomo /usr/local/bin/mihomo

echo "部署 Metacubexd Web UI..."
sudo mkdir -p /etc/mihomo/ui
wget -qO /tmp/metacubexd.tgz "$META_UI_URL"
sudo rm -rf /etc/mihomo/ui/*
sudo tar -xzf /tmp/metacubexd.tgz -C /etc/mihomo/ui
rm -f /tmp/metacubexd.tgz

echo "生成配置文件..."
sudo mkdir -p /etc/mihomo
sudo tee /etc/mihomo/config.yaml >/dev/null <<EOF
mixed-port: 7890                # HTTP/SOCKS5 混合端口
allow-lan: true                 # 允许局域网访问
bind-address: '*'               # 监听所有网卡

mode: rule
log-level: info

external-controller: 0.0.0.0:9090  # API 监听地址
external-ui: /etc/mihomo/ui
secret: ''

ipv6: true
EOF

echo "部署 systemd 服务..."
sudo tee /etc/systemd/system/mihomo.service >/dev/null <<EOF
[Unit]
Description=Mihomo Service
Documentation=https://wiki.metacubex.one
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/etc/mihomo
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
Restart=always
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mihomo >/dev/null 2>&1
sudo systemctl restart mihomo

echo "配置 Podman 无根模式权限(解决无根模式无法绑定低端口的问题)..."
echo "net.ipv4.ip_unprivileged_port_start=0" | sudo tee /etc/sysctl.d/99-podman-privileged-ports.conf
sudo sysctl --system >/dev/null

echo "启用用户驻留，确保用户退出 SSH 后容器不挂掉"
sudo loginctl enable-linger $(whoami)

echo "配置 Podman 全局镜像源 (Root/Rootless 通用)..."
sudo mkdir -p /etc/containers
sudo tee /etc/containers/registries.conf >/dev/null <<EOF
unqualified-search-registries = ["docker.io", "quay.io"]

[[registry]]
prefix = "docker.io"
location = "docker.io"
# 如果 Mihomo 很稳，其实不需要 mirror，但留着防备
[[registry.mirror]]
location = "docker.m.daocloud.io"
EOF

# containers.conf: 核心配置
# 修正点：使用 host.containers.internal 指向宿主机
cat <<EOF > ~/.config/containers/containers.conf
[containers]
log_size_max = 52428800

[engine]
events_logger = "file"
# 这里配置环境变量，让所有容器启动时默认走代理
# 注意：host.containers.internal 是 Podman 特有的宿主机 DNS
env = [
  "HTTP_PROXY=http://host.containers.internal:7890",
  "HTTPS_PROXY=http://host.containers.internal:7890",
  "NO_PROXY=localhost,127.0.0.1,::1,host.containers.internal"
]
EOF

echo "配置 Podman 用户级代理 (仅针对当前用户 Rootless)"
# 给当前用户配置默认代理，防止干扰 sudo podman 运行系统服务
mkdir -p ~/.config/containers
cat <<EOF > ~/.config/containers/containers.conf
[containers]
# 限制日志大小
log_size_max = 52428800

[engine]
# 事件日志驱动
events_logger = "file"
# 让容器内部自动走宿主机代理;host.containers.internal 自动解析为宿主机 IP
env = [
  "HTTP_PROXY=http://host.containers.internal:7890",
  "HTTPS_PROXY=http://host.containers.internal:7890",
  "NO_PROXY=localhost,127.0.0.1,::1,host.containers.internal"
]
EOF

LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "host环境部署完毕。GeoIP / GeoSite / rule-provider 将在首次订阅加载时自动下载，无需手动干预;后续执行 just nala 或 just mihomo 或just mihomo-tips或just podman进行维护。"
echo "在浏览器打开webUI管理：http://$LOCAL_IP:9090/ui"
echo "Mihomo 服务管理（原生命令）："
echo "  启动:   sudo systemctl start mihomo"
echo "  停止:   sudo systemctl stop mihomo"
echo "  重启:   sudo systemctl restart mihomo"
echo "  状态:   systemctl status mihomo"
echo "  日志查看: journalctl -u mihomo -f"
echo " podman原生命令:"
echo "  检查配置:       podman info"
echo "  拉取镜像:       podman pull alpine (已自动走代理)"
echo "  查看镜像/容器:  podman images / podman ps -a"
echo "  别名测试:       docker ps"