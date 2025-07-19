#!/bin/bash

# HPA 完整部署脚本
# 适用于 Kubernetes v1.23+ 本地集群（已测试 v1.31.2+k3s1）
# 包含 Metrics Server 和 Prometheus Adapter 部署

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
    
    # 检查集群连接
    if ! kubectl cluster-info &> /dev/null; then
        log_error "无法连接到 Kubernetes 集群"
        log_info "请检查 kubeconfig 配置"
        exit 1
    fi
    
    log_success "依赖检查通过"
}

# 部署 Metrics Server
deploy_metrics_server() {
    log_info "部署 Metrics Server..."
    
    if kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
        log_warning "Metrics Server 已存在，跳过部署"
    else
        log_info "部署 Metrics Server (本地环境配置)..."
        kubectl apply -f ../configs/metrics-server/metrics-server.yaml
        log_info "等待 Metrics Server 就绪..."
        kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system
    fi
    
    log_info "检查 Metrics Server Pod 状态..."
    kubectl get pods -n kube-system -l k8s-app=metrics-server
    
    log_info "等待 metrics API 可用..."
    for i in {1..30}; do
        if kubectl top nodes >/dev/null 2>&1; then
            log_success "Metrics API 已可用"
            break
        fi
        log_info "等待 metrics API 可用... ($i/30)"
        sleep 10
    done
    
    log_info "显示节点资源使用情况:"
    kubectl top nodes
    
    log_success "Metrics Server 部署完成"
}

# 清理冲突资源
cleanup_conflicting_resources() {
    log_info "检查并清理可能的冲突资源..."
    
    # 检查是否存在非 Helm 管理的 Prometheus Adapter 部署
    if kubectl get deployment prometheus-adapter -n monitor >/dev/null 2>&1; then
        local managed_by=$(kubectl get deployment prometheus-adapter -n monitor -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null || echo "")
        if [ "$managed_by" != "Helm" ]; then
            log_warning "发现非 Helm 管理的 prometheus-adapter 部署，需要清理"
            log_info "删除现有部署以避免冲突..."
            kubectl delete deployment prometheus-adapter -n monitor
        fi
    fi
    
    # 检查是否存在非 Helm 管理的 Service
    if kubectl get service prometheus-adapter -n monitor >/dev/null 2>&1; then
        local managed_by=$(kubectl get service prometheus-adapter -n monitor -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null || echo "")
        if [ "$managed_by" != "Helm" ]; then
            log_warning "发现非 Helm 管理的 prometheus-adapter 服务，需要清理"
            log_info "删除现有服务以避免冲突..."
            kubectl delete service prometheus-adapter -n monitor
        fi
    fi
    
    # 检查是否存在非 Helm 管理的 APIService
    if kubectl get apiservice v1beta1.custom.metrics.k8s.io >/dev/null 2>&1; then
        local managed_by=$(kubectl get apiservice v1beta1.custom.metrics.k8s.io -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null || echo "")
        if [ "$managed_by" != "Helm" ]; then
            log_warning "发现非 Helm 管理的自定义指标 APIService，需要清理"
            log_info "删除现有 APIService 以避免冲突..."
            kubectl delete apiservice v1beta1.custom.metrics.k8s.io
        fi
    fi
    
    log_success "冲突资源清理完成"
}

# 准备自定义 ConfigMap
prepare_custom_configmap() {
    log_info "准备自定义 Prometheus Adapter ConfigMap..."
    
    # 检查配置文件是否存在
    local config_file="../configs/prometheus-adapter/prometheus-adapter-springboot-config.yaml"
    if [ ! -f "$config_file" ]; then
        log_error "配置文件 $config_file 不存在"
        exit 1
    fi
    
    # 创建 monitor 命名空间（如果不存在）
    kubectl create namespace monitor --dry-run=client -o yaml | kubectl apply -f -
    
    # 检查是否存在非 Helm 管理的 ConfigMap
    if kubectl get configmap prometheus-adapter -n monitor >/dev/null 2>&1; then
        local managed_by=$(kubectl get configmap prometheus-adapter -n monitor -o jsonpath='{.metadata.labels.app\.kubernetes\.io/managed-by}' 2>/dev/null || echo "")
        if [ "$managed_by" != "Helm" ]; then
            log_warning "发现非 Helm 管理的 prometheus-adapter ConfigMap，需要清理"
            log_info "删除现有 ConfigMap 以避免冲突..."
            kubectl delete configmap prometheus-adapter -n monitor
        else
            log_info "ConfigMap 已由 Helm 管理，跳过创建"
            return 0
        fi
    fi
    
    # 创建自定义 ConfigMap
    log_info "创建自定义 Prometheus Adapter ConfigMap..."
    kubectl apply -f ../configs/prometheus-adapter/prometheus-adapter-springboot-config.yaml
    
    log_success "ConfigMap 准备完成"
}

