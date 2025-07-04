#!/bin/bash

verify_installation() {
    log_info "验证 Docker 安装..."
    local has_error=false

    log_info "检查 Docker 版本:"
    if docker --version; then
        log_success "Docker 版本检查通过"
    else
        log_error "Docker 版本检查失败"
        has_error=true
    fi

    echo

    log_info "检查 Colima 状态:"
    if command_exists colima; then
        local colima_status=$(get_colima_status)
        log_info "Colima 状态: $colima_status"
        if is_colima_running; then
            log_success "Colima 状态检查通过"
        else
            log_warning "Colima 未运行"
        fi
    else
        log_error "Colima 未安装"
        has_error=true
    fi

    echo

    log_info "检查 Docker 守护进程连接..."
    if is_docker_running; then
        log_success "Docker 守护进程连接正常"

        log_info "运行测试容器..."
        if run_test_container; then
            log_success "测试容器运行成功"
        else
            log_warning "测试容器运行失败"
            has_error=true
        fi
    else
        log_warning "无法连接到 Docker 守护进程（Colima可能未运行）"
        log_info "这不会影响基本验证，但容器测试将被跳过"
    fi

    if [[ "$has_error" == "true" ]]; then
        log_warning "Docker 安装验证未完全通过"
        return 1
    else
        log_success "Docker 安装验证成功！"
        return 0
    fi
}

run_test_container() {
    log_info "拉取并运行 hello-world 测试容器..."

    if timeout 60 docker pull hello-world; then
        log_success "hello-world 镜像拉取成功"
    else
        log_error "hello-world 镜像拉取失败"
        return 1
    fi

    if docker run --rm hello-world; then
        log_success "hello-world 容器运行成功"

        docker rmi hello-world &>/dev/null || true

        return 0
    else
        log_error "hello-world 容器运行失败"
        return 1
    fi
}

