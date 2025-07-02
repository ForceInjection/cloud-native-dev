#!/bin/bash

# Redis 功能验证测试脚本

set -e

echo "开始 Redis 功能验证测试..."

# 1. 检查 Pod 状态
echo "1. 检查 Redis Pod 状态..."
kubectl get pods -l app=redis -n redis
kubectl describe pod -l app=redis -n redis

# 2. 检查服务状态
echo "2. 检查 Redis Service 状态..."
kubectl get svc redis-service -o wide -n redis

# 3. 查看日志
echo "3. 查看 Redis 日志..."
kubectl logs -l app=redis --tail=20 -n redis

# 4. 基本连接测试
echo "4. 执行基本连接测试..."
kubectl run redis-test --rm -it --restart=Never --image=redis:7-alpine -n redis -- redis-cli -h redis-service -p 6379 ping

# 5. 功能测试
echo "5. 执行功能测试..."
echo "5.1 测试 SET/GET 操作..."
kubectl run redis-test --rm -it --restart=Never --image=redis:7-alpine -n redis -- sh -c "redis-cli -h redis-service -p 6379 set test-key 'Hello Redis' && redis-cli -h redis-service -p 6379 get test-key"

echo "5.2 测试 LIST 操作..."
kubectl run redis-test --rm -it --restart=Never --image=redis:7-alpine -n redis -- sh -c "redis-cli -h redis-service -p 6379 lpush test-list item1 item2 item3 && redis-cli -h redis-service -p 6379 lrange test-list 0 -1"

echo "5.3 测试 HASH 操作..."
kubectl run redis-test --rm -it --restart=Never --image=redis:7-alpine -n redis -- sh -c "redis-cli -h redis-service -p 6379 hset test-hash field1 value1 field2 value2 && redis-cli -h redis-service -p 6379 hgetall test-hash"

echo "5.4 查看服务器信息..."
kubectl run redis-test --rm -it --restart=Never --image=redis:7-alpine -n redis -- redis-cli -h redis-service -p 6379 info server

# 6. 性能基准测试
echo "6. 执行性能基准测试..."
kubectl run redis-benchmark --rm -it --restart=Never --image=redis:7-alpine -n redis -- redis-benchmark -h redis-service -p 6379 -c 10 -n 1000 -q

# 7. 故障恢复测试
echo "7. 执行故障恢复测试..."
echo "删除 Redis Pod 进行重启测试..."
kubectl delete pod -l app=redis -n redis
echo "等待 Pod 重新创建..."
kubectl wait --for=condition=ready pod -l app=redis --timeout=300s -n redis
echo "验证服务恢复..."
kubectl run redis-test --rm -it --restart=Never --image=redis:7-alpine -n redis -- redis-cli -h redis-service -p 6379 ping

echo "Redis 功能验证测试完成！"