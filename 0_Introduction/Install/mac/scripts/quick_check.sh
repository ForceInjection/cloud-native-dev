#!/bin/bash

# 快速代码质量检查脚本

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULES_DIR="$PROJECT_ROOT/modules"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=== 快速代码质量检查 ==="
echo "项目根目录: $PROJECT_ROOT"
echo "模块目录: $MODULES_DIR"
echo ""

# 检查语法
log_info "检查 Shell 脚本语法..."
syntax_errors=0
for file in "$PROJECT_ROOT"/*.sh "$MODULES_DIR"/*.sh "$PROJECT_ROOT/scripts"/*.sh; do
    if [[ -f "$file" ]]; then
        if ! bash -n "$file" 2>/dev/null; then
            log_error "语法错误: $file"
            ((syntax_errors++))
        fi
    fi
done

if [[ $syntax_errors -eq 0 ]]; then
    log_info "✓ 所有脚本语法检查通过"
else
    log_error "发现 $syntax_errors 个语法错误"
fi

# 检查重复函数
log_info "检查重复函数定义..."
duplicate_functions=$(find "$MODULES_DIR" -name "*.sh" -exec grep -H "^[a-zA-Z_][a-zA-Z0-9_]*()" {} \; | 
                     sed 's/().*$//' | 
                     awk -F: '{print $2}' | 
                     sort | uniq -d)

if [[ -n "$duplicate_functions" ]]; then
    log_warning "发现重复函数:"
    echo "$duplicate_functions" | sed 's/^/  /'
else
    log_info "✓ 未发现重复函数定义"
fi

# 检查统一函数使用
log_info "检查统一函数使用情况..."

# 检查 utils.sh 中的统一函数
utils_functions=("command_exists" "log_with_timestamp" "check_host_connectivity")
for func in "${utils_functions[@]}"; do
    usage_count=$(find "$PROJECT_ROOT" -name "*.sh" -exec grep -l "$func" {} \; | wc -l | tr -d ' ')
    if [[ $usage_count -gt 0 ]]; then
        log_info "✓ $func 被 $usage_count 个文件使用"
    else
        log_warning "$func 未被使用"
    fi
done

# 检查文件权限
log_info "检查文件权限..."
non_executable=0
for file in "$PROJECT_ROOT"/*.sh "$MODULES_DIR"/*.sh "$PROJECT_ROOT/scripts"/*.sh; do
    if [[ -f "$file" && ! -x "$file" ]]; then
        log_warning "脚本不可执行: $file"
        ((non_executable++))
    fi
done

if [[ $non_executable -eq 0 ]]; then
    log_info "✓ 所有脚本文件都可执行"
fi

echo ""
echo "=== 检查完成 ==="

if [[ $syntax_errors -eq 0 ]]; then
    log_info "✓ 快速检查通过！"
    exit 0
else
    log_error "发现问题，请修复后重新检查"
    exit 1
fi