# 部署 Prometheus Adapter
deploy_prometheus_adapter() {
    log_info "部署 Prometheus Adapter..."
    
    # 检查 helm
    if ! command -v helm &> /dev/null; then
        log_error "helm 未安装或不在 PATH 中"
        log_info "请安装 Helm: https://helm.sh/docs/intro/install/"
        return 1
    fi
    
    # 检查 values.yaml 文件是否存在
    if [ ! -f "../configs/prometheus-adapter/prometheus-adapter-values.yaml" ]; then
        log_error "prometheus-adapter-values.yaml 文件不存在"
        return 1
    fi
    
    # 添加 Helm 仓库（使用指定的镜像仓库）
    log_info "添加 Prometheus Community Helm 仓库..."
    helm repo add prometheus-community "https://helm-charts.itboon.top/prometheus-community" --force-update
    helm repo update
    
    # 创建命名空间
    kubectl create namespace monitor --dry-run=client -o yaml | kubectl apply -f -
    
    # 检查是否已经安装
    if helm list -n monitor | grep -q prometheus-adapter; then
        log_warning "Prometheus Adapter 已存在，是否要升级? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            log_info "升级 Prometheus Adapter..."
            helm upgrade prometheus-adapter prometheus-community/prometheus-adapter \
                --namespace monitor \
                --values ../configs/prometheus-adapter/prometheus-adapter-values.yaml
        else
            log_info "跳过 Prometheus Adapter 部署"
            return 0
        fi
    else
        log_info "安装 Prometheus Adapter..."
        helm install prometheus-adapter prometheus-community/prometheus-adapter \
            --namespace monitor \
            --values ../configs/prometheus-adapter/prometheus-adapter-values.yaml
    fi
    
    # 等待部署完成
    log_info "等待 Prometheus Adapter 部署完成..."
    kubectl wait --for=condition=available --timeout=300s deployment/prometheus-adapter -n monitor
    
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
        log_warning "自定义指标 API 服务未注册"
        return 1
    fi
    
    # 检查 API 可用性
    if kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1" &> /dev/null; then
        log_success "自定义指标 API 可用"
    else
        log_warning "自定义指标 API 暂时不可用，可能需要等待更长时间"
        return 1
    fi
}

# 显示使用说明
show_usage() {
    echo ""
    echo "=========================================="
    log_success "HPA 环境准备完成！"
    echo "=========================================="
    echo ""
    
    log_info "已部署组件:"
    echo "✓ Metrics Server - 提供基础资源指标 (CPU/内存)"
    if kubectl get deployment prometheus-adapter -n monitor >/dev/null 2>&1; then
        echo "✓ Prometheus Adapter - 提供自定义指标支持"
    fi
    echo ""
    
    log_info "环境验证命令:"
    echo "  查看 Metrics Server 状态: kubectl get pods -n kube-system -l k8s-app=metrics-server"
    echo "  查看节点资源使用: kubectl top nodes"
    echo "  查看 Pod 资源使用: kubectl top pods"
    echo ""
    
    if kubectl get apiservices v1beta1.custom.metrics.k8s.io &> /dev/null; then
        log_info "自定义指标 API 验证命令:"
        echo "  查看可用指标: kubectl get --raw \"/apis/custom.metrics.k8s.io/v1beta1\""
        echo "  查看 Pod 级别指标: kubectl get --raw \"/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second\""
        echo "  查看 Namespace 级别指标: kubectl get --raw \"/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/http_requests_per_second_by_app\""
        echo ""
    fi
    
    log_info "下一步 - HPA 演示:"
    echo "  1. 部署基础资源指标 HPA:"
    echo "     kubectl apply -f ../examples/hpa-basic-resource-metrics.yaml"
    echo ""
    echo "  2. 部署 Pod 级别自定义指标 HPA (需要 Prometheus Adapter):"
    echo "     kubectl apply -f ../examples/hpa-pod-level-custom-metrics.yaml"
    echo ""
    echo "  3. 部署 Namespace 级别自定义指标 HPA (需要 Prometheus Adapter):"
    echo "     kubectl apply -f ../examples/hpa-namespace-level-custom-metrics.yaml"
    echo ""
    echo "  4. 运行负载测试验证 HPA 功能:"
    echo "     ./load-test.sh"
    echo ""
    echo "  5. 性能调优 (可选):"
    echo "     ./hpa-tuning.sh"
    echo ""
    
    log_info "注意事项:"
    echo "- 确保目标应用 prometheus-test-demo 已部署"
    echo "- 确保应用 Pod 设置了资源请求 (requests)"
    echo "- 自定义指标需要应用暴露 Prometheus 指标"
    echo "- 根据实际环境调整 HPA 配置中的阈值"
    echo ""
    
    log_info "验证部署:"
    echo "  运行验证脚本: ./validate-hpa-deployment.sh"
}

# 主函数
main() {
    echo "=========================================="
    echo "  HPA 环境准备脚本"
    echo "  支持 Kubernetes v1.23+"
    echo "  当前集群: $(kubectl version --output=json 2>/dev/null | jq -r '.serverVersion.gitVersion' 2>/dev/null || echo '未知')"
    echo "=========================================="
    echo ""
    
    check_dependencies
    
    echo ""
    log_info "=== 步骤 1: 部署 Metrics Server ==="
    deploy_metrics_server
    
    echo ""
    log_info "=== 步骤 2: 部署 Prometheus Adapter (可选) ==="
    read -p "是否部署 Prometheus Adapter 以支持自定义指标? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup_conflicting_resources
        if deploy_prometheus_adapter; then
            verify_custom_metrics_api
        else
            log_warning "Prometheus Adapter 部署失败，跳过自定义指标验证"
        fi
    else
        log_info "跳过 Prometheus Adapter 部署"
    fi
    
    show_usage
}

# 执行主函数
main "$@"