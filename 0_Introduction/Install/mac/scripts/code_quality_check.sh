#!/bin/bash

# 代码质量检查脚本
# 用于检查 mac 目录下的脚本是否符合编码规范

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MODULES_DIR="$PROJECT_ROOT/modules"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查结果统计
ERROR_COUNT=0
WARNING_COUNT=0

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    ((ERROR_COUNT++))
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
    ((WARNING_COUNT++))
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# 检查重复函数定义
check_duplicate_functions() {
    log_info "检查重复函数定义..."
    
    local all_functions=$(find "$MODULES_DIR" -name "*.sh" -exec grep -H "^[a-zA-Z_][a-zA-Z0-9_]*()" {} \; | 
                         sed 's/().*$//' | 
                         awk -F: '{print $2":"$1}' | 
                         sort)
    
    local duplicates=$(echo "$all_functions" | 
                      awk -F: '{print $1}' | 
                      sort | uniq -d)
    
    if [[ -n "$duplicates" ]]; then
        while read -r func; do
            if [[ -n "$func" ]]; then
                log_error "重复函数定义: $func"
                echo "$all_functions" | grep "^$func:" | sed 's/^/  位置: /'
            fi
        done <<< "$duplicates"
    else
        log_info "✓ 未发现重复函数定义"
    fi
}

# 检查未使用的函数（简化版本）
check_unused_functions() {
    log_info "检查未使用的函数..."
    
    # 获取所有函数定义
    local defined_functions=$(find "$MODULES_DIR" -name "*.sh" -exec grep -l "^[a-zA-Z_][a-zA-Z0-9_]*()" {} \; | wc -l)
    
    if [[ $defined_functions -gt 0 ]]; then
        log_info "✓ 发现 $defined_functions 个模块文件包含函数定义"
    else
        log_warning "未发现函数定义"
    fi
}

# 检查命令存在性检查的一致性
check_command_existence_consistency() {
    log_info "检查命令存在性检查的一致性..."
    
    local inconsistent_patterns=(
        "command -v.*>/dev/null 2>&1"
        "which.*>/dev/null 2>&1"
        "type.*>/dev/null 2>&1"
    )
    
    for pattern in "${inconsistent_patterns[@]}"; do
        local matches=$(find "$MODULES_DIR" -name "*.sh" -exec grep -Hn "$pattern" {} \;)
        if [[ -n "$matches" ]]; then
            log_warning "发现非标准的命令检查模式: $pattern"
            echo "$matches" | sed 's/^/  /'
            log_warning "建议使用 utils.sh 中的 command_exists 函数"
        fi
    done
}

# 检查日志函数使用的一致性
check_logging_consistency() {
    log_info "检查日志函数使用的一致性..."
    
    local inconsistent_log_patterns=(
        "echo.*\[INFO\]"
        "echo.*\[ERROR\]"
        "echo.*\[WARNING\]"
        "echo.*\[SUCCESS\]"
    )
    
    for pattern in "${inconsistent_log_patterns[@]}"; do
        local matches=$(find "$MODULES_DIR" -name "*.sh" -exec grep -Hn "$pattern" {} \;)
        if [[ -n "$matches" ]]; then
            log_warning "发现非标准的日志输出: $pattern"
            echo "$matches" | sed 's/^/  /'
            log_warning "建议使用 utils.sh 中的统一日志函数"
        fi
    done
}

# 检查重复的 Docker/Colima 状态检查
check_duplicate_status_checks() {
    log_info "检查重复的状态检查模式..."
    
    local duplicate_patterns=(
        "docker info.*>/dev/null 2>&1"
        "colima list.*grep.*awk"
        "colima status.*>/dev/null 2>&1"
    )
    
    for pattern in "${duplicate_patterns[@]}"; do
        local matches=$(find "$MODULES_DIR" -name "*.sh" -exec grep -Hn "$pattern" {} \;)
        local match_count=$(echo "$matches" | grep -c . || echo 0)
        
        if [[ $match_count -gt 1 ]]; then
            log_warning "发现重复的状态检查模式 ($match_count 次): $pattern"
            echo "$matches" | sed 's/^/  /'
            log_warning "建议使用 utils.sh 中的统一状态检查函数"
        fi
    done
}

# 检查 Shell 脚本语法
check_shell_syntax() {
    log_info "检查 Shell 脚本语法..."
    
    find "$PROJECT_ROOT" -name "*.sh" | while read -r file; do
        if ! bash -n "$file" 2>/dev/null; then
            log_error "语法错误: $file"
        fi
    done
}

# 检查文件权限
check_file_permissions() {
    log_info "检查文件权限..."
    
    find "$PROJECT_ROOT" -name "*.sh" | while read -r file; do
        if [[ ! -x "$file" ]]; then
            log_warning "脚本文件不可执行: $file"
        fi
    done
}

# 生成报告
generate_report() {
    echo ""
    echo "==================== 代码质量检查报告 ===================="
    echo "错误数量: $ERROR_COUNT"
    echo "警告数量: $WARNING_COUNT"
    echo ""
    
    if [[ $ERROR_COUNT -eq 0 && $WARNING_COUNT -eq 0 ]]; then
        log_info "✓ 代码质量检查通过！"
        return 0
    elif [[ $ERROR_COUNT -eq 0 ]]; then
        log_warning "代码质量检查完成，有 $WARNING_COUNT 个警告需要关注"
        return 0
    else
        log_error "代码质量检查失败，有 $ERROR_COUNT 个错误需要修复"
        return 1
    fi
}

# 主函数
main() {
    echo "开始代码质量检查..."
    echo "项目根目录: $PROJECT_ROOT"
    echo "模块目录: $MODULES_DIR"
    echo ""
    
    check_shell_syntax
    check_file_permissions
    check_duplicate_functions
    check_unused_functions
    check_command_existence_consistency
    check_logging_consistency
    check_duplicate_status_checks
    
    generate_report
}

# 脚本入口
main "$@"