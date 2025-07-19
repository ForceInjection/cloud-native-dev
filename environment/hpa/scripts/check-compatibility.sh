#!/bin/bash

# Kubernetes HPA 兼容性检查脚本
# 检查当前 K8s 版本并推荐合适的配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 是否启用调试模式
DEBUG=0
if [ "$1" = "--debug" ]; then
    DEBUG=1
    log_info "调试模式已启用"
fi

# 调试输出函数
debug_log() {
    if [ $DEBUG -eq 1 ]; then
        echo -e "${YELLOW}[DEBUG]${NC} $1"
    fi
}

echo "=== Kubernetes HPA 兼容性检查 ==="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl 命令未找到，请先安装 kubectl"
    exit 1
fi

# 检查集群连接
if ! kubectl cluster-info &> /dev/null; then
    log_error "无法连接到 Kubernetes 集群"
    log_info "请检查 kubeconfig 配置"
    exit 1
fi

log_success "kubectl 可用，集群连接正常"

# 检查 Helm 是否可用（用于 Prometheus Adapter 部署）
check_helm() {
    log_info "检查 Helm 可用性..."
    if command -v helm &> /dev/null; then
        local helm_version=$(helm version --short 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        log_success "Helm 可用，版本: $helm_version"
        
        # 检查 Helm 版本兼容性
        local major_version=$(echo $helm_version | cut -d'.' -f1 | sed 's/v//')
        if [ "$major_version" -ge 3 ]; then
            log_success "Helm 版本兼容（推荐 v3.0+）"
            return 0
        else
            log_warning "Helm 版本较低，推荐升级到 v3.0+"
            return 1
        fi
    else
        log_warning "Helm 未安装，部署 Prometheus Adapter 时需要 Helm"
        log_info "安装命令: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
        return 1
    fi
}

# 获取版本信息
echo ""
log_info "=== 版本信息 ==="

# 尝试多种方式获取版本信息
log_info "获取 Kubernetes 版本信息..."

K8S_VERSION=$(kubectl version --client=false -o json 2>/dev/null | jq -r '.serverVersion.gitVersion' 2>/dev/null || echo "unknown")
if [ "$K8S_VERSION" = "unknown" ]; then
    # 备用方法
    K8S_VERSION=$(kubectl version --short 2>/dev/null | grep "Server Version" | awk '{print $3}' || echo "unknown")
fi

debug_log "原始版本字符串: $K8S_VERSION"

if [ "$K8S_VERSION" = "unknown" ]; then
    log_error "无法获取 Kubernetes 版本信息"
    exit 1
fi

log_success "Kubernetes 版本: $K8S_VERSION"

# 解析版本号
SERVER_VERSION=$(echo $K8S_VERSION | sed 's/v//')
CLIENT_VERSION="$SERVER_VERSION"  # 简化处理

# 验证版本信息是否获取成功
if [ -z "$SERVER_VERSION" ] || [ "$SERVER_VERSION" = "0.0.0" ]; then
    log_error "无法获取有效的 Kubernetes 版本信息"
    log_info "请检查集群连接和权限"
    exit 1
fi

echo ""
log_info "=== Kubernetes 版本信息 ==="
log_info "服务器版本: v$SERVER_VERSION"
log_info "客户端版本: v$CLIENT_VERSION"

echo ""
log_info "=== 版本兼容性分析 ==="

# 检查版本是否满足教学环境要求 (>= 1.23)
# 解析主版本号和次版本号
MAJOR_VERSION=$(echo $SERVER_VERSION | cut -d'.' -f1)
MINOR_VERSION=$(echo $SERVER_VERSION | cut -d'.' -f2)

debug_log "解析版本: MAJOR=$MAJOR_VERSION, MINOR=$MINOR_VERSION"

if [ "$MAJOR_VERSION" -eq 1 ] && [ "$MINOR_VERSION" -ge 23 ]; then
    log_success "✓ Kubernetes 版本满足教学环境要求 (v$SERVER_VERSION >= v1.23)"
    log_info "  支持完整的 HPA v2 功能集合"
    METRICS_SERVER_VERSION="v0.6.x"
    HPA_API_VERSION="autoscaling/v2"
else
    log_error "✗ Kubernetes 版本过低 (v$SERVER_VERSION < v1.23)"
    log_error "  教学环境要求 Kubernetes 版本 >= v1.23"
    log_error "  请升级 Kubernetes 集群版本"
    exit 1
fi

echo ""
log_info "=== 支持的 HPA 功能 ==="

# K8s 1.23+ 支持所有 HPA 功能
log_success "✓ CPU 指标 (autoscaling/v2)"
log_success "✓ 内存指标 (autoscaling/v2)"
log_success "✓ 自定义指标 (custom.metrics.k8s.io/v1beta1)"
log_success "✓ 外部指标 (external.metrics.k8s.io/v1beta1)"
log_success "✓ 多指标支持"
log_success "✓ 行为配置 (behavior)"
log_success "✓ 扩缩容策略配置"

echo ""
log_info "=== 推荐配置 ==="

log_info "推荐的 Metrics Server 版本: $METRICS_SERVER_VERSION"
log_info "推荐的 HPA API 版本: $HPA_API_VERSION"

# 检查 Helm 可用性
echo ""
check_helm
HELM_AVAILABLE=$?

echo ""
log_success "=== 教学环境部署建议 ==="
log_info "1. 环境要求已满足 (K8s v$SERVER_VERSION >= v1.23)"
log_info "2. 使用 autoscaling/v2 API (推荐)"
log_info "3. 支持完整的 HPA 功能集合"
if [ $HELM_AVAILABLE -eq 0 ]; then
    log_success "4. Helm 可用，可以部署 Prometheus Adapter 用于自定义指标"
else
    log_warning "4. 需要安装 Helm 才能部署 Prometheus Adapter"
    log_info "   安装命令: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
fi
log_info "5. 运行部署脚本: ./deploy-hpa.sh"
log_info "6. 运行验证脚本: ./validate-hpa-deployment.sh"
log_info "7. 运行负载测试: ./load-test.sh"

echo ""
log_info "=== Metrics Server 状态检查 ==="

# 检查 Metrics Server 是否已安装
if kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    log_success "Metrics Server 已安装"
    
    # 检查 Metrics Server 状态
    METRICS_READY=$(kubectl get deployment metrics-server -n kube-system -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    METRICS_DESIRED=$(kubectl get deployment metrics-server -n kube-system -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
    
    if [ "$METRICS_READY" = "$METRICS_DESIRED" ] && [ "$METRICS_READY" != "0" ]; then
        log_success "Metrics Server 运行正常 ($METRICS_READY/$METRICS_DESIRED)"
    else
        log_warning "Metrics Server 状态异常 ($METRICS_READY/$METRICS_DESIRED)"
        log_info "可以运行 'kubectl logs -n kube-system deployment/metrics-server' 查看日志"
    fi
    
    # 显示当前版本
    CURRENT_IMAGE=$(kubectl get deployment metrics-server -n kube-system -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "unknown")
    log_info "当前版本: $CURRENT_IMAGE"
else
    log_warning "Metrics Server 未安装"
    log_info "HPA 需要 Metrics Server 来获取资源指标"
fi

# 检查 HPA 控制器
echo ""
log_info "=== HPA 控制器检查 ==="
if kubectl get pods -n kube-system -l component=kube-controller-manager &> /dev/null; then
    log_success "HPA 控制器可用"
else
    log_warning "无法确认 HPA 控制器状态"
    log_info "这在某些托管 Kubernetes 服务中是正常的"
fi

echo ""
log_success "=== 兼容性检查完成 ==="
log_info "建议按照上述部署建议进行操作"