#!/bin/bash

# Mac Docker + Colima 模块化安装脚本
# 版本: 4.0

set -e
set -o pipefail
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"
LOG_DIR="$SCRIPT_DIR/logs"
CONFIG_DIR="$SCRIPT_DIR/config"
TEMP_DIR="$(mktemp -d)"

mkdir -p "$LOG_DIR" "$CONFIG_DIR"

# 日志文件
LOG_FILE="$LOG_DIR/install.log"
ERROR_LOG="$LOG_DIR/error.log"

# 检查模块目录
check_modules() {
    if [[ ! -d "$MODULES_DIR" ]]; then
        echo "❌ 错误: 模块目录不存在: $MODULES_DIR" >&2
        exit 1
    fi

    local required_modules=(
        "utils.sh"
        "colima_driver.sh"
        "system_checks.sh"
        "registry_mirrors.sh"
        "verification.sh"
    )

    local missing_modules=()
    for module in "${required_modules[@]}"; do
        if [[ ! -f "$MODULES_DIR/$module" ]]; then
            missing_modules+=("$module")
        fi
    done

    if [[ ${#missing_modules[@]} -gt 0 ]]; then
        echo "❌ 错误: 缺少必需的模块文件:" >&2
        printf '  - %s\n' "${missing_modules[@]}" >&2
        exit 1
    fi
}

import_modules() {
    echo "📦 正在加载模块..."

    local modules=(
        "utils.sh"
        "system_checks.sh"
        "colima_driver.sh"
        "registry_mirrors.sh"
        "verification.sh"
    )

    for module in "${modules[@]}"; do
        if [[ -f "$MODULES_DIR/$module" ]]; then
            echo "  ✓ 加载: $module"
            if ! source "$MODULES_DIR/$module" 2>>"$ERROR_LOG"; then
                echo "❌ 错误: 无法加载模块 $module" >&2
                exit 1
            fi
        fi
    done

    echo "✅ 所有模块加载完成"
}

# 配置文件路径
CONFIG_FILE="$CONFIG_DIR/config.conf"

load_config_file() {
    if [[ -f "$CONFIG_FILE" ]]; then
        log_with_timestamp "INFO" "加载配置文件: $CONFIG_FILE"
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^#.*$ ]] || [[ -z "$key" ]] && continue
            if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
                # 去除注释部分（# 及其后面的内容）
                value=$(echo "$value" | sed 's/#.*$//' | xargs)
                eval "$key='$value'"
            fi
        done <"$CONFIG_FILE"
    fi
}



# 全局变量和配置
COLIMA_MEMORY=${COLIMA_MEMORY:-2048}
COLIMA_DISK_SIZE=${COLIMA_DISK_SIZE:-20000}
COLIMA_CPU_COUNT=${COLIMA_CPU_COUNT:-2}
SKIP_TESTS=${SKIP_TESTS:-false}
VERBOSE=${VERBOSE:-false}
DRY_RUN=${DRY_RUN:-false}
FORCE_REINSTALL=${FORCE_REINSTALL:-false}
QUIET_MODE=${QUIET_MODE:-false}
AUTO_CONFIRM=${AUTO_CONFIRM:-false}
ENABLE_KUBERNETES=${ENABLE_KUBERNETES:-false}
ENABLE_CLEANUP=${ENABLE_CLEANUP:-false}
VIRTUALIZATION_ENGINE="colima"
COLIMA_VM_NAME="default"
REQUIRED_MEMORY_GB=4
REQUIRED_DISK_SPACE_GB=20

# 脚本元数据
SCRIPT_VERSION="4.0"
SCRIPT_NAME="Mac Docker + Colima 模块化安装脚本"
MIN_MACOS_VERSION="10.15"

# 显示帮助信息
show_help() {
    cat <<EOF
🐳 $SCRIPT_NAME v$SCRIPT_VERSION
在 macOS 上安装和配置 Docker + Colima 环境的智能化工具

📋 用法: $0 [选项]

🔧 基本选项:
  -h, --help              显示此帮助信息
  -v, --verbose           启用详细输出模式
  -q, --quiet             启用静默模式
  -y, --yes               自动确认所有提示
  -f, --force             强制重新安装
  -k, --kubernetes        启用 Kubernetes 支持
  --dry-run               模拟运行模式（仅显示将要执行的操作，不实际执行）
  --cleanup               执行系统清理操作（清理临时文件、缓存等）

⚙️  虚拟机配置:
  -m, --memory SIZE       设置虚拟机内存大小（MB，默认: 2048）
  -c, --cpu-count COUNT   设置虚拟机CPU核心数（默认: 2）
  -D, --disk-size SIZE    设置虚拟机磁盘大小（MB，默认: 20000）

🎯 操作模式:
  --system-check-only     仅运行系统兼容性检查
  --install-only          仅安装 Docker 组件
  --verify-only           仅运行安装验证测试
  --uninstall             完全卸载 Docker 环境

📚 使用示例:
  $0                           # 完整安装流程
  $0 -v                        # 详细输出模式安装
  $0 -k                        # 安装 Docker + Kubernetes
  $0 --dry-run                 # 模拟运行，预览将要执行的操作
  $0 --system-check-only       # 仅检查系统兼容性
  $0 --cleanup                 # 执行系统清理操作
  $0 --uninstall               # 完全卸载

EOF
}

validate_arguments() {
    if [[ ! "$COLIMA_MEMORY" =~ ^[0-9]+$ ]] || [[ "$COLIMA_MEMORY" -lt 1024 ]]; then
        echo "❌ 错误: 内存大小必须是数字且不少于1024MB" >&2
        exit 1
    fi

    if [[ ! "$COLIMA_CPU_COUNT" =~ ^[0-9]+$ ]] || [[ "$COLIMA_CPU_COUNT" -lt 1 ]]; then
        echo "❌ 错误: CPU核心数必须是正整数" >&2
        exit 1
    fi

    if [[ ! "$COLIMA_DISK_SIZE" =~ ^[0-9]+$ ]] || [[ "$COLIMA_DISK_SIZE" -lt 10000 ]]; then
        echo "❌ 错误: 磁盘大小必须是数字且不少于10000MB" >&2
        exit 1
    fi

    # 验证操作模式相关的参数
    # 当前支持的操作模式不需要额外的文件验证
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
        -h | --help)
            show_help
            exit 0
            ;;
        -v | --verbose)
            VERBOSE=true
            shift
            ;;
        -q | --quiet)
            QUIET_MODE=true
            shift
            ;;
        -y | --yes)
            AUTO_CONFIRM=true
            shift
            ;;
        -f | --force)
            FORCE_REINSTALL=true
            shift
            ;;
        -s | --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -k | --kubernetes)
            ENABLE_KUBERNETES=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --cleanup)
            OPERATION="cleanup"
            ENABLE_CLEANUP=true
            shift
            ;;
        -m | --memory)
            if [[ -z "${2:-}" ]]; then
                echo "❌ 错误: --memory 需要指定内存大小" >&2
                exit 1
            fi
            COLIMA_MEMORY="$2"
            shift 2
            ;;
        -c | --cpu-count)
            if [[ -z "${2:-}" ]]; then
                echo "❌ 错误: --cpu-count 需要指定CPU核心数" >&2
                exit 1
            fi
            COLIMA_CPU_COUNT="$2"
            shift 2
            ;;
        -D | --disk-size)
            if [[ -z "${2:-}" ]]; then
                echo "❌ 错误: --disk-size 需要指定磁盘大小" >&2
                exit 1
            fi
            COLIMA_DISK_SIZE="$2"
            shift 2
            ;;
        --system-check-only)
            OPERATION="system-check"
            shift
            ;;
        --install-only)
            OPERATION="install"
            shift
            ;;
        --verify-only)
            OPERATION="verify"
            shift
            ;;
        --uninstall)
            OPERATION="uninstall"
            shift
            ;;
        -*)
            echo "❌ 错误: 未知选项: $1" >&2
            exit 1
            ;;
        *)
            echo "❌ 错误: 不支持的参数: $1" >&2
            exit 1
            ;;
        esac
    done

    validate_arguments
}

