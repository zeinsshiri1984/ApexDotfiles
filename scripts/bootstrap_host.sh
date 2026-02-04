#!/bin/bash

echo "更新软件包列表..."
sudo apt update

echo "安装 nala..."
sudo apt install nala -y

echo "配置：测试并选择最快的镜像源..."
sudo nala fetch

echo "执行软件包同步与升级..."
sudo nala update
sudo nala upgrade -y

echo "配置：清理孤儿依赖..."
sudo nala autoremove -y
sudo nala autopurge -y
sudo apt --fix-broken install

echo "nala 安装与配置完毕。后续执行just nala维护系统包"