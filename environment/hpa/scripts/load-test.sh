#!/bin/bash

# HPA 负载测试脚本
# 用于测试 HPA 自动扩缩容功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 默认配置
DEFAULT_APP_NAME="prometheus-test-demo"
DEFAULT_HPA_NAME="prometheus-test-demo-hpa"
DEFAULT_SERVICE_PORT="8998"
DEFAULT_LOAD_DURATION="300"  # 5分钟
DEFAULT_CONCURRENT_REQUESTS="4"

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl 未安装或不在 PATH 中"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "无法连接到 Kubernetes 集群"
        exit 1
    fi
    
    log_success "依赖检查通过"
}

# 检查目标应用和HPA
check_target_resources() {
    local app_name=$1
    local hpa_name=$2
    
    log_info "检查目标资源..."
    
    if ! kubectl get deployment "$app_name" >/dev/null 2>&1; then
        log_error "部署 '$app_name' 不存在"
        log_info "请先部署应用，例如: kubectl apply -f hpa-basic-resource-metrics.yaml"
        exit 1
    fi
    
    if ! kubectl get hpa "$hpa_name" >/dev/null 2>&1; then
        log_error "HPA '$hpa_name' 不存在"
        log_info "请先部署 HPA，例如: kubectl apply -f hpa-basic-resource-metrics.yaml"
        exit 1
    fi
    
    log_success "目标资源检查通过"
}

# 显示当前状态
show_current_status() {
    local app_name=$1
    local hpa_name=$2
    
    echo ""
    log_info "当前状态:"
    echo "HPA 状态:"
    kubectl get hpa "$hpa_name"
    echo ""
    echo "Pod 状态:"
    kubectl get pods -l app="$app_name"
    echo ""
}

# 运行负载测试
run_load_test() {
    local app_name=$1
    local service_port=$2
    local duration=$3
    local concurrent=$4
    
    log_info "开始负载测试..."
    log_info "目标服务: $app_name:$service_port"
    log_info "测试时长: ${duration}秒"
    log_info "并发数: $concurrent"
    
    # 创建负载测试 Pod
    kubectl run load-generator --rm -i --tty --image=busybox --restart=Never -- /bin/sh -c "
echo '负载测试启动...'
echo '目标: $app_name:$service_port'
echo '并发: $concurrent'
echo '时长: ${duration}秒'
echo ''

# 启动并发请求
for i in \$(seq 1 $concurrent); do
  (
    while true; do
      wget -q -O- http://$app_name:$service_port/ >/dev/null 2>&1 || true
      sleep 0.1
    done
  ) &
done

echo '负载测试运行中...'
sleep $duration
echo '负载测试完成'
" &

    return $!
}

# 监控HPA状态
monitor_hpa() {
    local app_name=$1
    local hpa_name=$2
    local phase=$3
    local max_checks=$4
    local interval=$5
    
    log_info "监控 HPA $phase 过程..."
    
    for i in $(seq 1 $max_checks); do
        echo "=== $phase 第 $i 次检查 ($(date '+%H:%M:%S')) ==="
        
        # HPA 状态
        kubectl get hpa "$hpa_name" --no-headers | awk '{print "HPA: " $3 " -> " $4 " (当前: " $5 ", 目标: " $6 ")"}'
        
        # Pod 数量
        local pod_count=$(kubectl get pods -l app="$app_name" --no-headers 2>/dev/null | wc -l | tr -d ' ')
        echo "Pod 数量: $pod_count"
        
        # 资源使用情况
        if kubectl top pods -l app="$app_name" >/dev/null 2>&1; then
            echo "资源使用:"
            kubectl top pods -l app="$app_name" --no-headers | awk '{print "  " $1 ": CPU=" $2 ", Memory=" $3}'
        fi
        
        echo "----------------------------------------"
        sleep $interval
    done
}

# 主函数
main() {
    echo "=========================================="
    echo "  HPA 负载测试脚本"
    echo "  支持自定义参数和智能监控"
    echo "=========================================="
    echo ""
    
    check_dependencies
    
    # 获取用户输入或使用默认值
    read -p "应用名称 (默认: $DEFAULT_APP_NAME): " app_name
    app_name=${app_name:-$DEFAULT_APP_NAME}
    
    read -p "HPA 名称 (默认: $DEFAULT_HPA_NAME): " hpa_name
    hpa_name=${hpa_name:-$DEFAULT_HPA_NAME}
    
    read -p "服务端口 (默认: $DEFAULT_SERVICE_PORT): " service_port
    service_port=${service_port:-$DEFAULT_SERVICE_PORT}
    
    read -p "负载测试时长/秒 (默认: $DEFAULT_LOAD_DURATION): " load_duration
    load_duration=${load_duration:-$DEFAULT_LOAD_DURATION}
    
    read -p "并发请求数 (默认: $DEFAULT_CONCURRENT_REQUESTS): " concurrent_requests
    concurrent_requests=${concurrent_requests:-$DEFAULT_CONCURRENT_REQUESTS}
    
    echo ""
    check_target_resources "$app_name" "$hpa_name"
    show_current_status "$app_name" "$hpa_name"
    
    # 确认开始测试
    read -p "是否开始负载测试? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "测试已取消"
        exit 0
    fi
    
    # 运行负载测试
    run_load_test "$app_name" "$service_port" "$load_duration" "$concurrent_requests"
    local load_pid=$!
    
    log_success "负载测试已启动 (PID: $load_pid)"
    
    # 监控扩容过程
    local scale_up_checks=$((load_duration / 10))
    monitor_hpa "$app_name" "$hpa_name" "扩容" "$scale_up_checks" 10
    
    # 停止负载测试
    log_info "停止负载测试..."
    kill $load_pid 2>/dev/null || true
    kubectl delete pod load-generator --ignore-not-found=true >/dev/null 2>&1
    
    # 监控缩容过程
    log_info "观察缩容过程..."
    monitor_hpa "$app_name" "$hpa_name" "缩容" 10 30
    
    # 显示最终状态
    echo ""
    log_success "负载测试完成！"
    echo "=========================================="
    show_current_status "$app_name" "$hpa_name"
    
    log_info "测试总结:"
    echo "- 应用: $app_name"
    echo "- HPA: $hpa_name"
    echo "- 测试时长: ${load_duration}秒"
    echo "- 并发数: $concurrent_requests"
    echo ""
    log_info "后续操作:"
    echo "- 查看 HPA 详情: kubectl describe hpa $hpa_name"
    echo "- 查看 HPA 事件: kubectl get events --field-selector involvedObject.name=$hpa_name"
    echo "- 持续监控: watch kubectl get hpa $hpa_name"
}

# 脚本执行入口
main "$@"