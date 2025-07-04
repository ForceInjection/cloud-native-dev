#!/bin/bash

if [[ -n "${UTILS_LOADED:-}" ]]; then
    return 0
fi
readonly UTILS_LOADED=1
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'
readonly BOLD='\033[1m'

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

file_exists() {
    [[ -f "$1" ]]
}

dir_exists() {
    [[ -d "$1" ]]
}

get_os_type() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

get_mac_arch() {
    local arch=$(uname -m)
    case "$arch" in
        "x86_64")
            echo "intel"
            ;;
        "arm64")
            echo "apple_silicon"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}


is_root() {
    [[ $EUID -eq 0 ]]
}


check_write_permission() {
    local dir="$1"
    
    if [[ ! -d "$dir" ]]; then
        if ! mkdir -p "$dir" 2>/dev/null; then
            return 1
        fi
    fi
    
    [[ -w "$dir" ]]
}





check_system_resources() {
    local min_memory_gb="${1:-4}"
    local min_disk_gb="${2:-10}"
    
    local available_memory_mb=$(get_available_memory)
    local min_memory_mb=$((min_memory_gb * 1024))
    
    if [[ $available_memory_mb -lt $min_memory_mb ]]; then
        log_error "可用内存不足: ${available_memory_mb}MB < ${min_memory_mb}MB"
        return 1
    fi
    
    local available_disk_gb
    if [[ "$(get_os_type)" == "macos" ]]; then
        available_disk_gb=$(df -g . | awk 'NR==2 {print $4}')
    else
        available_disk_gb=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    fi
    
    if [[ $available_disk_gb -lt $min_disk_gb ]]; then
        log_error "可用磁盘空间不足: ${available_disk_gb}GB < ${min_disk_gb}GB"
        return 1
    fi
    
    return 0
}





wait_for_confirmation() {
    local message="$1"
    local default="${2:-n}"
    
    if [[ "${FORCE_YES:-false}" == "true" ]]; then
        log_info "强制确认模式，自动选择: y"
        return 0
    fi
    
    local prompt
    if [[ "$default" == "y" ]]; then
        prompt="$message [Y/n]: "
    else
        prompt="$message [y/N]: "
    fi
    
    while true; do
        read -p "$prompt" -r response
        
        if [[ -z "$response" ]]; then
            response="$default"
        fi
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "请输入 y 或 n"
                ;;
        esac
    done
}


retry_command() {
    local max_attempts="$1"
    local delay="$2"
    local cmd="$3"
    local description="${4:-执行命令}"
    
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        log_info "$description (尝试 $attempt/$max_attempts)"
        
        if eval "$cmd"; then
            log_success "$description 成功"
            return 0
        else
            if [[ $attempt -lt $max_attempts ]]; then
                log_warning "$description 失败，${delay}秒后重试..."
                sleep "$delay"
            else
                log_error "$description 失败，已达到最大重试次数"
                return 1
            fi
        fi
        
        ((attempt++))
    done
    
    return 1
}


check_network_connectivity() {
    local host="${1:-8.8.8.8}"
    local timeout="${2:-5}"
    
    ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
}


check_essential_connectivity() {
    local hosts=("github.com" "raw.githubusercontent.com" "registry-1.docker.io" "brew.sh")
    local failed_hosts=()
    
    log_info "检查关键服务网络连接..."
    
    for host in "${hosts[@]}"; do
        if ! check_network_connectivity "$host" 10; then
            failed_hosts+=("$host")
            log_warning "无法连接到: $host"
        else
            log_success "连接正常: $host"
        fi
    done
    
    if [[ ${#failed_hosts[@]} -gt 0 ]]; then
        log_error "以下服务连接失败: ${failed_hosts[*]}"
        return 1
    fi
    
    return 0
}


get_available_memory() {
    if [[ "$(get_os_type)" == "macos" ]]; then
        echo $(($(sysctl -n hw.memsize) / 1024 / 1024))
    else
        echo $(($(free -m | awk 'NR==2{print $7}')))
    fi
}


get_cpu_cores() {
    if [[ "$(get_os_type)" == "macos" ]]; then
        sysctl -n hw.ncpu
    else
        nproc
    fi
}


cleanup_temp_files() {
    local temp_dir="$1"
    
    if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
        log_info "清理临时目录: $temp_dir"
        rm -rf "$temp_dir"
    fi
}


setup_error_handling() {
    set -e
    set -u
    set -o pipefail
}




# 统一的 Colima 状态检查函数
get_colima_status() {
    local vm_name="${1:-${COLIMA_VM_NAME:-default}}"
    
    if ! command_exists colima; then
        echo "未安装"
        return 1
    fi
    
    local status=$(colima list 2>/dev/null | grep "^$vm_name" | awk '{print $2}' || echo "Stopped")
    if [[ -n "$status" && "$status" != "Stopped" ]]; then
        echo "$status"
    else
        echo "已停止"
    fi
}

# 检查 Colima 是否运行
is_colima_running() {
    local vm_name="${1:-${COLIMA_VM_NAME:-default}}"
    local status=$(get_colima_status "$vm_name")
    [[ "$status" == "Running" ]]
}

# 检查 Docker 是否运行
is_docker_running() {
    docker info >/dev/null 2>&1
}

# 统一的 Docker 版本获取
get_docker_version() {
    if is_docker_running; then
        docker version --format '{{.Server.Version}}' 2>/dev/null || echo "未知"
    else
        echo "未运行"
    fi
}

# 统一的日志函数 - 标准化所有模块的日志输出
log_with_timestamp() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo -e "${BLUE}[$timestamp] [INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[$timestamp] [SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[$timestamp] [WARNING]${NC} $message" >&2
            ;;
        "ERROR")
            echo -e "${RED}[$timestamp] [ERROR]${NC} $message" >&2
            ;;
        *)
            echo -e "[$timestamp] [$level] $message"
            ;;
    esac
}

# 兼容性别名函数
log_info() {
    log_with_timestamp "INFO" "$1"
}

log_success() {
    log_with_timestamp "SUCCESS" "$1"
}

log_warning() {
    log_with_timestamp "WARNING" "$1"
}

log_error() {
    log_with_timestamp "ERROR" "$1"
}

# 统一的网络连接检查函数
check_host_connectivity() {
    local host="$1"
    local port="${2:-80}"
    local timeout="${3:-5}"
    
    if command_exists nc; then
        # 使用 netcat 检查连接
        nc -z -w"$timeout" "$host" "$port" >/dev/null 2>&1
    elif command_exists timeout; then
        # 使用 timeout 和 bash 内置功能
        timeout "$timeout" bash -c "</dev/tcp/$host/$port" >/dev/null 2>&1
    else
        # 使用 curl 作为备选方案
        curl -s --connect-timeout "$timeout" "http://$host:$port" >/dev/null 2>&1
    fi
}