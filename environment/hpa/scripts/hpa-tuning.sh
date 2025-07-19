#!/bin/bash

# HPA 本地调优脚本
# 用于分析和优化本地 HPA 配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 分析 HPA 性能
analyze_hpa_performance() {
    local hpa_name=$1
    local namespace=${2:-default}
    
    log_info "分析 HPA: $hpa_name (命名空间: $namespace)"
    
    # 检查 HPA 是否存在
    if ! kubectl get hpa "$hpa_name" -n "$namespace" &>/dev/null; then
        log_error "HPA $hpa_name 在命名空间 $namespace 中不存在"
        return 1
    fi
    
    # 显示 HPA 状态
    log_info "HPA 当前状态:"
    kubectl get hpa "$hpa_name" -n "$namespace"
    
    # 显示详细信息
    log_info "HPA 详细信息:"
    kubectl describe hpa "$hpa_name" -n "$namespace"
    
    # 检查最近的扩缩容事件
    log_info "最近的扩缩容事件:"
    kubectl get events -n "$namespace" \
        --field-selector involvedObject.name="$hpa_name" \
        --sort-by='.lastTimestamp' | tail -5
}

# 生成优化建议
suggest_optimizations() {
    local hpa_name=$1
    local namespace=${2:-default}
    
    log_info "为 HPA $hpa_name 生成优化建议:"
    
    if ! kubectl get hpa "$hpa_name" -n "$namespace" &>/dev/null; then
        log_error "HPA $hpa_name 在命名空间 $namespace 中不存在"
        return 1
    fi
    
    local hpa_info=$(kubectl get hpa "$hpa_name" -n "$namespace" -o json)
    local current_replicas=$(echo "$hpa_info" | jq -r '.status.currentReplicas // 0')
    local max_replicas=$(echo "$hpa_info" | jq -r '.spec.maxReplicas')
    
    echo "优化建议:"
    echo "========="
    
    # 副本数建议
    if [ "$current_replicas" -eq "$max_replicas" ]; then
        log_warning "当前副本数已达到最大值，建议:"
        echo "  1. 增加 maxReplicas 值"
        echo "  2. 检查应用性能瓶颈"
        echo "  3. 优化资源配置"
    fi
    
    # 本地环境建议
    echo ""
    echo "本地环境优化建议:"
    echo "- 设置合理的资源请求和限制"
    echo "- 使用较小的副本数范围 (如 1-5)"
    echo "- 设置适当的 CPU 阈值 (70-80%)"
    echo "- 配置稳定窗口避免频繁扩缩容"
}

# 分析集群资源使用
analyze_resource_usage() {
    log_info "分析集群资源使用情况:"
    
    # 节点资源使用率
    log_info "节点资源使用率:"
    kubectl top nodes
    
    # Pod 资源使用率
    log_info "Pod 资源使用率 (Top 10):"
    kubectl top pods --all-namespaces --sort-by=cpu | head -11
    
    # Metrics Server 状态
    log_info "Metrics Server 状态:"
    kubectl get pods -n kube-system -l k8s-app=metrics-server
    
    # HPA 状态概览
    log_info "HPA 状态概览:"
    kubectl get hpa --all-namespaces
}

# 生成简单报告
generate_simple_report() {
    local output_file="hpa-report-$(date +%Y%m%d-%H%M%S).txt"
    
    log_info "生成简单报告: $output_file"
    
    {
        echo "HPA 本地环境分析报告"
        echo "生成时间: $(date)"
        echo "========================"
        echo
        
        echo "1. 集群节点状态"
        echo "-------------"
        kubectl get nodes
        echo
        
        echo "2. HPA 状态"
        echo "----------"
        kubectl get hpa --all-namespaces
        echo
        
        echo "3. Metrics Server 状态"
        echo "-------------------"
        kubectl get pods -n kube-system -l k8s-app=metrics-server
        echo
        
        echo "4. 资源使用情况"
        echo "-------------"
        kubectl top nodes
        echo
        
    } > "$output_file"
    
    log_success "报告已生成: $output_file"
}

# 主菜单
show_menu() {
    echo "=================================="
    echo "  HPA 本地调优工具"
    echo "=================================="
    echo "1. 分析特定 HPA 性能"
    echo "2. 生成优化建议"
    echo "3. 分析集群资源使用"
    echo "4. 生成简单报告"
    echo "5. 退出"
    echo "=================================="
}

# 主函数
main() {
    while true; do
        show_menu
        read -p "请选择操作 (1-5): " choice
        
        case $choice in
            1)
                read -p "请输入 HPA 名称: " hpa_name
                read -p "请输入命名空间 (默认: default): " namespace
                namespace=${namespace:-default}
                analyze_hpa_performance "$hpa_name" "$namespace"
                ;;
            2)
                read -p "请输入 HPA 名称: " hpa_name
                read -p "请输入命名空间 (默认: default): " namespace
                namespace=${namespace:-default}
                suggest_optimizations "$hpa_name" "$namespace"
                ;;
            3)
                analyze_resource_usage
                ;;
            4)
                generate_simple_report
                ;;
            5)
                log_info "退出工具"
                exit 0
                ;;
            *)
                log_error "无效选择，请重新输入"
                ;;
        esac
        
        echo
        read -p "按 Enter 键继续..."
        echo
    done
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi