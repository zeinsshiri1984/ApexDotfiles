#!/bin/bash

echo "更新软件包列表..."
sudo apt update

echo "安装 nala..."
sudo apt install nala -y

echo "配置：测试并选择最快的https镜像源,默认写入配置文件..."
sudo nala fetch --auto --https-only -y

echo "执行软件包同步与升级..."
sudo nala update
sudo nala upgrade -y

echo "安装系统基础依赖..."
sudo nala install -y build-essential ca-certificates wget curl unzip git file tar gzip

echo "获取 Mihomo & Metacubexd最新版本下载链接..."
LATEST_URL=$(
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

LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "部署环境初始化完毕。GeoIP / GeoSite / rule-provider 将在首次订阅加载时自动下载，无需手动干预;后续执行 just nala 或 just mihomo 或just mihomo-tips进行维护。"
echo "在浏览器打开webUI管理：http://$LOCAL_IP:9090/ui"
echo "Mihomo 服务管理（原生命令）："
echo "  启动:   sudo systemctl start mihomo"
echo "  停止:   sudo systemctl stop mihomo"
echo "  重启:   sudo systemctl restart mihomo"
echo "  状态:   systemctl status mihomo"
echo "  日志查看: journalctl -u mihomo -f"