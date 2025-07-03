#!/bin/bash

# Kubernetes HPA 兼容性检查脚本
# 检查当前 K8s 版本并推荐合适的配置

# 是否启用调试模式
DEBUG=0
if [ "$1" = "--debug" ]; then
    DEBUG=1
    echo "调试模式已启用"
fi

# 调试输出函数
debug_log() {
    if [ $DEBUG -eq 1 ]; then
        echo "[DEBUG] $1"
    fi
}

set -e

echo "=== Kubernetes HPA 兼容性检查 ==="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 命令未找到，请先安装 kubectl"
    exit 1
fi

# 检查集群连接
if ! kubectl cluster-info &> /dev/null; then
    echo "错误: 无法连接到 Kubernetes 集群"
    echo "请检查 kubeconfig 配置"
    exit 1
fi

echo "✓ kubectl 可用，集群连接正常"

# 获取版本信息
echo ""
echo "=== 版本信息 ==="

# 尝试多种方式获取版本信息
get_version() {
    debug_log "开始获取 Kubernetes 版本信息"
    
    # 方法1: 使用 kubectl version --short
    debug_log "尝试方法1: kubectl version --short"
    if command -v kubectl version --short &> /dev/null; then
        local raw_output=$(kubectl version --short 2>&1)
        debug_log "方法1原始输出: $raw_output"
        SERVER_VERSION=$(echo "$raw_output" | grep "Server Version" | awk '{print $3}' | sed 's/v//')
        CLIENT_VERSION=$(echo "$raw_output" | grep "Client Version" | awk '{print $3}' | sed 's/v//')
        debug_log "方法1结果: SERVER=$SERVER_VERSION, CLIENT=$CLIENT_VERSION"
    fi
    
    # 方法2: 如果方法1失败，使用 kubectl version
    if [ -z "$SERVER_VERSION" ]; then
        debug_log "尝试方法2: kubectl version"
        local raw_output=$(kubectl version 2>&1)
        debug_log "方法2原始输出: $raw_output"
        SERVER_VERSION=$(echo "$raw_output" | grep "Server Version" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/v//')
        CLIENT_VERSION=$(echo "$raw_output" | grep "Client Version" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | sed 's/v//')
        debug_log "方法2结果: SERVER=$SERVER_VERSION, CLIENT=$CLIENT_VERSION"
    fi
    
    # 方法3: 使用 kubectl version -o json
    if [ -z "$SERVER_VERSION" ]; then
        debug_log "尝试方法3: kubectl version -o json"
        local raw_server_output=$(kubectl version -o json 2>&1)
        local raw_client_output=$(kubectl version --client -o json 2>&1)
        debug_log "方法3原始输出(服务器): $raw_server_output"
        debug_log "方法3原始输出(客户端): $raw_client_output"
        SERVER_VERSION=$(echo "$raw_server_output" | grep -o '"gitVersion":"v[0-9]\+\.[0-9]\+\.[0-9]\+"' | head -1 | cut -d'"' -f4 | sed 's/v//')
        CLIENT_VERSION=$(echo "$raw_client_output" | grep -o '"gitVersion":"v[0-9]\+\.[0-9]\+\.[0-9]\+"' | cut -d'"' -f4 | sed 's/v//')
        debug_log "方法3结果: SERVER=$SERVER_VERSION, CLIENT=$CLIENT_VERSION"
    fi
    
    # 方法4: 直接从服务器获取版本
    if [ -z "$SERVER_VERSION" ]; then
        debug_log "尝试方法4: kubectl get nodes"
        local raw_output=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}' 2>&1)
        debug_log "方法4原始输出: $raw_output"
        SERVER_VERSION=$(echo "$raw_output" | sed 's/v//')
        debug_log "方法4结果: SERVER=$SERVER_VERSION"
    fi
    
    # 方法5: 使用 kubectl api-versions 作为最后的尝试
    if [ -z "$SERVER_VERSION" ]; then
        debug_log "尝试方法5: 使用 kubectl api-versions 推断版本"
        if kubectl api-versions | grep -q "autoscaling/v2" &>/dev/null; then
            debug_log "检测到 autoscaling/v2 API，推断为 v1.23+"
            SERVER_VERSION="1.23.0"
        elif kubectl api-versions | grep -q "autoscaling/v2beta2" &>/dev/null; then
            debug_log "检测到 autoscaling/v2beta2 API，推断为 v1.20+"
            SERVER_VERSION="1.20.0"
        elif kubectl api-versions | grep -q "autoscaling/v2beta1" &>/dev/null; then
            debug_log "检测到 autoscaling/v2beta1 API，推断为 v1.16+"
            SERVER_VERSION="1.16.0"
        else
            debug_log "无法推断版本，使用默认值"
            SERVER_VERSION="1.0.0"
        fi
    fi
    
    debug_log "最终版本信息: SERVER=$SERVER_VERSION, CLIENT=$CLIENT_VERSION"
}

get_version

echo "客户端版本: v$CLIENT_VERSION"
echo "服务器版本: v$SERVER_VERSION"

# 验证版本信息是否获取成功
if [ -z "$SERVER_VERSION" ]; then
    echo "错误: 无法获取 Kubernetes 服务器版本"
    echo "请检查集群连接和权限"
    exit 1
fi

# 解析版本号
SERVER_MAJOR=$(echo $SERVER_VERSION | cut -d'.' -f1)
SERVER_MINOR=$(echo $SERVER_VERSION | cut -d'.' -f2)
SERVER_PATCH=$(echo $SERVER_VERSION | cut -d'.' -f3)

# 验证解析结果
if [ -z "$SERVER_MAJOR" ] || [ -z "$SERVER_MINOR" ]; then
    echo "错误: 版本解析失败"
    echo "服务器版本: $SERVER_VERSION"
    echo "解析结果: Major=$SERVER_MAJOR, Minor=$SERVER_MINOR, Patch=$SERVER_PATCH"
    exit 1
fi

echo ""
echo "=== 兼容性分析 ==="

# HPA 功能检查
# 确保版本号是整数
SERVER_MAJOR=${SERVER_MAJOR:-0}
SERVER_MINOR=${SERVER_MINOR:-0}
SERVER_PATCH=${SERVER_PATCH:-0}

# 调试信息
echo "解析版本: Major=$SERVER_MAJOR, Minor=$SERVER_MINOR, Patch=$SERVER_PATCH"

if [ "$SERVER_MAJOR" -eq 1 ] 2>/dev/null; then
    if [ "$SERVER_MINOR" -ge 25 ] 2>/dev/null; then
        echo "✓ HPA v2 API: 完全支持"
        echo "✓ 多指标支持: 完全支持"
        echo "✓ 扩缩容行为配置: 完全支持"
        RECOMMENDED_METRICS_VERSION="v0.6.4"
        COMPATIBILITY_LEVEL="excellent"
    elif [ "$SERVER_MINOR" -ge 23 ] 2>/dev/null; then
        echo "✓ HPA v2 API: 支持"
        echo "✓ 多指标支持: 支持"
        echo "✓ 扩缩容行为配置: 支持"
        RECOMMENDED_METRICS_VERSION="v0.6.4"
        COMPATIBILITY_LEVEL="good"
    elif [ "$SERVER_MINOR" -ge 20 ] 2>/dev/null; then
        echo "✓ HPA v2 API: 支持"
        echo "⚠ 多指标支持: 部分支持"
        echo "⚠ 扩缩容行为配置: 部分支持"
        RECOMMENDED_METRICS_VERSION="v0.5.2"
        COMPATIBILITY_LEVEL="fair"
    else
        echo "⚠ HPA v2 API: 有限支持"
        echo "✗ 多指标支持: 不支持"
        echo "✗ 扩缩容行为配置: 不支持"
        RECOMMENDED_METRICS_VERSION="v0.4.6"
        COMPATIBILITY_LEVEL="limited"
    fi
else
    echo "✗ 不支持的 Kubernetes 版本"
    COMPATIBILITY_LEVEL="unsupported"
fi

echo ""
echo "=== 推荐配置 ==="

case $COMPATIBILITY_LEVEL in
    "excellent")
        echo "🟢 兼容性等级: 优秀"
        echo "推荐使用: metrics-server-production.yaml (生产环境)"
        echo "推荐使用: metrics-server.yaml (开发/测试环境)"
        echo "Metrics Server 版本: $RECOMMENDED_METRICS_VERSION"
        ;;
    "good")
        echo "🟡 兼容性等级: 良好"
        echo "推荐使用: metrics-server-production.yaml (生产环境)"
        echo "推荐使用: metrics-server.yaml (开发/测试环境)"
        echo "Metrics Server 版本: $RECOMMENDED_METRICS_VERSION"
        echo "注意: 某些高级功能可能需要升级 K8s 版本"
        ;;
    "fair")
        echo "🟠 兼容性等级: 一般"
        echo "推荐使用: metrics-server.yaml (需要调整配置)"
        echo "Metrics Server 版本: $RECOMMENDED_METRICS_VERSION"
        echo "建议: 升级到 K8s v1.23+ 以获得更好支持"
        ;;
    "limited")
        echo "🔴 兼容性等级: 有限"
        echo "推荐使用: 简化的 HPA 配置"
        echo "Metrics Server 版本: $RECOMMENDED_METRICS_VERSION"
        echo "强烈建议: 升级到 K8s v1.20+ 版本"
        ;;
    "unsupported")
        echo "❌ 兼容性等级: 不支持"
        echo "请升级 Kubernetes 到 v1.16+ 版本"
        exit 1
        ;;
esac

echo ""
echo "=== 环境检查 ==="

# 检查是否已安装 metrics-server
if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    echo "✓ Metrics Server 已安装"
    CURRENT_IMAGE=$(kubectl get deployment metrics-server -n kube-system -o jsonpath='{.spec.template.spec.containers[0].image}')
    echo "当前版本: $CURRENT_IMAGE"
else
    echo "⚠ Metrics Server 未安装"
fi

# 检查 HPA 控制器
if kubectl get pods -n kube-system -l component=kube-controller-manager &> /dev/null; then
    echo "✓ HPA 控制器可用"
else
    echo "⚠ 无法确认 HPA 控制器状态"
fi

echo ""
echo "=== 部署建议 ==="

if [ "$SERVER_MINOR" -ge 23 ] 2>/dev/null; then
    echo "1. 运行 ./deploy-hpa.sh 进行自动部署"
    echo "2. 选择生产环境配置以获得最佳安全性"
    echo "3. 确保集群节点有足够资源"
else
    echo "1. 考虑升级 Kubernetes 版本"
    echo "2. 使用简化的 HPA 配置"
    echo "3. 仔细测试扩缩容功能"
fi

echo ""
echo "=== 检查完成 ==="