run_comprehensive_test() {
    log_info "运行综合功能测试..."

    local test_results=()

    log_info "测试1: 基本容器操作"
    if test_basic_container_operations; then
        test_results+=("基本容器操作: 通过")
    else
        test_results+=("基本容器操作: 失败")
    fi

    echo

    log_info "测试2: 网络功能"
    if test_network_functionality; then
        test_results+=("网络功能: 通过")
    else
        test_results+=("网络功能: 失败")
    fi

    echo

    log_info "测试3: 存储功能"
    if test_storage_functionality; then
        test_results+=("存储功能: 通过")
    else
        test_results+=("存储功能: 失败")
    fi

    echo

    echo

    log_info "综合测试结果:"
    for result in "${test_results[@]}"; do
        if [[ "$result" == *"通过"* ]]; then
            log_success "  $result"
        else
            log_error "  $result"
        fi
    done

    local failed_tests=0
    if [[ ${#test_results[@]} -gt 0 ]]; then
        failed_tests=$(printf '%s\n' "${test_results[@]}" | grep -c "失败" 2>/dev/null || echo "0")
        # 确保 failed_tests 是一个纯数字
        failed_tests=$(echo "$failed_tests" | tr -d '\n\r' | grep -o '[0-9]*' | head -1)
        [[ -z "$failed_tests" ]] && failed_tests=0
    fi

    if [[ $failed_tests -eq 0 ]]; then
        log_success "所有综合测试通过！"
        return 0
    else
        log_warning "有 $failed_tests 项测试失败"
        return 1
    fi
}

test_basic_container_operations() {
    log_info "测试基本容器操作..."

    # 测试1: 简单容器运行
    if ! docker run --rm alpine:latest echo "Hello from Alpine"; then
        log_error "Alpine 容器运行失败"
        return 1
    fi
    log_success "基本容器操作测试完成"
    return 0
}

test_network_functionality() {

    local network_name="test-network-$(date +%s)"

    if docker network create "$network_name" >/dev/null; then
        log_success "自定义网络创建成功: $network_name"
    else
        log_error "自定义网络创建失败"
        return 1
    fi

    if docker run --rm --network="$network_name" alpine:latest ping -c 1 google.com >/dev/null; then
        log_success "网络连接测试通过"
    else
        log_warning "网络连接测试失败（可能是网络限制）"
    fi

    docker network rm "$network_name" >/dev/null

    return 0
}

test_storage_functionality() {

    local volume_name="test-volume-$(date +%s)"

    if docker volume create "$volume_name" >/dev/null; then
        log_success "数据卷创建成功: $volume_name"
    else
        log_error "数据卷创建失败"
        return 1
    fi

    local test_data="Hello Docker Volume"

    if docker run --rm -v "$volume_name:/data" alpine:latest sh -c "echo '$test_data' > /data/test.txt"; then
        log_success "数据写入测试通过"
    else
        log_error "数据写入测试失败"
        docker volume rm "$volume_name" >/dev/null
        return 1
    fi

    local read_data
    if read_data=$(docker run --rm -v "$volume_name:/data" alpine:latest cat /data/test.txt); then
        if [[ "$read_data" == "$test_data" ]]; then
            log_success "数据持久性测试通过"
        else
            log_error "数据持久性测试失败: 数据不匹配"
            docker volume rm "$volume_name" >/dev/null
            return 1
        fi
    else
        log_error "数据读取测试失败"
        docker volume rm "$volume_name" >/dev/null
        return 1
    fi

    docker volume rm "$volume_name" >/dev/null

    return 0
}

run_performance_test() {
    log_info "运行性能测试..."

    log_info "测试镜像拉取速度..."
    local start_time=$(date +%s)

    if docker pull alpine:latest >/dev/null 2>&1; then
        local end_time=$(date +%s)
        local pull_time=$((end_time - start_time))
        log_success "Alpine 镜像拉取时间: ${pull_time}秒"
    else
        log_error "镜像拉取测试失败"
    fi

    log_info "测试容器启动速度..."
    start_time=$(date +%s%N)

    if docker run --rm alpine:latest echo "Speed test" >/dev/null; then
        local end_time=$(date +%s%N)
        local startup_time=$(((end_time - start_time) / 1000000)) # 转换为毫秒
        log_success "容器启动时间: ${startup_time}ms"
    else
        log_error "容器启动测试失败"
    fi

    log_info "测试并发容器启动..."
    local concurrent_count=5
    start_time=$(date +%s)

    for i in $(seq 1 $concurrent_count); do
        docker run --rm -d alpine:latest sleep 5 >/dev/null &
    done

    wait # 等待所有后台任务完成

    local end_time=$(date +%s)
    local concurrent_time=$((end_time - start_time))
    log_success "${concurrent_count}个并发容器启动时间: ${concurrent_time}秒"

    log_success "性能测试完成"
}

show_usage_info() {
    echo
    log_success "=== Docker + Colima 安装完成 ==="
    echo
    echo -e "${GREEN}Colima 管理命令:${NC}"
    echo -e "  启动 Colima:        ${BLUE}colima start${NC}"
    echo -e "  停止 Colima:        ${BLUE}colima stop${NC}"
    echo -e "  查看状态:           ${BLUE}colima status${NC}"
    echo -e "  重启 Colima:        ${BLUE}colima restart${NC}"
    echo -e "  查看日志:           ${BLUE}colima logs${NC}"
    echo
    echo -e "${GREEN}Docker 基本命令:${NC}"
    echo -e "  查看镜像:           ${BLUE}docker images${NC}"
    echo -e "  查看容器:           ${BLUE}docker ps${NC}"
    echo -e "  拉取镜像:           ${BLUE}docker pull <镜像名>${NC}"
    echo -e "  运行容器:           ${BLUE}docker run <镜像名>${NC}"
    echo -e "  构建镜像:           ${BLUE}docker build -t <标签> .${NC}"
    echo

    echo -e "${GREEN}注意事项:${NC}"
    echo "  1. Colima 启动后 Docker 命令即可直接使用"
    echo "  2. 无需配置额外的环境变量"
    echo "  3. 使用前确保 Colima 处于 Running 状态"
    echo -e "  4. 如遇问题，可尝试重启 Colima: ${YELLOW}colima restart${NC}"
    echo
    echo -e "${GREEN}故障排除:${NC}"
    echo -e "  查看详细日志:       ${BLUE}colima logs${NC}"
    echo -e "  重置 Colima:        ${BLUE}colima delete && colima start${NC}"
    echo -e "  检查系统资源:       ${BLUE}colima status --verbose${NC}"
    echo
}

show_system_info() {
    log_info "系统信息:"
    echo

    echo -e "${GREEN}Docker 版本信息:${NC}"
    docker --version 2>/dev/null || echo "  Docker: 未安装或不可用"

    colima --version 2>/dev/null || echo "  Colima: 未安装或不可用"
    echo

    echo -e "${GREEN}Colima 状态信息:${NC}"
    if command_exists colima; then
        local colima_status=$(get_colima_status)
        echo "  Colima 状态: $colima_status"

        if colima list 2>/dev/null; then
            echo
        fi

        if is_docker_running; then
            echo -e "${GREEN}Docker 守护进程信息:${NC}"
            docker info | grep -E "Server Version|Storage Driver|Logging Driver|Cgroup Driver|Kernel Version|Operating System|Architecture|CPUs|Total Memory" | sed 's/^/  /'
        fi
    else
        echo "  Colima 未安装"
    fi

    echo
}

generate_installation_report() {
    local report_file="$HOME/docker-installation-report-$(date +%Y%m%d_%H%M%S).txt"

    log_info "生成安装报告: $report_file"

    if ! touch "$report_file" 2>/dev/null; then
        log_error "无法创建报告文件: $report_file"
        return 1
    fi

    {
        echo "Docker Engine 安装报告"
        echo "生成时间: $(date)"
        echo "系统信息: $(uname -a)"
        echo "macOS版本: $(sw_vers -productVersion 2>/dev/null || echo 'unknown')"
        echo "架构: $(uname -m)"
        echo

        echo "=== 安装的组件 ==="
        docker --version 2>/dev/null || echo "Docker: 未安装"

        colima --version 2>/dev/null || echo "Colima: 未安装"
        echo

        echo "=== Colima 状态 ==="
        if command -v colima >/dev/null 2>&1; then
            colima list 2>/dev/null || echo "无 Colima 实例"
        else
            echo "Colima 未安装"
        fi
        echo

        echo "=== Docker 守护进程信息 ==="
        if is_docker_running; then
            docker info 2>/dev/null || echo "获取Docker信息失败"
        else
            echo "无法连接到 Docker 守护进程"
        fi
        echo

        echo "=== 镜像源配置 ==="
        if is_colima_running; then
            colima ssh "${COLIMA_VM_NAME:-default}" "sudo cat /etc/docker/daemon.json 2>/dev/null" || echo "无镜像源配置"
        else
            echo "Colima未运行，无法获取镜像源配置"
        fi
        echo

        echo "=== Colima 配置信息 ==="
        if command_exists colima; then
            # 显示 Colima 实例的详细配置信息
            colima list 2>/dev/null | grep "^${COLIMA_VM_NAME:-default}" || echo "无配置信息"
        else
            echo "Colima 未安装"
        fi

    } >"$report_file" 2>/dev/null

    if [[ -f "$report_file" && -s "$report_file" ]]; then
        log_success "安装报告已生成: $report_file"
        echo "$report_file"
        return 0
    else
        log_error "安装报告生成失败"
        return 1
    fi
}

run_verification() {
    log_info "开始验证 Docker 安装..."
    echo

    if command_exists colima; then
        if ! is_colima_running; then
            log_info "Colima 处于停止状态，正在尝试启动..."
            if colima start "${COLIMA_VM_NAME:-default}" 2>/dev/null; then
                log_success "Colima 已启动"
                log_info "等待Docker守护进程启动..."
                sleep 5
            else
                log_warning "无法启动Colima，将在离线模式下进行验证"
                log_info "请检查系统资源和虚拟化支持"
            fi
        elif is_colima_running; then
            log_success "Colima 已在运行中"
        else
            local colima_status=$(get_colima_status)
            log_warning "Colima 状态未知: $colima_status"
        fi
    else
        log_warning "未找到Colima，将验证本地Docker组件"
    fi

    local verify_result=0
    verify_installation || verify_result=$?

    echo

    show_system_info

    local docker_available=false
    if is_docker_running; then
        docker_available=true
    fi

    if [[ "$docker_available" == "true" ]] && wait_for_confirmation "是否运行综合功能测试?" "n"; then
        echo
        run_comprehensive_test
    elif [[ "$docker_available" != "true" ]]; then
        log_warning "Docker守护进程不可用，跳过综合功能测试"
    fi

    if [[ "$docker_available" == "true" ]] && wait_for_confirmation "是否运行性能测试?" "n"; then
        echo
        run_performance_test
    elif [[ "$docker_available" != "true" ]]; then
        log_warning "Docker守护进程不可用，跳过性能测试"
    fi

    if wait_for_confirmation "是否生成安装报告?" "y"; then
        echo
        generate_installation_report
    fi

    show_usage_info

    echo
    if [[ $verify_result -eq 0 ]]; then
        log_success "Docker 安装验证完成！"
        return 0
    else
        log_warning "Docker 安装验证部分通过，某些测试被跳过"
        log_info "请确保Docker Machine正常运行后再进行完整验证"
        return $verify_result
    fi
}
