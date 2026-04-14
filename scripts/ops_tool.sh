#!/bin/bash
set -e

echo "更新软件包列表..."
sudo apt update

# echo "配置：测试并选择最快的https镜像源,默认写入配置文件..."
# sudo nala fetch --auto --https-only -y

echo "执行软件包同步与升级..."
sudo nala update
sudo nala upgrade -y

echo "ops tool..."
sudo nala install -y \
  network-manager dnsutils rsync \
  ptcpdump tshark termshark \