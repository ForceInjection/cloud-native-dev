#!/bin/bash

# HPA 快速启动脚本
# 提供便捷的命令入口，适配新的目录结构

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 显示帮助信息
show_help() {
    echo "HPA 快速启动脚本"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  deploy              - 部署 HPA 环境（Metrics Server + Prometheus Adapter）"
    echo "  deploy-basic        - 仅部署 Metrics Server"
    echo "  validate            - 验证 HPA 部署状态"
    echo "  load-test           - 运行负载测试"
    echo "  tune                - 运行性能调优"
    echo "  check               - 检查环境兼容性"
    echo "  apply-basic-hpa     - 部署基础资源指标 HPA 示例"
    echo "  apply-custom-hpa    - 部署自定义指标 HPA 示例"
    echo "  clean               - 清理 HPA 资源"
    echo "  help                - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 deploy           # 完整部署 HPA 环境"
    echo "  $0 validate         # 验证部署状态"
    echo "  $0 load-test        # 运行负载测试"
}

# 执行命令
case "$1" in
    "deploy")
        echo -e "${BLUE}[INFO]${NC} 开始部署 HPA 环境..."
        cd scripts && ./deploy-hpa.sh
        ;;
    "deploy-basic")
        echo -e "${BLUE}[INFO]${NC} 仅部署 Metrics Server..."
        cd scripts && ./deploy-hpa.sh --metrics-only
        ;;
    "validate")
        echo -e "${BLUE}[INFO]${NC} 验证 HPA 部署状态..."
        cd scripts && ./validate-hpa-deployment.sh
        ;;
    "load-test")
        echo -e "${BLUE}[INFO]${NC} 运行负载测试..."
        cd scripts && ./load-test.sh
        ;;
    "tune")
        echo -e "${BLUE}[INFO]${NC} 运行性能调优..."
        cd scripts && ./hpa-tuning.sh
        ;;
    "check")
        echo -e "${BLUE}[INFO]${NC} 检查环境兼容性..."
        cd scripts && ./check-compatibility.sh
        ;;
    "apply-basic-hpa")
        echo -e "${BLUE}[INFO]${NC} 部署基础资源指标 HPA 示例..."
        kubectl apply -f examples/hpa-basic-resource-metrics.yaml
        echo -e "${GREEN}[SUCCESS]${NC} 基础 HPA 已部署"
        ;;
    "apply-custom-hpa")
        echo -e "${BLUE}[INFO]${NC} 部署自定义指标 HPA 示例..."
        kubectl apply -f examples/hpa-pod-level-custom-metrics.yaml
        kubectl apply -f examples/hpa-namespace-level-custom-metrics.yaml
        echo -e "${GREEN}[SUCCESS]${NC} 自定义指标 HPA 已部署"
        ;;
    "clean")
        echo -e "${YELLOW}[WARNING]${NC} 清理 HPA 资源..."
        echo "这将删除所有 HPA 相关资源，是否继续? (y/N)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            # 清理 HPA 示例
            kubectl delete -f examples/ --ignore-not-found=true
            # 清理 Prometheus Adapter
            helm uninstall prometheus-adapter -n monitor --ignore-not-found
            # 清理 Metrics Server
            kubectl delete -f configs/metrics-server/metrics-server.yaml --ignore-not-found=true
            echo -e "${GREEN}[SUCCESS]${NC} HPA 资源已清理"
        else
            echo "取消清理操作"
        fi
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo -e "${YELLOW}[WARNING]${NC} 未知命令: $1"
        echo ""
        show_help
        exit 1
        ;;
esac