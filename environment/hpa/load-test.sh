#!/bin/bash

# HPA 负载测试脚本
# 用于测试 HPA 自动扩缩容功能

set -e

echo "=== HPA 负载测试脚本 ==="

# 检查示例应用是否存在
if ! kubectl get deployment nginx-hpa-demo >/dev/null 2>&1; then
    echo "错误: nginx-hpa-demo 部署不存在"
    echo "请先运行 deploy-hpa.sh 部署示例应用"
    exit 1
fi

# 检查 HPA 是否存在
if ! kubectl get hpa nginx-hpa-demo >/dev/null 2>&1; then
    echo "错误: nginx-hpa-demo HPA 不存在"
    echo "请先运行 deploy-hpa.sh 部署 HPA"
    exit 1
fi

echo "当前 HPA 状态:"
kubectl get hpa nginx-hpa-demo

echo ""
echo "当前 Pod 数量:"
kubectl get pods -l app=nginx-hpa-demo

echo ""
echo "=== 开始负载测试 ==="
echo "创建负载测试 Pod..."

# 创建负载测试 Pod
kubectl run load-generator --rm -i --tty --image=busybox --restart=Never -- /bin/sh -c "
echo '开始负载测试...'
echo '目标服务: nginx-hpa-demo-service'
echo '测试时间: 5分钟'
echo ''

# 并发发送请求
for i in \$(seq 1 4); do
  (
    while true; do
      wget -q -O- http://nginx-hpa-demo-service/ >/dev/null 2>&1
    done
  ) &
done

echo '负载测试已启动，请在另一个终端监控 HPA 状态'
echo '监控命令: watch kubectl get hpa nginx-hpa-demo'
echo '监控命令: watch kubectl get pods -l app=nginx-hpa-demo'
echo ''
echo '等待 5 分钟...'
sleep 300

echo '负载测试完成'
" &

LOAD_PID=$!

echo "负载测试已启动 (PID: $LOAD_PID)"
echo ""
echo "=== 监控 HPA 状态 ==="
echo "观察 HPA 扩容过程..."

# 监控 HPA 状态
for i in {1..30}; do
    echo "=== 第 $i 次检查 ($(date)) ==="
    echo "HPA 状态:"
    kubectl get hpa nginx-hpa-demo
    echo "Pod 数量:"
    kubectl get pods -l app=nginx-hpa-demo --no-headers | wc -l | xargs echo "当前 Pod 数量:"
    echo "Pod 状态:"
    kubectl get pods -l app=nginx-hpa-demo
    echo "Pod 资源使用:"
    kubectl top pods -l app=nginx-hpa-demo 2>/dev/null || echo "资源指标暂不可用"
    echo "----------------------------------------"
    sleep 10
done

echo ""
echo "=== 停止负载测试 ==="
kill $LOAD_PID 2>/dev/null || true
kubectl delete pod load-generator --ignore-not-found=true

echo ""
echo "=== 观察缩容过程 ==="
echo "负载停止后，观察 HPA 缩容..."

for i in {1..20}; do
    echo "=== 缩容观察第 $i 次检查 ($(date)) ==="
    echo "HPA 状态:"
    kubectl get hpa nginx-hpa-demo
    echo "Pod 数量:"
    kubectl get pods -l app=nginx-hpa-demo --no-headers | wc -l | xargs echo "当前 Pod 数量:"
    echo "----------------------------------------"
    sleep 30
done

echo ""
echo "=== 测试完成 ==="
echo "最终状态:"
kubectl get hpa nginx-hpa-demo
kubectl get pods -l app=nginx-hpa-demo