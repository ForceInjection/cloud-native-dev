#!/bin/bash

# 开启严格模式：脚本中任意命令失败时立即退出
set -e

# 1. 安装 Kubernetes 所需依赖（如 conntrack，若系统已装可忽略）
# 注意：离线环境需提前准备好 conntrack.deb，否则此步骤会失败
apt install -y conntrack

# 2. 解压离线包，包含镜像、minikube/kubectl 等二进制文件
tar -xzvf minikube-offline.tar.gz
tar -xzvf minikube-v1.23.17-binaries.tar.gz -C /tmp/

mv /tmp/root/.minikube/ ~/

# 3. 进入 packages 子目录（假设二进制和镜像存放在此目录下）
cd packages

# 4. 安装 minikube 到 /usr/local/bin（确保具有可执行权限）
sudo install ./minikube-linux-amd64 /usr/local/bin/minikube

# 5. 安装 kubectl 到 /usr/local/bin（用于与 K8s API 交互）
sudo install ./kubectl /usr/local/bin/kubectl

# 6. 加载所有 Kubernetes 所需镜像到 Docker（统一打包为一个 tar 文件）
docker load -i k8s-images-v1.23.17.tar

# 7. 启动 minikube，指定 driver=none 和固定版本（需 root 权限）
sudo minikube start --driver=none --kubernetes-version=v1.23.17