check_system_requirements() {
    log_with_timestamp "INFO" "检查系统要求..."

    local has_error=false

    # 检查是否为 root 用户
    if is_root; then
        log_with_timestamp "ERROR" "请不要使用 root 用户运行此脚本"
        has_error=true
    fi

    if [[ "$(get_os_type)" != "macos" ]]; then
        log_with_timestamp "ERROR" "此脚本仅支持 macOS 系统"
        has_error=true
    fi

    # 检查必要的命令是否存在
    if ! command_exists brew; then
        log_with_timestamp "ERROR" "Homebrew 未安装，请先安装 Homebrew"
        has_error=true
    fi

    local os_version=$(sw_vers -productVersion)
    local major_version=$(echo "$os_version" | cut -d. -f1)
    local minor_version=$(echo "$os_version" | cut -d. -f2)

    log_with_timestamp "INFO" "当前系统版本: macOS $os_version"

    if [[ $major_version -lt 10 ]] || [[ $major_version -eq 10 && $minor_version -lt 15 ]]; then
        log_with_timestamp "ERROR" "系统版本过低，需要 macOS 10.15 或更高版本"
        has_error=true
    fi

    if ! check_system_resources "$REQUIRED_MEMORY_GB" "$REQUIRED_DISK_SPACE_GB"; then
        log_with_timestamp "WARNING" "系统资源可能不足，但将继续安装"
    fi

    local dirs_to_check=("$HOME" "$LOG_DIR" "$CONFIG_DIR")
    for dir in "${dirs_to_check[@]}"; do
        if ! check_write_permission "$dir"; then
            log_with_timestamp "ERROR" "目录权限检查失败: $dir"
            has_error=true
        fi
    done

    if ! check_essential_connectivity; then
        log_with_timestamp "WARNING" "网络连通性检查失败，可能影响安装"
    fi

    local arch=$(get_mac_arch)
    log_with_timestamp "INFO" "系统架构: $arch"

    if [[ "$has_error" == "true" ]]; then
        log_with_timestamp "ERROR" "系统要求检查失败，无法继续安装"
        return 1
    fi

    log_with_timestamp "SUCCESS" "系统要求检查通过"
    return 0
}

