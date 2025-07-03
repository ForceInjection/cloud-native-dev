#!/bin/bash

# HPA 部署脚本
# 用于在 Kubernetes 集群中部署 HPA 组件

set -e

echo "=== HPA 部署脚本 ==="
echo "Kubernetes 版本检查..."
kubectl version --client

# 获取服务器版本 - 使用多种方法确保兼容性
get_server_version() {
    # 方法1: 使用 kubectl version --short
    if command -v kubectl version --short &> /dev/null; then
        SERVER_VERSION=$(kubectl version --short 2>/dev/null | grep "Server Version" | awk '{print $3}' | sed 's/v//')
    fi
    
    # 方法2: 如果方法1失败，使用 kubectl version
    if [ -z "$SERVER_VERSION" ]; then
        SERVER_VERSION=$(kubectl version 2>/dev/null | grep "Server Version" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/v//')
    fi
    
    # 方法3: 使用 kubectl version -o json
    if [ -z "$SERVER_VERSION" ]; then
        SERVER_VERSION=$(kubectl version -o json 2>/dev/null | grep -o '"gitVersion":"v[0-9]\+\.[0-9]\+\.[0-9]\+"' | head -1 | cut -d'"' -f4 | sed 's/v//')
    fi
    
    # 方法4: 直接从服务器获取版本
    if [ -z "$SERVER_VERSION" ]; then
        SERVER_VERSION=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}' 2>/dev/null | sed 's/v//')
    fi
    
    # 方法5: 使用 API 版本推断
    if [ -z "$SERVER_VERSION" ]; then
        if kubectl api-versions | grep -q "autoscaling/v2" &>/dev/null; then
            SERVER_VERSION="1.23.0"
        elif kubectl api-versions | grep -q "autoscaling/v2beta2" &>/dev/null; then
            SERVER_VERSION="1.20.0"
        elif kubectl api-versions | grep -q "autoscaling/v2beta1" &>/dev/null; then
            SERVER_VERSION="1.16.0"
        else
            SERVER_VERSION="1.0.0"
        fi
    fi
}

get_server_version

# 验证版本信息是否获取成功
if [ -z "$SERVER_VERSION" ]; then
    echo "错误: 无法获取 Kubernetes 服务器版本"
    echo "请检查集群连接和权限"
    exit 1
fi

echo "检测到 Kubernetes 服务器版本: v$SERVER_VERSION"

# 版本兼容性检查
MAJOR_VERSION=$(echo $SERVER_VERSION | cut -d'.' -f1)
MINOR_VERSION=$(echo $SERVER_VERSION | cut -d'.' -f2)

# 确保版本号是整数
MAJOR_VERSION=${MAJOR_VERSION:-0}
MINOR_VERSION=${MINOR_VERSION:-0}

# 验证解析结果
if [ -z "$MAJOR_VERSION" ] || [ -z "$MINOR_VERSION" ]; then
    echo "错误: 版本解析失败"
    echo "服务器版本: $SERVER_VERSION"
    echo "解析结果: Major=$MAJOR_VERSION, Minor=$MINOR_VERSION"
    exit 1
fi

if [ "$MAJOR_VERSION" -eq 1 ] 2>/dev/null && [ "$MINOR_VERSION" -lt 20 ] 2>/dev/null; then
    echo "警告: 检测到较旧的 Kubernetes 版本 (v$SERVER_VERSION)"
    echo "建议升级到 v1.20+ 以获得最佳 HPA 体验"
    echo "当前配置已针对 v1.20+ 版本优化"
fi

echo ""
echo "=== 步骤 1: 部署 Metrics Server ==="
echo "检查 metrics-server 是否已存在..."
if kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
    echo "Metrics Server 已存在，跳过部署"
else
    # 选择合适的配置文件
    METRICS_CONFIG="metrics-server.yaml"
    
    # 检测是否为生产环境
    read -p "是否为生产环境部署? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        METRICS_CONFIG="metrics-server-production.yaml"
        echo "使用生产环境配置: $METRICS_CONFIG"
        echo "注意: 生产环境配置要求正确的TLS证书配置"
    else
        echo "使用开发/测试环境配置: $METRICS_CONFIG"
    fi
    
    if [ ! -f "$METRICS_CONFIG" ]; then
        echo "错误: 配置文件 $METRICS_CONFIG 不存在"
        exit 1
    fi
    
    echo "部署 Metrics Server..."
    kubectl apply -f "$METRICS_CONFIG"
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
        echo "Metrics API 已可用"
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
echo "HPA 组件已成功部署到集群中"
echo ""
echo "常用命令:"
echo "  查看 HPA 状态: kubectl get hpa"
echo "  查看 Pod 资源使用: kubectl top pods"
echo "  查看节点资源使用: kubectl top nodes"
echo "  查看 HPA 详细信息: kubectl describe hpa <hpa-name>"
echo "  查看 HPA 事件: kubectl get events --field-selector involvedObject.kind=HorizontalPodAutoscaler"