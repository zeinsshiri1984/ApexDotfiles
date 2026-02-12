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
  git \
  file \
  gzip \
  xdg-user-dirs \
  uidmap slirp4netns fuse-overlayfs \
  podman podman-docker

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

[[registry.mirror]]
location = "docker.m.daocloud.io"
EOF

echo "containers.conf配置用户级 Podman引擎参数..."
# host.containers.internal 指向宿主机
mkdir -p $HOME/.config/containers
cat <<EOF > ~/.config/containers/containers.conf
[containers]
log_size_max = 52428800

[engine]
events_logger = "file"
env = [
  "http_proxy",
  "https_proxy",
  "ftp_proxy",
  "no_proxy",
  "HTTP_PROXY",
  "HTTPS_PROXY",
  "FTP_PROXY",
  "NO_PROXY"
]
EOF

echo "host环境部署完毕。后续执行 just nala 或just podman进行维护。"
echo " podman原生命令:"
echo "  检查配置:       podman info"
echo "  拉取镜像:       podman pull alpine (已自动走代理)"
echo "  查看镜像/容器:  podman images / podman ps -a"
echo "  别名测试:       docker ps"