# 检测系统架构
detect_system_architecture() {
    local arch=$(get_mac_arch)

    log_with_timestamp "INFO" "检测到系统架构: $arch"
    log_with_timestamp "INFO" "使用 Colima 作为容器运行时"

    case "$arch" in
    "arm64")
        log_with_timestamp "INFO" "检测到 Apple Silicon (M系列) 芯片，Colima 原生支持"
        ;;
    "x86_64")
        log_with_timestamp "INFO" "检测到 Intel 芯片，Colima 完全兼容"
        ;;
    *)
        log_with_timestamp "WARNING" "未知的系统架构: $arch，但 Colima 应该仍能正常工作"
        ;;
    esac

    log_with_timestamp "SUCCESS" "系统架构检测完成，将使用 Colima"
    echo "$arch"
}

show_configuration() {
    if [[ "$QUIET_MODE" != "true" ]]; then
        echo "🔧 当前配置:"
        echo "  📊 内存: $((COLIMA_MEMORY / 1024))GB"
        echo "  🖥️  CPU核心: ${COLIMA_CPU_COUNT}"
        echo "  💾 磁盘大小: ${COLIMA_DISK_SIZE}GB"
        echo "  🚀 容器运行时: Colima"
        echo "  ☸️  Kubernetes: $([ "$ENABLE_KUBERNETES" == "true" ] && echo "启用" || echo "禁用")"
        echo
    fi

    log_with_timestamp "INFO" "配置: 内存=$((COLIMA_MEMORY / 1024))GB, CPU=${COLIMA_CPU_COUNT}, 磁盘=${COLIMA_DISK_SIZE}GB, 容器运行时=Colima, Kubernetes=$([ "$ENABLE_KUBERNETES" == "true" ] && echo "启用" || echo "禁用")"
}

run_system_check() {
    log_with_timestamp "INFO" "运行系统检查模式..."

    if run_system_checks; then
        log_with_timestamp "SUCCESS" "系统检查完成，环境满足要求"
        return 0
    else
        log_with_timestamp "ERROR" "系统检查失败，请解决问题后重试"
        return 1
    fi
}

run_installation() {
    log_with_timestamp "INFO" "运行安装模式..."

    if ! check_system_requirements; then
        log_with_timestamp "ERROR" "系统要求检查失败"
        return 1
    fi

    update_homebrew
    install_docker_with_colima

    log_with_timestamp "SUCCESS" "Docker组件安装完成"
    return 0
}



run_verification_mode() {
    log_with_timestamp "INFO" "运行验证模式..."

    if run_verification; then
        log_with_timestamp "SUCCESS" "验证完成，Docker环境正常"
        return 0
    else
        log_with_timestamp "ERROR" "验证失败，请检查安装"
        return 1
    fi
}

run_uninstallation() {
    log_with_timestamp "INFO" "开始卸载Docker环境..."

    # 调用统一的卸载函数
    uninstall_docker_components

    log_with_timestamp "SUCCESS" "Docker环境卸载完成"
    return 0
}

# 清理所有Colima实例
cleanup_all_colima_instances() {
    if command_exists colima; then
        log_info "检查所有Colima实例..."
        local all_instances=$(colima list 2>/dev/null | tail -n +2 | awk '{print $1}' || true)

        if [[ -n "$all_instances" ]]; then
            echo "$all_instances" | while read -r instance; do
                if [[ -n "$instance" ]]; then
                    if [[ "$DRY_RUN" == "true" ]]; then
                        log_with_timestamp "INFO" "[模拟] 停止并删除Colima实例: $instance"
                    else
                        log_info "停止并删除Colima实例: $instance"
                        colima stop "$instance" 2>/dev/null || true
                        colima delete "$instance" --force 2>/dev/null || true
                    fi
                fi
            done
        else
            log_info "未发现运行中的Colima实例"
        fi
        
        # 调用统一的删除函数确保彻底清理
        delete_colima_vm
    fi
}

