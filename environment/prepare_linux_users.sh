#!/bin/bash

set -euo pipefail

# ==================== 配置变量 ====================
NAMESPACE_FILE="namespaces.txt"
DEFAULT_PASSWORD="dangerous"

# ==================== 颜色输出函数 ====================
print_green() { echo -e "\033[32m$1\033[0m"; }
print_red() { echo -e "\033[31m$1\033[0m"; }
print_yellow() { echo -e "\033[33m$1\033[0m"; }
print_blue() { echo -e "\033[34m$1\033[0m"; }

# ==================== 检查系统 ====================
check_system() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    print_red "错误: 此脚本只能在Linux系统上运行"
    exit 1
  fi

  if [[ $EUID -ne 0 ]]; then
    print_red "错误: 需要root权限，请使用sudo运行"
    exit 1
  fi

  if [[ ! -f "$NAMESPACE_FILE" ]]; then
    print_red "错误: 配置文件不存在: $NAMESPACE_FILE"
    exit 1
  fi

  # 检查 Docker 安装状态
  check_docker_installation

  print_green "✓ 系统检查通过"
}

# ==================== 检查 Docker 安装 ====================
check_docker_installation() {
  print_blue "检查 Docker 安装状态..."
  
  # 检查 docker 命令是否存在
  if ! command -v docker >/dev/null 2>&1; then
    print_yellow "⚠ Docker 命令未找到"
    print_yellow "  建议: 请先安装 Docker"
    return 1
  fi
  
  # 检查 Docker 服务是否运行
  if ! systemctl is-active --quiet docker 2>/dev/null; then
    print_yellow "⚠ Docker 服务未运行"
    print_yellow "  建议: sudo systemctl start docker"
    return 1
  fi
  
  # 检查 docker 组是否存在
  if ! getent group docker >/dev/null 2>&1; then
    print_yellow "⚠ docker 组不存在"
    print_yellow "  建议: sudo groupadd docker"
    return 1
  fi
  
  print_green "✓ Docker 环境检查通过"
  return 0
}

# ==================== 检查用户是否存在 ====================
user_exists() {
  local username="$1"
  id "$username" &>/dev/null
}

# ==================== 创建用户 ====================
create_user() {
    local username="$1"
    
    echo "创建用户 $username..."
    sudo useradd -m -s /bin/bash -c "K8s User for $username" "$username"
    
    echo "设置用户家目录权限..."
    # 设置用户家目录权限为 700，确保只有用户自己可以访问
    sudo chmod 700 "/home/$username"
    sudo chown "$username:$username" "/home/$username"
    echo "✓ 用户家目录权限设置完成 (700)"
    
    echo "添加用户到 docker 组..."
    # 检查 docker 组是否存在
    if getent group docker >/dev/null 2>&1; then
        sudo usermod -aG docker "$username"
        echo "✓ 用户已添加到 docker 组"
    else
        echo "⚠ docker 组不存在，跳过添加到 docker 组"
        echo "  请确保 Docker 已正确安装并创建了 docker 组"
    fi
    
    echo "设置密码..."
    echo "$username:dangerous" | sudo chpasswd
    
    echo "创建 .kube 目录..."
    sudo mkdir -p "/home/$username/.kube"
    sudo chown "$username:$username" "/home/$username/.kube"
    sudo chmod 700 "/home/$username/.kube"
    
    echo "检查 kubeconfig 文件..."
    if [[ -f "$username-admin-config" ]]; then
        echo "复制 kubeconfig 文件..."
        sudo cp "$username-admin-config" "/home/$username/.kube/config"
        sudo chown "$username:$username" "/home/$username/.kube/config"
        sudo chmod 600 "/home/$username/.kube/config"
        echo "✓ kubeconfig 文件复制成功"
    else
        echo "⚠ kubeconfig 文件不存在: $username-admin-config"
    fi
    
    echo "验证用户创建..."
    id "$username"
    ls -la "/home/$username/.kube/"
    
    echo "✓ 用户 $username 创建完成"
    echo "默认密码: dangerous"
    echo "请提醒用户登录后修改密码"
    echo ""
    echo "Docker 权限说明:"
    echo "  - 用户已添加到 docker 组"
    echo "  - 需要重新登录才能生效 Docker 权限"
    echo "  - 登录后可以执行: docker build, docker run 等命令"
    echo "  - 验证权限: docker --version && docker info"
    
    return 0
}

# ==================== 删除用户 ====================
delete_user() {
  local username="$1"

  if ! user_exists "$username"; then
    print_yellow "用户不存在: $username"
    return 0
  fi

  print_blue "删除用户: $username"
  if userdel -r "$username"; then
    print_green "✓ 用户删除成功: $username"
  else
    print_red "✗ 用户删除失败: $username"
    return 1
  fi
}

# ==================== 验证用户 ====================
verify_user() {
  local username="$1"

  if ! user_exists "$username"; then
    print_red "✗ 用户不存在: $username"
    return 1
  fi

  local user_home="/home/$username"
  local kube_dir="$user_home/.kube"
  local config_file="$kube_dir/config"

  print_blue "验证用户: $username"

  if [[ -d "$user_home" ]]; then
    print_green "  ✓ 用户家目录存在"
  else
    print_red "  ✗ 用户家目录不存在"
    return 1
  fi

  if [[ -d "$kube_dir" ]]; then
    print_green "  ✓ .kube目录存在"
  else
    print_red "  ✗ .kube目录不存在"
    return 1
  fi

  if [[ -f "$config_file" ]]; then
    print_green "  ✓ kubeconfig文件存在"
  else
    print_yellow "  ⚠ kubeconfig文件不存在"
  fi

  # 验证 Docker 权限
  if groups "$username" | grep -q "\bdocker\b"; then
    print_green "  ✓ 用户已加入 docker 组"
  else
    print_yellow "  ⚠ 用户未加入 docker 组"
  fi

  print_green "✓ 用户验证完成: $username"
  return 0
}

