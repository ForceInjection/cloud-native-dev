#!/bin/bash
set -e

echo ">>> 更新软件包..."
sudo apt update

echo ">>> 安装基础依赖..."
sudo apt install -y ca-certificates curl gnupg lsb-release

echo ">>> 检测网络环境并选择合适的镜像源..."

# 检测是否为阿里云内网环境
if curl -s --connect-timeout 3 http://100.100.100.200/latest/meta-data/ > /dev/null 2>&1; then
    # 阿里云内网环境，使用内网镜像源
    DOCKER_MIRROR="mirrors.cloud.aliyuncs.com"
    echo ">>> 检测到阿里云内网环境，使用内网镜像源: $DOCKER_MIRROR"
else
    # 外网环境，使用公网镜像源
    DOCKER_MIRROR="mirrors.aliyun.com"
    echo ">>> 检测到外网环境，使用公网镜像源: $DOCKER_MIRROR"
fi

echo ">>> 添加阿里云 Docker GPG 密钥..."
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://$DOCKER_MIRROR/docker-ce/linux/ubuntu/gpg | \
  gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null

echo ">>> 添加 Docker 镜像源（$DOCKER_MIRROR）..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  http://$DOCKER_MIRROR/docker-ce/linux/ubuntu \
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