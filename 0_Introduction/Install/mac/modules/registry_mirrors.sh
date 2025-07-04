#!/bin/bash

# Docker 镜像源配置脚本

# 变量默认值
COLIMA_VM_NAME="${COLIMA_VM_NAME:-default}" # Colima 虚拟机名称

# DaoCloud 镜像源 URL
DOCKER_MIRROR_URL="https://docker.m.daocloud.io"

# 配置 Docker daemon 镜像源
configure_docker_daemon() {
    local mirror_url="$1"
    local vm_name="${2:-${COLIMA_VM_NAME:-default}}"

    if [[ -z "$mirror_url" ]]; then
        log_with_timestamp "ERROR" "镜像源URL不能为空"
        return 1
    fi

    log_with_timestamp "INFO" "配置 Docker daemon 镜像源: $mirror_url (虚拟机: $vm_name)"

    # 使用动态的 Colima 配置文件路径
    local colima_config_file="$HOME/.colima/$vm_name/colima.yaml"

    # 检查配置文件是否存在
    if [[ ! -f "$colima_config_file" ]]; then
        log_with_timestamp "ERROR" "Colima 配置文件不存在: $colima_config_file"
        return 1
    fi

    log_with_timestamp "INFO" "检查配置文件中的镜像源设置"

    # 检查是否已存在 registry-mirrors 配置
    if grep -A 10 "^docker:" "$colima_config_file" 2>/dev/null | grep -q "registry-mirrors:" &&
        grep -A 20 "registry-mirrors:" "$colima_config_file" 2>/dev/null | grep -q "$mirror_url"; then
        log_with_timestamp "INFO" "镜像源已存在于配置文件中: $mirror_url"
        return 0
    fi

    log_with_timestamp "INFO" "添加镜像源配置到 Colima 配置文件"

    # 备份配置文件
    cp "$colima_config_file" "$colima_config_file.backup.$(date +%Y%m%d_%H%M%S)"

    # 创建临时配置文件
    local temp_config="$colima_config_file.tmp"

    # 检查是否已有 docker 配置段
    if grep -q "^docker:" "$colima_config_file"; then
        # 移除现有的 docker 配置段
        awk '/^docker:/{skip=1} /^[a-zA-Z][^:]*:/ && !/^docker:/{skip=0} !skip' "$colima_config_file" >"$temp_config"
    else
        # 复制原文件
        cp "$colima_config_file" "$temp_config"
    fi

    # 添加新的 docker 配置段
    cat >>"$temp_config" <<EOF

# Docker daemon 配置
docker:
  registry-mirrors:
    - $mirror_url
EOF

    # 替换原配置文件
    mv "$temp_config" "$colima_config_file"

    log_with_timestamp "SUCCESS" "镜像源配置已添加到配置文件"

    # 重启 Colima 以应用配置
    log_with_timestamp "INFO" "重启 Colima 以应用配置..."

    if ! restart_colima_vm "$vm_name"; then
        log_with_timestamp "ERROR" "Colima 重启失败，镜像源配置可能未生效"
        return 1
    fi

    log_with_timestamp "SUCCESS" "镜像源配置完成: $mirror_url"
    return 0
}

# 设置镜像源（主要入口函数）
setup_registry_mirrors() {
    log_with_timestamp "INFO" "开始设置 Docker 镜像源"

    # 检查 Colima 是否安装
    if ! check_colima_installed; then
        log_with_timestamp "ERROR" "Colima 未安装，请先安装 Colima"
        return 1
    fi

    # 检查 Colima 是否运行，如果未运行则启动
    if ! is_colima_running "$COLIMA_VM_NAME"; then
        log_with_timestamp "INFO" "Colima 未运行，正在启动..."
        if ! start_colima_vm "$COLIMA_VM_NAME"; then
            log_with_timestamp "ERROR" "Colima 启动失败"
            return 1
        fi
    fi

    log_with_timestamp "INFO" "检测到 Colima 环境，虚拟机: $COLIMA_VM_NAME"

    # 使用 DaoCloud 镜像源
    log_with_timestamp "INFO" "使用 DaoCloud 镜像源: $DOCKER_MIRROR_URL"
    configure_docker_daemon "$DOCKER_MIRROR_URL" "$COLIMA_VM_NAME"
}

# 测试镜像源连通性
test_mirror_connectivity() {
    local mirror_url="${1:-$DOCKER_MIRROR_URL}"

    log_with_timestamp "INFO" "测试镜像源连通性: $mirror_url"

    # 检查Docker是否可用
    if ! is_docker_running; then
        log_with_timestamp "WARNING" "Docker 未运行，跳过镜像源连通性测试"
        return 1
    fi

    # 尝试从镜像源拉取测试镜像
    log_with_timestamp "INFO" "正在从镜像源拉取测试镜像 hello-world..."

    if timeout 60 docker pull hello-world &>/dev/null; then
        log_with_timestamp "SUCCESS" "镜像源连通性测试成功"

        # 运行测试容器
        log_with_timestamp "INFO" "运行测试容器..."
        if docker run --rm hello-world &>/dev/null; then
            log_with_timestamp "SUCCESS" "容器运行测试成功"
        else
            log_with_timestamp "WARNING" "容器运行测试失败"
        fi

        # 清理测试镜像
        docker rmi hello-world &>/dev/null || true

        return 0
    else
        log_with_timestamp "ERROR" "镜像源连通性测试失败"
        return 1
    fi
}

# 主要管理函数
manage_registry_mirrors() {
    log_with_timestamp "INFO" "开始配置 Docker 镜像源..."
    setup_registry_mirrors
    log_with_timestamp "SUCCESS" "Docker 镜像源配置完成"
}
