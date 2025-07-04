#!/bin/bash

COLIMA_VM_NAME="${COLIMA_VM_NAME:-default}"
COLIMA_ARCH="${COLIMA_ARCH:-aarch64}"
COLIMA_VM_TYPE="${COLIMA_VM_TYPE:-vz}"
COLIMA_MOUNT_TYPE="${COLIMA_MOUNT_TYPE:-virtiofs}"
ENABLE_KUBERNETES="${ENABLE_KUBERNETES:-false}"

# 注意：is_colima_running 函数已移至 utils.sh 中统一管理

check_kubectl_installed() {
    if command -v kubectl >/dev/null 2>&1; then
        log_with_timestamp "SUCCESS" "kubectl 已安装"
        return 0
    else
        log_with_timestamp "INFO" "kubectl 未安装"
        return 1
    fi
}

install_kubectl() {
    log_with_timestamp "INFO" "开始安装 kubectl"

    if ! command -v brew >/dev/null 2>&1; then
        log_with_timestamp "ERROR" "需要先安装 Homebrew"
        return 1
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_with_timestamp "INFO" "[模拟] brew install kubectl"
    else
        if brew install kubectl; then
            log_with_timestamp "SUCCESS" "kubectl 安装成功"
        else
            log_with_timestamp "ERROR" "kubectl 安装失败"
            return 1
        fi
    fi

    return 0
}

wait_for_kubernetes() {
    log_with_timestamp "INFO" "等待 Kubernetes 集群就绪..."

    if ! command -v kubectl >/dev/null 2>&1; then
        log_with_timestamp "WARNING" "kubectl 未安装，跳过 Kubernetes 验证"
        return 1
    fi

    local retry_count=0
    local max_retries=60

    while [[ $retry_count -lt $max_retries ]]; do
        if kubectl cluster-info >/dev/null 2>&1; then
            log_with_timestamp "SUCCESS" "Kubernetes 集群已就绪"

            if kubectl wait --for=condition=Ready nodes --all --timeout=60s >/dev/null 2>&1; then
                log_with_timestamp "SUCCESS" "Kubernetes 节点已就绪"
                return 0
            else
                log_with_timestamp "WARNING" "Kubernetes 节点未完全就绪，但集群可用"
                return 0
            fi
        fi

        sleep 3
        ((retry_count++))

        if [[ $((retry_count % 10)) -eq 0 ]]; then
            log_with_timestamp "INFO" "等待 Kubernetes 中... ($retry_count/$max_retries)"
        fi
    done

    log_with_timestamp "ERROR" "Kubernetes 集群启动超时"
    return 1
}

verify_kubernetes() {
    log_with_timestamp "INFO" "验证 Kubernetes 环境"

    local issues_found=0

    if ! command -v kubectl >/dev/null 2>&1; then
        log_with_timestamp "ERROR" "kubectl 未安装"
        ((issues_found++))
        return $issues_found
    fi

    if kubectl cluster-info >/dev/null 2>&1; then
        log_with_timestamp "SUCCESS" "Kubernetes 集群连接正常"

        local k8s_version=$(kubectl version --short --client 2>/dev/null | grep "Client Version" | awk '{print $3}' || echo "未知")
        local server_version=$(kubectl version --short 2>/dev/null | grep "Server Version" | awk '{print $3}' || echo "未知")
        log_with_timestamp "INFO" "kubectl 版本: $k8s_version"
        log_with_timestamp "INFO" "Kubernetes 服务器版本: $server_version"
    else
        log_with_timestamp "ERROR" "Kubernetes 集群连接失败"
        ((issues_found++))
    fi

    if kubectl get nodes >/dev/null 2>&1; then
        local node_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
        local ready_nodes=$(kubectl get nodes --no-headers 2>/dev/null | grep -c "Ready" || echo "0")
        log_with_timestamp "INFO" "Kubernetes 节点: $ready_nodes/$node_count 就绪"

        if [[ "$ready_nodes" -eq "$node_count" ]] && [[ "$node_count" -gt 0 ]]; then
            log_with_timestamp "SUCCESS" "所有 Kubernetes 节点就绪"
        else
            log_with_timestamp "WARNING" "部分 Kubernetes 节点未就绪"
        fi
    else
        log_with_timestamp "ERROR" "无法获取 Kubernetes 节点信息"
        ((issues_found++))
    fi

    if [[ "$SKIP_TESTS" != "true" ]]; then
        log_with_timestamp "INFO" "运行 Kubernetes 连接测试"

        if kubectl get namespaces >/dev/null 2>&1; then
            log_with_timestamp "SUCCESS" "Kubernetes API 测试通过"
        else
            log_with_timestamp "WARNING" "Kubernetes API 测试失败"
        fi
    fi

    return $issues_found
}

check_colima_installed() {
    if command -v colima >/dev/null 2>&1; then
        log_with_timestamp "SUCCESS" "Colima 已安装"
        return 0
    else
        log_with_timestamp "INFO" "Colima 未安装"
        return 1
    fi
}

install_colima() {
    log_with_timestamp "INFO" "开始安装 Colima 虚拟化引擎"

    if ! command -v brew >/dev/null 2>&1; then
        log_with_timestamp "ERROR" "需要先安装 Homebrew"
        return 1
    fi

    log_with_timestamp "INFO" "安装 Colima 和 Docker CLI"
    if [[ "$DRY_RUN" == "true" ]]; then
        log_with_timestamp "INFO" "[模拟] brew install colima docker"
    else
        if brew install colima docker; then
            log_with_timestamp "SUCCESS" "Colima 和 Docker CLI 安装成功"
        else
            log_with_timestamp "ERROR" "Colima 安装失败"
            return 1
        fi
    fi

    return 0
}

configure_colima_vm() {
    local memory="${COLIMA_MEMORY:-2048}"
    local cpu="${COLIMA_CPU_COUNT:-${COLIMA_CPU:-2}}"
    local disk="${COLIMA_DISK_SIZE:-${COLIMA_DISK:-20}}"

    log_with_timestamp "INFO" "配置 Colima 虚拟机参数"
    local memory_display_gb=$((memory / 1024))
    log_with_timestamp "INFO" "内存: ${memory_display_gb}GB, CPU: ${cpu}核, 磁盘: ${disk}GB"

    local disk_gb=$((disk / 1000))
    if [[ $disk_gb -lt 10 ]]; then
        disk_gb=10
        log_with_timestamp "WARNING" "磁盘大小调整为最小值: ${disk_gb}GB"
    fi

    local memory_gb=$((memory / 1024))
    if [[ $memory_gb -lt 1 ]]; then
        memory_gb=1
        log_with_timestamp "WARNING" "内存大小调整为最小值: ${memory_gb}GB"
    fi

    # 保持 COLIMA_MEMORY 为 MB 单位，用于显示一致性
    # 使用 COLIMA_MEMORY_GB 作为 GB 单位的内部变量
    export COLIMA_MEMORY_GB="$memory_gb"
    export COLIMA_CPU="$cpu"
    export COLIMA_DISK="$disk_gb"
}

start_colima_vm() {
    log_with_timestamp "INFO" "启动 Colima 虚拟机"

    local running_instances=$(colima list 2>/dev/null | grep -E "Running|Started" | awk '{print $1}' | grep -v "^$COLIMA_VM_NAME$" || true)
    if [[ -n "$running_instances" ]]; then
        log_with_timestamp "WARNING" "发现其他运行中的Colima实例，正在停止以避免冲突"
        echo "$running_instances" | while read -r instance; do
            if [[ -n "$instance" ]]; then
                log_with_timestamp "INFO" "停止实例: $instance"
                if [[ "$instance" == "default" ]]; then
                    colima stop 2>/dev/null || true
                else
                    colima stop -p "$instance" 2>/dev/null || true
                fi
            fi
        done
    fi

    if is_colima_running "$COLIMA_VM_NAME"; then
        # 检查当前运行的实例是否支持 Kubernetes
        local current_runtime=$(colima list 2>/dev/null | grep "^$COLIMA_VM_NAME" | awk '{print $NF}' || echo "unknown")
        if [[ "$ENABLE_KUBERNETES" == "true" && "$current_runtime" != *"kubernetes"* && "$current_runtime" != *"k3s"* ]]; then
            log_with_timestamp "INFO" "当前 Colima 实例不支持 Kubernetes，需要重新启动以启用 Kubernetes"
            stop_colima_vm
            sleep 3
        else
            log_with_timestamp "INFO" "Colima 虚拟机已在运行"
            return 0
        fi
    fi

    configure_colima_vm

    local start_cmd="colima start"
    if [[ "$COLIMA_VM_NAME" != "default" ]]; then
        start_cmd+=" -p $COLIMA_VM_NAME"
    fi
    start_cmd+=" --arch $COLIMA_ARCH"
    start_cmd+=" --vm-type $COLIMA_VM_TYPE"
    start_cmd+=" --memory $COLIMA_MEMORY_GB"
    start_cmd+=" --cpu $COLIMA_CPU"
    start_cmd+=" --disk $COLIMA_DISK"
    start_cmd+=" --mount-type $COLIMA_MOUNT_TYPE"

    if [[ "$ENABLE_KUBERNETES" == "true" ]]; then
        start_cmd+=" --kubernetes"
        log_with_timestamp "INFO" "启用 Kubernetes 支持"
    fi

    log_with_timestamp "INFO" "执行命令: $start_cmd"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_with_timestamp "INFO" "[模拟] $start_cmd"
        return 0
    fi

    if eval "$start_cmd"; then
        log_with_timestamp "SUCCESS" "Colima 虚拟机启动成功"

        log_with_timestamp "INFO" "等待 Docker 守护进程就绪..."
        local retry_count=0
        local max_retries=30

        while [[ $retry_count -lt $max_retries ]]; do
            if docker info >/dev/null 2>&1; then
                log_with_timestamp "SUCCESS" "Docker 守护进程已就绪"
                break
            fi

            sleep 2
            ((retry_count++))

            if [[ $((retry_count % 5)) -eq 0 ]]; then
                log_with_timestamp "INFO" "等待中... ($retry_count/$max_retries)"
            fi
        done

        if [[ $retry_count -ge $max_retries ]]; then
            log_with_timestamp "ERROR" "Docker 守护进程启动超时"
            return 1
        fi

        if [[ "$ENABLE_KUBERNETES" == "true" ]]; then
            wait_for_kubernetes
        fi

        export DOCKER_HOST="unix://$HOME/.colima/$COLIMA_VM_NAME/docker.sock"
        log_with_timestamp "INFO" "设置 DOCKER_HOST: $DOCKER_HOST"

        return 0
    else
        log_with_timestamp "ERROR" "Colima 虚拟机启动失败"
        return 1
    fi
}

stop_colima_vm() {
    log_with_timestamp "INFO" "停止 Colima 虚拟机"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_with_timestamp "INFO" "[模拟] colima stop $COLIMA_VM_NAME"
        return 0
    fi

    local stop_cmd="colima stop"
    if [[ "$COLIMA_VM_NAME" != "default" ]]; then
        stop_cmd+=" -p $COLIMA_VM_NAME"
    fi
    
    if eval "$stop_cmd"; then
        log_with_timestamp "SUCCESS" "Colima 虚拟机已停止"
    else
        log_with_timestamp "WARNING" "Colima 虚拟机停止失败或未运行"
    fi
}

delete_colima_vm() {
    log_with_timestamp "INFO" "删除 Colima 虚拟机"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_with_timestamp "INFO" "[模拟] colima delete $COLIMA_VM_NAME"
        return 0
    fi

    stop_colima_vm

    local delete_cmd="colima delete --force"
    if [[ "$COLIMA_VM_NAME" != "default" ]]; then
        delete_cmd+=" -p $COLIMA_VM_NAME"
    fi
    
    if eval "$delete_cmd"; then
        log_with_timestamp "SUCCESS" "Colima 虚拟机已删除"
    else
        log_with_timestamp "WARNING" "Colima 虚拟机删除失败或不存在"
    fi
}

# 验证 Colima 环境
verify_colima() {
    log_with_timestamp "INFO" "验证 Colima 环境"

    local issues_found=0

    if is_colima_running "$COLIMA_VM_NAME"; then
        log_with_timestamp "SUCCESS" "Colima 虚拟机运行正常"
    else
        log_with_timestamp "ERROR" "Colima 虚拟机未运行"
        ((issues_found++))
    fi

    if docker info >/dev/null 2>&1; then
        log_with_timestamp "SUCCESS" "Docker 连接正常"

        local docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
        if [[ -n "$docker_version" ]]; then
            log_with_timestamp "INFO" "Docker 版本: $docker_version"
        fi
    else
        log_with_timestamp "ERROR" "Docker 连接失败"
        ((issues_found++))
    fi

    if [[ "$SKIP_TESTS" != "true" ]]; then
        log_with_timestamp "INFO" "运行 Docker 容器测试"

        if docker run --rm alpine:latest echo "Docker test successful" >/dev/null 2>&1; then
            log_with_timestamp "SUCCESS" "Docker 容器测试通过"
        else
            log_with_timestamp "WARNING" "Docker 容器测试失败 - 尝试拉取alpine镜像"
            if docker pull alpine:latest >/dev/null 2>&1 && docker run --rm alpine:latest echo "Docker test successful" >/dev/null 2>&1; then
                log_with_timestamp "SUCCESS" "Docker 容器测试通过（重试后）"
            else
                log_with_timestamp "WARNING" "Docker 容器测试失败 - 可能是网络或镜像源问题"
            fi
        fi
    fi

    if [[ "$ENABLE_KUBERNETES" == "true" ]]; then
        verify_kubernetes
        local k8s_issues=$?
        if [[ $k8s_issues -eq 0 ]]; then
            log_with_timestamp "SUCCESS" "Kubernetes 环境验证通过"
        else
            log_with_timestamp "WARNING" "Kubernetes 环境验证发现 $k8s_issues 个问题"
            ((issues_found += k8s_issues))
        fi
    fi

    if command -v colima >/dev/null 2>&1; then
        # 显示 Colima 实例的详细信息
        local vm_info=$(colima list 2>/dev/null | grep "^$COLIMA_VM_NAME" || echo "无实例信息")
        if [[ -n "$vm_info" && "$vm_info" != "无实例信息" ]]; then
            log_with_timestamp "INFO" "虚拟机状态: $vm_info"
        fi
    fi

    if [[ $issues_found -eq 0 ]]; then
        log_with_timestamp "SUCCESS" "Colima 环境验证通过"
        return 0
    else
        log_with_timestamp "WARNING" "Colima 环境验证发现 $issues_found 个问题"
        return 1
    fi
}

# 注意：get_colima_status 函数已移至 utils.sh 中统一管理

restart_colima_vm() {
    local vm_name="${1:-$COLIMA_VM_NAME}"
    log_with_timestamp "INFO" "重启 Colima 虚拟机: $vm_name"

    local restart_cmd="colima restart"
    local stop_cmd="colima stop"
    local start_cmd="colima start"
    
    # 如果不是默认虚拟机，添加 -p 参数
    if [[ "$vm_name" != "default" ]]; then
        restart_cmd+=" -p $vm_name"
        stop_cmd+=" -p $vm_name"
        start_cmd+=" -p $vm_name"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        log_with_timestamp "INFO" "[模拟] $restart_cmd"
        return 0
    fi

    if eval "$restart_cmd" 2>/dev/null; then
        log_with_timestamp "SUCCESS" "Colima 重启成功"
        return 0
    else
        log_with_timestamp "WARNING" "Colima 重启失败，尝试停止后重新启动"
        eval "$stop_cmd" 2>/dev/null || true
        sleep 3
        if eval "$start_cmd" 2>/dev/null; then
            log_with_timestamp "SUCCESS" "Colima 启动成功"
            return 0
        else
            log_with_timestamp "ERROR" "Colima 启动失败，请手动执行: $start_cmd"
            return 1
        fi
    fi
}



uninstall_colima() {
    log_with_timestamp "INFO" "开始卸载 Colima"

    delete_colima_vm

    if [[ "$DRY_RUN" == "true" ]]; then
        log_with_timestamp "INFO" "[模拟] brew uninstall colima docker"
    else
        if brew uninstall colima docker 2>/dev/null; then
            log_with_timestamp "SUCCESS" "Colima 卸载成功"
        else
            log_with_timestamp "WARNING" "Colima 卸载失败或未安装"
        fi
    fi

    local config_dir="$HOME/.colima"
    if [[ -d "$config_dir" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_with_timestamp "INFO" "[模拟] 删除配置目录: $config_dir"
        else
            rm -rf "$config_dir"
            log_with_timestamp "INFO" "已删除配置目录: $config_dir"
        fi
    fi
}

install_docker_with_colima() {
    if [[ "$ENABLE_KUBERNETES" == "true" ]]; then
        log_with_timestamp "INFO" "使用 Colima 安装 Docker + Kubernetes 环境"
    else
        log_with_timestamp "INFO" "使用 Colima 安装 Docker 环境"
    fi

    local arch=$(uname -m)
    if [[ "$arch" != "arm64" ]]; then
        log_with_timestamp "WARNING" "Colima 主要为 Apple Silicon (ARM64) 优化"
        log_with_timestamp "INFO" "当前架构: $arch"
    fi

    if ! check_colima_installed; then
        if ! install_colima; then
            return 1
        fi
    fi

    if [[ "$ENABLE_KUBERNETES" == "true" ]]; then
        if ! check_kubectl_installed; then
            if ! install_kubectl; then
                log_with_timestamp "WARNING" "kubectl 安装失败，但将继续安装 Colima"
            fi
        fi
    fi

    if ! start_colima_vm; then
        return 1
    fi

    if ! verify_colima; then
        return 1
    fi

    if [[ "$ENABLE_KUBERNETES" == "true" ]]; then
        log_with_timestamp "SUCCESS" "Docker + Kubernetes 环境 (Colima) 安装完成"
    else
        log_with_timestamp "SUCCESS" "Docker 环境 (Colima) 安装完成"
    fi
    return 0
}

# 导出函数
export -f check_colima_installed
export -f install_colima
export -f start_colima_vm
export -f stop_colima_vm
export -f restart_colima_vm
export -f delete_colima_vm
export -f verify_colima
export -f get_colima_status
export -f uninstall_colima
export -f install_docker_with_colima
