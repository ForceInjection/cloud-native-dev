#!/bin/bash

# Redis 资源清理脚本

set -e

echo "开始清理 Redis 相关资源..."

# 1. 删除 Deployment 和 Service
echo "1. 删除 Redis Deployment 和 Service..."
kubectl delete -f redis-deployment.yaml --ignore-not-found=true -n redis

# 2. 删除 ConfigMap（如果存在）
echo "2. 删除 Redis ConfigMap（如果存在）..."
kubectl delete -f redis-configmap.yaml --ignore-not-found=true -n redis

# 3. 删除网络策略（如果存在）
echo "3. 删除网络策略（如果存在）..."
kubectl delete -f redis-network-policy.yaml --ignore-not-found=true -n redis

# 4. 删除 Secret（如果存在）
echo "4. 删除 Redis Secret（如果存在）..."
kubectl delete secret redis-secret --ignore-not-found=true -n redis

# 5. 清理可能残留的测试 Pod
echo "5. 清理测试相关的 Pod..."
kubectl delete pod redis-client --ignore-not-found=true -n redis
kubectl delete pod redis-test --ignore-not-found=true -n redis
kubectl delete pod redis-benchmark --ignore-not-found=true -n redis

# 6. 验证清理结果
echo "6. 验证清理结果..."
echo "检查 Redis 相关 Pod："
kubectl get pods -l app=redis -n redis
echo "检查 Redis 相关 Service："
kubectl get svc redis-service --ignore-not-found=true -n redis

echo "Redis 资源清理完成！"