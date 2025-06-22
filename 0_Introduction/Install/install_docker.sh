#!/bin/bash
set -e

echo ">>> 更新软件包..."
sudo apt update

echo ">>> 安装基础依赖..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo ">>> 添加阿里云 Docker GPG 密钥..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://mirrors.cloud.aliyuncs.com/docker-ce/linux/ubuntu/gpg | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null

echo ">>> 添加 Docker 镜像源（cloud.aliyuncs.com）..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  http://mirrors.cloud.aliyuncs.com/docker-ce/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ">>> 安装 Docker 引擎..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

echo ">>> 配置 Docker 镜像加速器..."
sudo mkdir -p /etc/docker
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io/"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF

echo ">>> 重启 Docker 服务..."
sudo systemctl daemon-reexec
sudo systemctl restart docker

echo ">>> Docker 安装完成！"
docker version