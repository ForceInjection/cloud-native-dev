#!/bin/bash

# Redis on Kubernetes 部署脚本

set -e

echo "开始部署 Redis on Kubernetes..."

# 1. 创建命名空间（可选）
echo "创建命名空间（可选）..."
if kubectl get namespace redis >/dev/null 2>&1; then
    echo "命名空间 'redis' 已存在，跳过创建"
else
    echo "创建命名空间 'redis'"
    kubectl create namespace redis
fi

# 2. 部署 Redis
echo "部署 Redis Deployment 和 Service..."
kubectl apply -f redis-deployment.yaml -n redis

# 3. 部署 ConfigMap（可选）
echo "部署 Redis ConfigMap（可选）..."
# kubectl apply -f redis-configmap.yaml -n redis

# 4. 部署网络策略（可选）
echo "部署网络策略（可选）..."
# kubectl apply -f redis-network-policy.yaml -n redis

# 5. 等待 Pod 就绪
echo "等待 Redis Pod 就绪..."
kubectl wait --for=condition=ready pod -l app=redis --timeout=300s -n redis

# 6. 检查部署状态
echo "检查部署状态..."
kubectl get pods -l app=redis -n redis
kubectl get svc redis-service -n redis

echo "Redis 部署完成！"
echo "使用以下命令测试连接："
echo "kubectl run redis-client --rm -it --restart=Never --image=redis:7-alpine -n redis -- redis-cli -h redis-service -p 6379"
