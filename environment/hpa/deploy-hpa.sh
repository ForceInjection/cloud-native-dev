#!/bin/bash

# HPA 本地部署脚本
# 适用于 Kubernetes v1.23+ 本地集群（已测试 v1.31.2+k3s1）

set -e

echo "=== HPA 本地部署脚本 ==="
echo "支持 Kubernetes 版本: v1.23+ (当前集群: $(kubectl version --output=json 2>/dev/null | jq -r '.serverVersion.gitVersion' 2>/dev/null || echo '未知'))"

# 检查 kubectl 连接
if ! kubectl cluster-info &> /dev/null; then
    echo "错误: 无法连接到 Kubernetes 集群"
    echo "请检查 kubeconfig 配置"
    exit 1
fi

echo "✓ 集群连接正常"

echo ""
echo "=== 步骤 1: 部署 Metrics Server ==="
echo "检查 metrics-server 是否已存在..."
if kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
    echo "Metrics Server 已存在，跳过部署"
else
    echo "部署 Metrics Server (本地环境配置)..."
    kubectl apply -f metrics-server.yaml
    echo "等待 Metrics Server 就绪..."
    kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system
fi

echo ""
echo "=== 步骤 2: 验证 Metrics Server ==="
echo "检查 Metrics Server Pod 状态..."
kubectl get pods -n kube-system -l k8s-app=metrics-server

echo "等待 metrics API 可用..."
for i in {1..30}; do
    if kubectl top nodes >/dev/null 2>&1; then
        echo "✓ Metrics API 已可用"
        break
    fi
    echo "等待 metrics API 可用... ($i/30)"
    sleep 10
done

echo "显示节点资源使用情况:"
kubectl top nodes

echo ""
echo "=== 步骤 3: 部署示例应用和 HPA ==="
read -p "是否部署示例应用和 HPA 配置? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "部署示例应用和 HPA..."
    kubectl apply -f hpa-example.yaml
    
    echo "等待部署就绪..."
    kubectl wait --for=condition=available --timeout=300s deployment/nginx-hpa-demo
    
    echo "检查 HPA 状态..."
    kubectl get hpa nginx-hpa-demo
    
    echo "显示 Pod 资源使用情况:"
    kubectl top pods -l app=nginx-hpa-demo
else
    echo "跳过示例应用部署"
fi

echo ""
echo "=== 部署完成 ==="
echo "HPA 组件已成功部署到本地集群"
echo ""
echo "常用命令:"
echo "  查看 HPA 状态: kubectl get hpa"
echo "  查看 Pod 资源使用: kubectl top pods"
echo "  查看节点资源使用: kubectl top nodes"
echo "  查看 HPA 详细信息: kubectl describe hpa <hpa-name>"
echo ""
echo "下一步:"
echo "  运行负载测试: ./load-test.sh"
echo "  性能调优: ./hpa-tuning.sh"