# 卸载Docker组件
uninstall_docker_components() {
    log_info "卸载Docker组件..."

    # 停止并删除所有Colima实例
    cleanup_all_colima_instances

    # 卸载Homebrew包
    local packages=("docker" "colima")

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            log_info "卸载: $package"
            if [[ "$DRY_RUN" == "true" ]]; then
                log_with_timestamp "INFO" "[模拟] brew uninstall $package"
            else
                brew uninstall "$package" 2>/dev/null || true
            fi
        fi
    done

    # 清理配置文件
    local config_dirs=(
        "$HOME/.docker"
        "$HOME/.colima"
    )

    for config_dir in "${config_dirs[@]}"; do
        if [[ -d "$config_dir" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_with_timestamp "INFO" "[模拟] 删除配置目录: $config_dir"
            elif wait_for_confirmation "删除配置目录 $config_dir?" "y"; then
                rm -rf "$config_dir"
                log_info "已删除: $config_dir"
            fi
        fi
    done

    # 清理Shell配置
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc")

    for shell_config in "${shell_configs[@]}"; do
        if [[ -f "$shell_config" ]] && grep -q "colima" "$shell_config"; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_with_timestamp "INFO" "[模拟] 清理Shell配置: $shell_config"
            else
                log_info "清理Shell配置: $shell_config"
                sed -i.bak '/# Colima 环境变量/,/^fi$/d' "$shell_config" 2>/dev/null || true
            fi
        fi
    done

    log_success "Docker组件卸载完成"
}





run_full_installation() {
    log_with_timestamp "INFO" "开始完整安装流程..."

    show_configuration

    if ! run_system_checks; then
        log_with_timestamp "ERROR" "系统检查失败"
        return 1
    fi

    if ! update_homebrew; then
        log_with_timestamp "ERROR" "Homebrew更新失败"
        return 1
    fi

    if ! install_docker_with_colima; then
        log_with_timestamp "ERROR" "Docker安装失败"
        return 1
    fi

    if ! manage_registry_mirrors; then
        log_with_timestamp "WARNING" "镜像源配置失败，但不影响基本功能"
    fi

    log_with_timestamp "SUCCESS" "完整安装流程完成"
    return 0
}

cleanup() {
    # 只在明确启用清理时才执行清理操作
    if [[ "$ENABLE_CLEANUP" != "true" ]]; then
        # 仅清理临时目录，这是必要的
        cleanup_temp_files "$TEMP_DIR"
        return 0
    fi

    log_with_timestamp "INFO" "正在清理临时文件..."

    # 使用统一的临时文件清理函数
    cleanup_temp_files "$TEMP_DIR"

    # 清理可能的临时文件
    rm -f /tmp/docker-install-*.tmp 2>/dev/null || true
    rm -f /tmp/colima-install-*.tmp 2>/dev/null || true

    if command_exists brew; then
        brew cleanup --prune=all 2>/dev/null || true
    fi

    if command_exists docker; then
        docker system prune -f 2>/dev/null || true
    fi

    if [[ -d "$LOG_DIR" ]]; then
        find "$LOG_DIR" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    fi

    log_with_timestamp "INFO" "清理完成"
}





main() {
    check_modules
    import_modules
    setup_error_handling

    log_with_timestamp "INFO" "$SCRIPT_NAME v$SCRIPT_VERSION 启动"
    log_with_timestamp "INFO" "日志文件: $LOG_FILE"

    load_config_file
    parse_arguments "$@"

    case "${OPERATION:-full}" in
    "system-check")
        run_system_check
        ;;
    "install")
        run_installation
        ;;
    "verify")
        run_verification_mode
        ;;
    "uninstall")
        if wait_for_confirmation "确定要卸载Docker环境吗？这将删除所有相关数据" "n"; then
            run_uninstallation
        else
            log_with_timestamp "INFO" "取消卸载操作"
        fi
        ;;
    "cleanup")
        cleanup
        ;;
    "full" | *)
        run_full_installation
        ;;
    esac

    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        log_with_timestamp "SUCCESS" "操作完成!"
    else
        log_with_timestamp "ERROR" "操作失败，退出码: $exit_code"
    fi

    exit $exit_code
}

main "$@"
