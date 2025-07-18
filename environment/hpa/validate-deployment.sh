#!/bin/bash

# HPA 部署验证脚本
# 用于在本地环境验证所有 HPA 相关脚本和配置的正确性

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

# 验证结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试结果记录
test_result() {
    local test_name="$1"
    local result="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        log_success "✓ $test_name"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        log_error "✗ $test_name"
    fi
}

echo "=== HPA 部署验证脚本 ==="
echo "验证时间: $(date)"
echo "验证环境: 本地 Kubernetes 集群"
echo ""

# 1. 环境检查
log_info "1. 检查环境依赖..."

# 检查 kubectl
if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | grep "Client Version" || echo "Unknown")
    test_result "kubectl 命令可用 ($KUBECTL_VERSION)" "PASS"
else
    test_result "kubectl 命令可用" "FAIL"
fi

# 检查集群连接
if kubectl cluster-info &> /dev/null; then
    CLUSTER_INFO=$(kubectl cluster-info | head -1)
    test_result "Kubernetes 集群连接正常" "PASS"
    log_info "  集群信息: $CLUSTER_INFO"
else
    test_result "Kubernetes 集群连接正常" "FAIL"
    log_warning "  请确保 Kubernetes 集群正在运行并且 kubeconfig 配置正确"
fi

# 检查集群版本
if kubectl version --short &> /dev/null; then
    SERVER_VERSION=$(kubectl version --short 2>/dev/null | grep "Server Version" | awk '{print $3}' || echo "Unknown")
    if [[ "$SERVER_VERSION" == *"v1.23"* ]]; then
        test_result "Kubernetes 版本兼容 ($SERVER_VERSION)" "PASS"
    else
        test_result "Kubernetes 版本兼容 ($SERVER_VERSION)" "FAIL"
        log_warning "  推荐使用 Kubernetes v1.23.17，当前版本可能存在兼容性问题"
    fi
else
    test_result "Kubernetes 版本检查" "FAIL"
fi

echo ""

# 2. 文件完整性检查
log_info "2. 检查文件完整性..."

