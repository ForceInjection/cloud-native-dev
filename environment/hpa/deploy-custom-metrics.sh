#!/bin/bash

# Prometheus Adapter 本地部署脚本
# 用于为 HPA 提供自定义指标支持

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

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    # 检查 kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl 未安装或不在 PATH 中"
        exit 1
    fi
    
    # 检查 helm
    if ! command -v helm &> /dev/null; then
        log_error "helm 未安装或不在 PATH 中"
        log_info "请安装 Helm: https://helm.sh/docs/intro/install/"
        exit 1
    fi
    
    # 检查集群连接
    if ! kubectl cluster-info &> /dev/null; then
        log_error "无法连接到 Kubernetes 集群"
        exit 1
    fi
    
    log_success "依赖检查通过"
}

# 部署 Prometheus Adapter
deploy_prometheus_adapter() {
    log_info "部署 Prometheus Adapter..."
    
    # 添加 Helm 仓库
    log_info "添加 Prometheus Community Helm 仓库..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # 创建命名空间
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # 检查是否已经安装
    if helm list -n monitoring | grep -q prometheus-adapter; then
        log_warning "Prometheus Adapter 已存在，是否要升级? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            log_info "升级 Prometheus Adapter..."
            helm upgrade prometheus-adapter prometheus-community/prometheus-adapter \
                --namespace monitoring \
                --set prometheus.url="http://prometheus-server.monitoring.svc.cluster.local" \
                --set prometheus.port="80" \
                --set replicas=1 \
                --set resources.requests.cpu=100m \
                --set resources.requests.memory=128Mi \
                --set resources.limits.cpu=500m \
                --set resources.limits.memory=512Mi
        else
            log_info "跳过 Prometheus Adapter 部署"
            return 0
        fi
    else
        log_info "安装 Prometheus Adapter..."
        helm install prometheus-adapter prometheus-community/prometheus-adapter \
            --namespace monitoring \
            --set prometheus.url="http://prometheus-server.monitoring.svc.cluster.local" \
            --set prometheus.port="80" \
            --set replicas=1 \
            --set resources.requests.cpu=100m \
            --set resources.requests.memory=128Mi \
            --set resources.limits.cpu=500m \
            --set resources.limits.memory=512Mi
    fi
    
    # 等待部署完成
    log_info "等待 Prometheus Adapter 部署完成..."
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus-adapter -n monitoring
    
    log_success "Prometheus Adapter 部署完成"
}

# 验证自定义指标 API
verify_custom_metrics_api() {
    log_info "验证自定义指标 API..."
    
    # 等待 API 服务注册
    sleep 30
    
    # 检查 API 服务
    if kubectl get apiservices v1beta1.custom.metrics.k8s.io &> /dev/null; then
        log_success "自定义指标 API 服务已注册"
    else
        log_error "自定义指标 API 服务未注册"
        return 1
    fi
    
    # 检查 API 可用性
    if kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" &> /dev/null; then
        log_success "自定义指标 API 可用"
    else
        log_warning "自定义指标 API 暂时不可用，可能需要等待更长时间"
    fi
}

# 部署示例配置
deploy_example() {
    log_info "是否要部署自定义指标 HPA 示例? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if [ -f "hpa-custom-metrics-example.yaml" ]; then
            log_info "部署自定义指标 HPA 示例..."
            kubectl apply -f hpa-custom-metrics-example.yaml
            log_success "示例部署完成"
            
            log_info "查看 HPA 状态:"
            kubectl get hpa web-app-custom-metrics-hpa
        else
            log_warning "示例文件 hpa-custom-metrics-example.yaml 不存在"
        fi
    fi
}

# 显示使用说明
show_usage() {
    log_info "Prometheus Adapter 部署完成！"
    echo
    log_info "使用说明:"
    echo "1. 验证自定义指标 API:"
    echo "   kubectl get apiservices | grep custom.metrics"
    echo
    echo "2. 查看可用指标:"
    echo "   kubectl get --raw \"/apis/custom.metrics.k8s.io/v1beta1\""
    echo
    echo "3. 创建基于自定义指标的 HPA:"
    echo "   参考 hpa-custom-metrics-example.yaml 文件"
    echo
    log_info "注意事项:"
    echo "- 确保 Prometheus 已部署并可访问"
    echo "- 确保应用暴露 Prometheus 指标"
    echo "- 根据实际指标名称调整 HPA 配置"
}

# 主函数
main() {
    echo "=========================================="
    echo "  Prometheus Adapter 本地部署脚本"
    echo "  用于 HPA 自定义指标支持"
    echo "=========================================="
    echo
    
    check_dependencies
    deploy_prometheus_adapter
    verify_custom_metrics_api
    deploy_example
    show_usage
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi