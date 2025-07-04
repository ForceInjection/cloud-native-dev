#!/bin/bash

check_xcode() {
    log_info "检查 Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        log_success "Xcode Command Line Tools 已安装"
        return 0
    else
        log_warning "Xcode Command Line Tools 未安装"
        log_info "正在安装 Xcode Command Line Tools..."

        xcode-select --install

        log_info "请在弹出的对话框中点击 '安装' 按钮"
        log_info "安装完成后请重新运行此脚本"

        while ! xcode-select -p &>/dev/null; do
            sleep 5
        done

        log_success "Xcode Command Line Tools 安装完成"
        return 0
    fi
}

check_homebrew() {
    log_info "检查 Homebrew..."

    if command_exists brew; then
        log_success "Homebrew 已安装"
        local brew_version=$(brew --version | head -n1)
        log_info "当前版本: $brew_version"
        return 0
    else
        log_warning "Homebrew 未安装"

        if wait_for_confirmation "是否安装 Homebrew?" "y"; then
            install_homebrew
        else
            log_error "Homebrew 是必需的，无法继续安装"
            exit 1
        fi
    fi
}

check_docker_environment() {
    log_info "检查 Docker 环境..."

    # 检查 Docker 是否可用
    if command_exists docker; then
        log_info "✓ Docker 已安装"
        
        # 检查 Docker 守护进程
        if is_docker_running; then
            log_info "✓ Docker 守护进程正在运行"
        else
            log_warning "⚠ Docker 已安装但守护进程未运行"
        fi
    else
        log_info "ℹ Docker 未安装（将通过 Colima 安装）"
    fi

    # 检查 Colima 是否已安装
    if command_exists colima; then
        log_info "✓ Colima 已安装"
        
        # 检查 Colima 状态
        if is_colima_running; then
            log_info "✓ Colima 正在运行"
        else
            log_info "ℹ Colima 已安装但未运行"
        fi
    else
        log_info "ℹ Colima 未安装"
    fi

    # 检查 Homebrew
    if command_exists brew; then
        log_info "✓ Homebrew 已安装"
    else
        log_error "✗ Homebrew 未安装，请先安装 Homebrew"
        return 1
    fi
}

install_homebrew() {
    log_info "正在安装 Homebrew..."

    if ! check_network_connectivity "raw.githubusercontent.com" 10; then
        log_error "无法连接到 GitHub，请检查网络连接"
        exit 1
    fi

    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_success "Homebrew 安装完成"

        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >>~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if command_exists brew; then
            log_success "Homebrew 验证成功"
        else
            log_error "Homebrew 安装失败，请手动安装"
            exit 1
        fi
    else
        log_error "Homebrew 安装失败"
        exit 1
    fi
}

update_homebrew() {
    log_info "更新 Homebrew..."

    if retry_command 3 5 "brew update" "更新 Homebrew 软件包列表"; then
        log_success "Homebrew 更新完成"
    else
        log_warning "Homebrew 更新失败，继续使用当前版本"
    fi

    local outdated=$(brew outdated)
    if [[ -n "$outdated" ]]; then
        log_info "发现过时的软件包:"
        echo "$outdated"

        if wait_for_confirmation "是否升级过时的软件包?" "n"; then
            brew upgrade
            log_success "软件包升级完成"
        fi
    fi
}

check_virtualization() {
    log_info "检查虚拟化支持..."

    local arch=$(get_mac_arch)

    case "$arch" in
    "apple_silicon")
        log_info "检测到 Apple Silicon Mac"

        if sysctl -n kern.hv_support 2>/dev/null | grep -q "1"; then
            log_success "Hypervisor 框架支持已启用"
        else
            log_warning "Hypervisor 框架支持未启用或不可用"
        fi
        ;;
    "intel")
        log_info "检测到 Intel Mac"

        if sysctl -n machdep.cpu.features 2>/dev/null | grep -q "VMX"; then
            log_success "Intel VT-x 虚拟化技术支持已启用"
        else
            log_warning "Intel VT-x 虚拟化技术支持未启用"
        fi
        ;;
    *)
        log_warning "未知的Mac架构: $arch"
        ;;
    esac

    local memory=$(get_available_memory)
    log_info "可用内存: ${memory}MB"

    if [[ $memory -lt 4096 ]]; then
        log_warning "可用内存不足4GB，可能影响Docker性能"
    fi

    local cores=$(get_cpu_cores)
    log_info "CPU核心数: $cores"

    if [[ $cores -lt 2 ]]; then
        log_warning "CPU核心数不足，可能影响Docker性能"
    fi
}

check_system_compatibility() {
    log_info "检查系统版本兼容性..."

    local os_version=$(sw_vers -productVersion)
    local major_version=$(echo "$os_version" | cut -d. -f1)
    local minor_version=$(echo "$os_version" | cut -d. -f2)

    log_info "当前系统版本: macOS $os_version"

    if [[ $major_version -gt 10 ]] || [[ $major_version -eq 10 && $minor_version -ge 13 ]]; then
        log_success "系统版本满足要求"
    else
        log_error "系统版本过低，需要 macOS 10.13 或更高版本"
        exit 1
    fi

    if [[ $major_version -eq 10 && $minor_version -eq 15 ]]; then
        log_warning "macOS Catalina 可能存在权限问题，建议升级到更新版本"
    fi
}

check_disk_space() {
    log_info "检查磁盘空间..."

    local available_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')
    local space_gb=$(echo "$available_space" | sed 's/[^0-9.]//g')

    log_info "可用磁盘空间: ${available_space}"

    if (($(echo "$space_gb < 10" | bc -l))); then
        log_error "磁盘空间不足10GB，无法继续安装"
        exit 1
    elif (($(echo "$space_gb < 20" | bc -l))); then
        log_warning "磁盘空间不足20GB，建议清理磁盘空间"
    else
        log_success "磁盘空间充足"
    fi
}



check_optional_dependencies() {
    log_info "检查可选依赖..."

    if command_exists "jq"; then
        log_success "jq 已安装"
    else
        log_info "jq 未安装，将在需要时自动安装"
    fi

    local optional_tools=("curl" "wget" "git")
    for tool in "${optional_tools[@]}"; do
        if command_exists "$tool"; then
            log_success "$tool 已安装"
        else
            log_warning "$tool 未安装，可能影响某些功能"
        fi
    done
}

check_permissions() {
    log_info "检查权限..."

    if groups "$(whoami)" | grep -q "\badmin\b"; then
        log_success "当前用户具有管理员权限"
    else
        log_warning "当前用户不是管理员，可能需要sudo权限"
    fi

    if sudo -n true 2>/dev/null; then
        log_success "sudo 权限可用"
    else
        log_info "需要sudo权限，安装过程中可能需要输入密码"
    fi
}

check_kubernetes_environment() {
    log_info "检查 Kubernetes 环境..."

    # 检查是否有运行中的 Colima 实例支持 Kubernetes
    if command_exists colima; then
        local running_instances=$(colima list 2>/dev/null | grep "Running" || true)
        if [[ -n "$running_instances" ]]; then
            log_info "发现运行中的 Colima 实例:"
            echo "$running_instances"
            
            # 检查是否有支持 Kubernetes 的实例
            local k8s_instances=$(echo "$running_instances" | grep -E "kubernetes|k3s" || true)
            if [[ -n "$k8s_instances" ]]; then
                log_success "发现支持 Kubernetes 的 Colima 实例"
                
                # 检查 kubectl 是否安装
                if command_exists kubectl; then
                    log_success "kubectl 已安装"
                    
                    # 检查 kubectl 版本
                    local kubectl_version=$(kubectl version --client --short 2>/dev/null | grep "Client Version" | awk '{print $3}' || echo "未知")
                    log_info "kubectl 版本: $kubectl_version"
                    
                    # 检查集群连接
                    if kubectl cluster-info >/dev/null 2>&1; then
                        log_success "Kubernetes 集群连接正常"
                        
                        # 检查节点状态
                        if kubectl get nodes >/dev/null 2>&1; then
                            local node_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
                            local ready_nodes=$(kubectl get nodes --no-headers 2>/dev/null | grep -c "Ready" || echo "0")
                            log_info "Kubernetes 节点状态: $ready_nodes/$node_count 就绪"
                            
                            if [[ "$ready_nodes" -eq "$node_count" ]] && [[ "$node_count" -gt 0 ]]; then
                                log_success "所有 Kubernetes 节点就绪"
                            else
                                log_warning "部分 Kubernetes 节点未就绪"
                            fi
                        else
                            log_warning "无法获取 Kubernetes 节点信息"
                        fi
                        
                        # 检查基本 API 访问
                        if kubectl get namespaces >/dev/null 2>&1; then
                            log_success "Kubernetes API 访问正常"
                        else
                            log_warning "Kubernetes API 访问异常"
                        fi
                    else
                        log_warning "Kubernetes 集群连接失败"
                        log_info "提示: 可能需要等待集群完全启动"
                    fi
                else
                    log_warning "kubectl 未安装，无法验证 Kubernetes 环境"
                    log_info "提示: 如需使用 Kubernetes，请安装 kubectl"
                fi
            else
                log_info "当前 Colima 实例不支持 Kubernetes"
            fi
        else
            log_info "未发现运行中的 Colima 实例"
        fi
    else
        log_info "Colima 未安装，跳过 Kubernetes 环境检查"
    fi
}

run_system_checks() {
    log_info "开始系统环境检查..."

    check_system_compatibility
    check_disk_space
    check_permissions
    check_xcode
    check_homebrew
    check_virtualization
    check_optional_dependencies
    check_docker_environment
    check_kubernetes_environment

    log_success "系统环境检查完成"
}