# 必需文件列表
REQUIRED_FILES=(
    "README.md"
    "IMAGE_ACCELERATION.md"
    "metrics-server.yaml"
    "hpa-example.yaml"
    "hpa-custom-metrics-example.yaml"
    "deploy-hpa.sh"
    "deploy-custom-metrics.sh"
    "load-test.sh"
    "hpa-tuning.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        test_result "文件存在: $file" "PASS"
    else
        test_result "文件存在: $file" "FAIL"
    fi
done

# 检查脚本可执行权限
SCRIPT_FILES=(
    "deploy-hpa.sh"
    "deploy-custom-metrics.sh"
    "load-test.sh"
    "hpa-tuning.sh"
)

for script in "${SCRIPT_FILES[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        test_result "脚本可执行: $script" "PASS"
    elif [ -f "$script" ]; then
        test_result "脚本可执行: $script" "FAIL"
        log_warning "  运行: chmod +x $script"
    else
        test_result "脚本可执行: $script" "FAIL"
    fi
done

echo ""

# 3. YAML 配置验证
log_info "3. 验证 YAML 配置文件..."

YAML_FILES=(
    "metrics-server.yaml"
    "hpa-example.yaml"
    "hpa-custom-metrics-example.yaml"
)

for yaml_file in "${YAML_FILES[@]}"; do
    if [ -f "$yaml_file" ]; then
        if kubectl apply --dry-run=client -f "$yaml_file" &> /dev/null; then
            test_result "YAML 语法正确: $yaml_file" "PASS"
        else
            test_result "YAML 语法正确: $yaml_file" "FAIL"
            log_error "  请检查 $yaml_file 的语法错误"
        fi
    fi
done

# 检查镜像配置
log_info "4. 检查镜像配置..."

# 检查是否使用了镜像加速
if grep -q "docker.m.daocloud.io" hpa-example.yaml 2>/dev/null; then
    test_result "hpa-example.yaml 使用镜像加速" "PASS"
else
    test_result "hpa-example.yaml 使用镜像加速" "FAIL"
fi

if grep -q "k8s.m.daocloud.io" metrics-server.yaml 2>/dev/null; then
    test_result "metrics-server.yaml 使用镜像加速" "PASS"
else
    test_result "metrics-server.yaml 使用镜像加速" "FAIL"
fi

echo ""

# 5. 脚本语法检查
log_info "5. 检查脚本语法..."

for script in "${SCRIPT_FILES[@]}"; do
    if [ -f "$script" ]; then
        if bash -n "$script" 2>/dev/null; then
            test_result "脚本语法正确: $script" "PASS"
        else
            test_result "脚本语法正确: $script" "FAIL"
            log_error "  请检查 $script 的语法错误"
        fi
    fi
done

echo ""

# 6. 模拟部署测试（可选）
log_info "6. 模拟部署测试..."

read -p "是否执行模拟部署测试？这将在集群中创建临时资源 (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "开始模拟部署测试..."
    
    # 测试 Metrics Server 部署
    if kubectl apply --dry-run=server -f metrics-server.yaml &> /dev/null; then
        test_result "Metrics Server 配置可部署" "PASS"
    else
        test_result "Metrics Server 配置可部署" "FAIL"
    fi
    
    # 测试示例应用部署
    if kubectl apply --dry-run=server -f hpa-example.yaml &> /dev/null; then
        test_result "HPA 示例配置可部署" "PASS"
    else
        test_result "HPA 示例配置可部署" "FAIL"
    fi
    
    # 测试自定义指标配置
    if kubectl apply --dry-run=server -f hpa-custom-metrics-example.yaml &> /dev/null; then
        test_result "自定义指标配置可部署" "PASS"
    else
        test_result "自定义指标配置可部署" "FAIL"
    fi
else
    log_info "跳过模拟部署测试"
fi

echo ""

# 7. 网络连通性测试
log_info "7. 测试镜像源连通性..."

# 测试 DaoCloud 镜像源连通性
if curl -s --connect-timeout 5 https://docker.m.daocloud.io/v2/ > /dev/null; then
    test_result "DaoCloud Docker 镜像源连通" "PASS"
else
    test_result "DaoCloud Docker 镜像源连通" "FAIL"
    log_warning "  网络可能存在问题，可能影响镜像拉取速度"
fi

if curl -s --connect-timeout 5 https://k8s.m.daocloud.io/v2/ > /dev/null; then
    test_result "DaoCloud K8s 镜像源连通" "PASS"
else
    test_result "DaoCloud K8s 镜像源连通" "FAIL"
    log_warning "  网络可能存在问题，可能影响镜像拉取速度"
fi

echo ""

# 8. 生成验证报告
log_info "8. 生成验证报告..."

echo "=== 验证报告 ==="
echo "验证时间: $(date)"
echo "总测试项: $TOTAL_TESTS"
echo "通过测试: $PASSED_TESTS"
echo "失败测试: $FAILED_TESTS"
echo "成功率: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    log_success "🎉 所有验证项目都通过了！"
    log_info "您可以安全地使用这些脚本进行 HPA 部署"
    echo ""
    log_info "建议的部署顺序："
    echo "  1. ./deploy-hpa.sh          # 部署 HPA 基础组件"
    echo "  2. ./load-test.sh           # 验证 HPA 功能"
    echo "  3. ./deploy-custom-metrics.sh # (可选) 部署自定义指标支持"
    echo "  4. ./hpa-tuning.sh          # (可选) 性能调优"
else
    log_warning "⚠️  发现 $FAILED_TESTS 个问题需要解决"
    log_info "请根据上述错误信息修复问题后重新运行验证"
    echo ""
    log_info "常见问题解决方案："
    echo "  - 文件权限: chmod +x *.sh"
    echo "  - 集群连接: 检查 kubeconfig 配置"
    echo "  - YAML 语法: 使用 kubectl apply --dry-run=client -f <file>"
    echo "  - 网络问题: 检查防火墙和代理设置"
fi

echo ""
log_info "详细文档请参考: README.md"
log_info "镜像加速配置请参考: IMAGE_ACCELERATION.md"

# 保存验证结果到文件
REPORT_FILE="hpa-validation-report-$(date +%Y%m%d-%H%M%S).txt"
{
    echo "HPA 部署验证报告"
    echo "================"
    echo "验证时间: $(date)"
    echo "验证环境: $(kubectl cluster-info 2>/dev/null | head -1 || echo 'Unknown')"
    echo "总测试项: $TOTAL_TESTS"
    echo "通过测试: $PASSED_TESTS"
    echo "失败测试: $FAILED_TESTS"
    echo "成功率: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
    echo ""
    echo "验证详情请查看控制台输出"
} > "$REPORT_FILE"

log_info "验证报告已保存到: $REPORT_FILE"

exit $FAILED_TESTS