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
wget -O /tmp/mihomo.gz "$LATEST_URL"
gunzip -f /tmp/mihomo.gz
chmod +x /tmp/mihomo
sudo mv -f /tmp/mihomo /usr/local/bin/mihomo

echo "部署 Metacubexd Web UI..."
sudo mkdir -p /etc/mihomo/ui
wget -O /tmp/metacubexd.tgz "$META_UI_URL"
sudo rm -rf /etc/mihomo/ui/*
sudo tar -xzf /tmp/metacubexd.tgz -C /etc/mihomo/ui
rm -f /tmp/metacubexd.tgz

echo "生成配置文件..."
CONFIG_FILE="/etc/mihomo/config.yaml"
SUB_FILE="/etc/mihomo/subscription.url"

SUB_URL=""
if [ -t 0 ]; then
    read -p "请输入订阅链接 (回车留空则使用纯净模板): " SUB_URL
fi

if [ -n "$SUB_URL" ]; then
  echo "写入订阅地址..."
  echo "$SUB_URL" | sudo tee "$SUB_FILE" >/dev/null

  echo "下载订阅配置..."
  if ! sudo curl -L -o "$CONFIG_FILE" "$SUB_URL"; then
    echo "订阅下载失败，回退到最小模板。"
    sudo rm -f "$SUB_FILE"
    SUB_URL=""
  fi
fi

# 如果没有订阅或下载失败，写入最小化模板
if [ -z "$SUB_URL" ]; then
  echo "写入最小配置模板..."
  sudo tee "$CONFIG_FILE" >/dev/null <<EOF
port: 7890
socks-port: 7891
allow-lan: true
mode: rule
log-level: info
EOF
fi

echo "正在注入 WebUI 强制参数..."
sudo sed -i '/^external-controller:/d' "$CONFIG_FILE"
sudo sed -i '/^external-ui:/d' "$CONFIG_FILE"
sudo sed -i '/^secret:/d' "$CONFIG_FILE"
sudo sed -i '/^ipv6:/d' "$CONFIG_FILE"

sudo tee -a "$CONFIG_FILE" >/dev/null <<EOF
ipv6: true
external-controller: 0.0.0.0:9090
external-ui: ui
secret: ''
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
echo "部署环境初始化完毕。后续请执行 just nala 或 just mihomo 进行维护。"
echo "订阅管理在浏览器打开：http://$LOCAL_IP:9090/ui"
echo "如果不通，请检查云服务商防火墙是否放行 TCP:9090"
echo "运行状态："
echo "  systemctl status mihomo"
echo "  journalctl -u mihomo"