# ==================== 列出用户 ====================
list_users() {
  print_blue "管理的用户列表:"
  echo
  printf "%-20s %-15s %-15s\n" "用户名" "系统状态" "配置文件"
  printf "%-20s %-15s %-15s\n" "------" "--------" "--------"

  while IFS= read -r line; do
    if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      local namespace
      read -r namespace _ <<<"$line"
      [[ -n "$namespace" ]] || continue

      local username="$namespace"
      local user_status="不存在" config_status="不存在"

      if user_exists "$username"; then
        user_status="存在"

        if [[ -f "/home/$username/.kube/config" ]]; then
          config_status="存在"
        fi
      fi

      printf "%-20s %-15s %-15s\n" "$username" "$user_status" "$config_status"
    fi
  done <"$NAMESPACE_FILE"
  echo
}

# ==================== 主函数 ====================
main() {
  print_blue "开始创建Linux用户"
  print_blue "配置文件: $NAMESPACE_FILE"

  # 检查配置文件是否可读
  if [[ ! -r "$NAMESPACE_FILE" ]]; then
    print_red "错误: 无法读取配置文件: $NAMESPACE_FILE"
    return 1
  fi

  local total=0 success=0

  while IFS= read -r line; do
    print_blue "读取行: '$line'"
    
    # 跳过空行和注释行
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
      print_yellow "跳过空行或注释行"
      continue
    fi

    local namespace
    read -r namespace _ <<<"$line"
    print_blue "解析到命名空间: '$namespace'"
    
    [[ -n "$namespace" ]] || {
      print_yellow "命名空间为空，跳过"
      continue
    }

    local username="$namespace"
    total=$((total + 1))
    print_blue "开始处理用户: $username (总计: $total)"

    print_blue "即将调用 create_user 函数"
    if create_user "$username"; then
      success=$((success + 1))
      print_green "create_user 函数执行成功"
    else
      print_red "create_user 函数执行失败"
    fi

    echo
  done <"$NAMESPACE_FILE"

  print_blue "处理完成: $success/$total 成功"

  if [[ $success -eq $total ]]; then
    print_green "\n🎉 所有用户创建成功！"
    print_yellow "默认密码: $DEFAULT_PASSWORD"
    print_yellow "请提醒用户登录后修改密码"
  else
    print_red "\n❌ 部分用户创建失败"
    return 1
  fi
}

# ==================== 帮助信息 ====================
show_help() {
  cat <<EOF
Linux用户管理脚本 (简化版)

用法: $0 [选项] [参数]

选项:
  (无参数)           创建所有用户
  -h, --help         显示帮助信息
  -l, --list         列出所有用户状态
  -v, --verify [用户] 验证用户设置
  -d, --delete <用户> 删除指定用户
  --cleanup          删除所有管理的用户

功能说明:
  - 自动创建用户并设置 Kubernetes 配置
  - 自动添加用户到 docker 组，支持 Docker 操作
  - 检查 Docker 环境并提供安装建议
  - 验证用户的 Kubernetes 和 Docker 权限

配置文件: $NAMESPACE_FILE
默认密码: $DEFAULT_PASSWORD

Docker 权限:
  - 用户创建后自动加入 docker 组
  - 支持 docker build, docker run 等操作
  - 需要重新登录才能生效

示例:
  sudo $0                    # 创建所有用户
  sudo $0 --list            # 列出用户状态
  sudo $0 --verify nju03    # 验证特定用户
  sudo $0 --delete nju03    # 删除特定用户
  sudo $0 --cleanup         # 删除所有用户
EOF
}

# ==================== 参数解析 ====================
case "${1:-}" in
-h | --help)
  show_help
  exit 0
  ;;
-l | --list)
  check_system
  list_users
  exit 0
  ;;
-v | --verify)
  check_system
  if [[ -n "${2:-}" ]]; then
    verify_user "$2"
  else
    # 验证所有用户
    while IFS= read -r line; do
      if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
        local namespace
        read -r namespace _ <<<"$line"
        [[ -n "$namespace" ]] || continue
        verify_user "$namespace"
        echo
      fi
    done <"$NAMESPACE_FILE"
  fi
  exit $?
  ;;
-d | --delete)
  check_system
  [[ -z "${2:-}" ]] && {
    print_red "错误: 需要指定用户名"
    exit 1
  }
  delete_user "$2"
  exit $?
  ;;
--cleanup)
  check_system
  print_yellow "警告: 即将删除所有管理的用户"
  read -p "确认删除? (输入 'yes' 确认): " -r
  if [[ "$REPLY" == "yes" ]]; then
    while IFS= read -r line; do
      if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
        local namespace
        read -r namespace _ <<<"$line"
        [[ -n "$namespace" ]] || continue
        delete_user "$namespace"
      fi
    done <"$NAMESPACE_FILE"
  else
    print_blue "操作已取消"
  fi
  exit 0
  ;;
"")
  # 默认操作：创建用户
  check_system
  main
  exit $?
  ;;
*)
  print_red "错误: 未知选项 $1"
  show_help
  exit 1
  ;;
esac
