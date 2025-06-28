#!/bin/bash

set -euo pipefail

# ==================== 配置变量 ====================
CREATE_LINUX_USERS="false"
NAMESPACE_FILE="namespaces.txt"
CONFIG_TEMPLATE="config"
LOG_FILE="prepare_ns_$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="./backup"
USER_PASSWORD_FILE="/tmp/user_passwords_$(date +%Y%m%d_%H%M%S).txt"

# 创建必要目录
mkdir -p "$BACKUP_DIR"

# ==================== 颜色输出函数 ====================
print_green() { echo -e "\033[32m$1\033[0m"; }
print_red() { echo -e "\033[31m$1\033[0m"; }
print_yellow() { echo -e "\033[33m$1\033[0m"; }
print_blue() { echo -e "\033[34m$1\033[0m"; }
print_bold() { echo -e "\033[1m$1\033[0m"; }

# ==================== 日志函数 ====================
log() {
  local level="$1"
  local message="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local color_code=""
  
  case "$level" in
    "ERROR") color_code="\033[31m" ;;
    "WARN")  color_code="\033[33m" ;;
    "INFO")  color_code="\033[32m" ;;
    *)       color_code="\033[0m" ;;
  esac
  
  echo -e "${color_code}[$timestamp] [$level] $message\033[0m" | tee -a "$LOG_FILE"
}

# ==================== 先决条件检查 ====================
check_prerequisites() {
  log "INFO" "检查先决条件..."
  
  # 检查kubectl
  if ! command -v kubectl >/dev/null 2>&1; then
    log "ERROR" "kubectl未安装，请先安装kubectl"
    exit 1
  fi
  
  # 检查集群连接
  if ! kubectl cluster-info >/dev/null 2>&1; then
    log "ERROR" "无法连接到Kubernetes集群"
    exit 1
  fi
  
  # 检查配置文件
  if [[ ! -f "$NAMESPACE_FILE" ]]; then
    log "ERROR" "配置文件不存在: $NAMESPACE_FILE"
    exit 1
  fi
  
  if [[ ! -f "$CONFIG_TEMPLATE" ]]; then
    log "ERROR" "模板文件不存在: $CONFIG_TEMPLATE"
    exit 1
  fi
  
  # 检查Linux用户创建权限
  if [[ "$CREATE_LINUX_USERS" == "true" ]] && [[ $EUID -ne 0 ]]; then
    log "ERROR" "创建Linux用户需要root权限"
    exit 1
  fi
  
  log "INFO" "✓ 先决条件检查通过"
}

# ==================== 资源配置验证 ====================
validate_resources() {
  local cpu_request="$1"
  local cpu_limit="$2"
  local memory_request="$3"
  local memory_limit="$4"
  
  # 简化的资源格式验证
  if [[ ! "$cpu_request" =~ ^[0-9]+m?$ ]] || [[ ! "$cpu_limit" =~ ^[0-9]+m?$ ]]; then
    log "ERROR" "CPU资源格式错误"
    return 1
  fi
  
  if [[ ! "$memory_request" =~ ^[0-9]+[MG]i?$ ]] || [[ ! "$memory_limit" =~ ^[0-9]+[MG]i?$ ]]; then
    log "ERROR" "内存资源格式错误"
    return 1
  fi
  
  return 0
}

# ==================== 简化的kubectl执行函数 ====================
execute_kubectl() {
  local description="$1"
  shift
  
  log "INFO" "执行: $description"
  if "$@" >>/dev/null 2>>"$LOG_FILE"; then
    log "INFO" "✓ $description 成功"
    return 0
  else
    log "ERROR" "✗ $description 失败"
    return 1
  fi
}

# ==================== 简化的密码生成 ====================
generate_secure_password() {
  openssl rand -base64 12 | tr -d "=+/" | cut -c1-12
}

# ==================== 审计日志 ====================
audit_log() {
  local action="$1"
  local target="$2"
  local user="$3"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] $action: $target by $user" >> "${LOG_FILE%.log}_audit.log"
}

# ==================== 创建Linux用户 ====================
create_linux_user() {
  local username="$1"
  local namespace="$2"
  
  if [[ "$CREATE_LINUX_USERS" != "true" ]]; then
    return 0
  fi
  
  log "INFO" "创建Linux用户: $username"
  
  # 检查用户是否已存在
  if id "$username" &>/dev/null; then
    log "INFO" "用户 $username 已存在，跳过创建"
    return 0
  fi
  
  # 生成安全密码
  local password
  password=$(generate_secure_password)
  
  # 创建用户
  if useradd -m -s /bin/bash "$username" 2>>"$LOG_FILE"; then
    log "INFO" "✓ 用户 $username 创建成功"
  else
    log "ERROR" "用户 $username 创建失败"
    return 1
  fi
  
  # 设置密码并强制首次登录修改
  echo "$username:$password" | chpasswd
  chage -d 0 "$username"
  
  # 记录密码到文件
  echo "用户: $username, 临时密码: $password, 命名空间: $namespace" >> "$USER_PASSWORD_FILE"
  chmod 600 "$USER_PASSWORD_FILE"
  
  audit_log "CREATE_USER" "$username" "$namespace"
  log "INFO" "✓ 用户 $username 密码设置完成"
  
  return 0
}

# ==================== 分发kubeconfig ====================
distribute_kubeconfig() {
  local username="$1"
  local namespace="$2"
  local config_file="${namespace}-admin-config"
  
  if [[ "$CREATE_LINUX_USERS" != "true" ]] || [[ ! -f "$config_file" ]]; then
    return 0
  fi
  
  local user_home
  user_home=$(getent passwd "$username" | cut -d: -f6)
  
  if [[ -z "$user_home" ]] || [[ ! -d "$user_home" ]]; then
    log "ERROR" "用户家目录不存在: $user_home"
    return 1
  fi
  
  # 创建.kube目录
  local kube_dir="$user_home/.kube"
  mkdir -p "$kube_dir"
  
  # 复制kubeconfig文件
  cp "$config_file" "$kube_dir/config"
  chown -R "$username:$username" "$kube_dir"
  chmod 700 "$kube_dir"
  chmod 600 "$kube_dir/config"
  
  log "INFO" "✓ Kubeconfig已分发到用户目录: $kube_dir/config"
  return 0
}

# ==================== 创建命名空间 ====================
create_namespace() {
  local namespace="$1"
  local cpu_request="$2"
  local cpu_limit="$3"
  local memory_request="$4"
  local memory_limit="$5"
  local quota_cpu="$6"
  local quota_memory="$7"
  
  log "INFO" "开始创建命名空间: $namespace"
  
  # 验证资源配置
  if ! validate_resources "$cpu_request" "$cpu_limit" "$memory_request" "$memory_limit"; then
    log "ERROR" "命名空间 $namespace 的资源配置验证失败"
    return 1
  fi
  
  # 创建命名空间
  if ! kubectl get ns "$namespace" >/dev/null 2>&1; then
    execute_kubectl "创建命名空间 $namespace" kubectl create ns "$namespace"
  else
    log "INFO" "命名空间 $namespace 已存在"
  fi
  
  # 创建ResourceQuota
  execute_kubectl "创建ResourceQuota" kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${namespace}-quota
  namespace: $namespace
  labels:
    managed-by: prepare-ns-script
spec:
  hard:
    requests.cpu: "$quota_cpu"
    requests.memory: "$quota_memory"
    limits.cpu: "$quota_cpu"
    limits.memory: "$quota_memory"
    persistentvolumeclaims: "10"
    services: "20"
    secrets: "50"
    configmaps: "50"
EOF
  
  # 创建LimitRange
  execute_kubectl "创建LimitRange" kubectl apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: ${namespace}-limits
  namespace: $namespace
  labels:
    managed-by: prepare-ns-script
spec:
  limits:
  - default:
      cpu: "$cpu_limit"
      memory: "$memory_limit"
    defaultRequest:
      cpu: "$cpu_request"
      memory: "$memory_request"
    type: Container
EOF
  
  log "INFO" "✓ 命名空间 $namespace 资源配置完成"
  return 0
}

# ==================== 创建ServiceAccount和RBAC ====================
create_sa() {
  local name="$1"
  
  log "INFO" "创建ServiceAccount和RBAC: $name"
  
  # 创建ServiceAccount
  execute_kubectl "创建ServiceAccount" kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${name}
  namespace: ${name}
  labels:
    managed-by: prepare-ns-script
EOF
  
  # 创建Role
  execute_kubectl "创建Role" kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${name}
  name: ${name}-admin-role
  labels:
    managed-by: prepare-ns-script
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims", "events", "endpoints"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses", "networkpolicies"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs", "cronjobs"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: [""]
  resources: ["pods/exec", "pods/log", "pods/portforward"]
  verbs: ["create", "get"]
EOF
  
  # 创建RoleBinding
  execute_kubectl "创建RoleBinding" kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${name}-admin-role-binding
  namespace: ${name}
  labels:
    managed-by: prepare-ns-script
subjects:
- kind: ServiceAccount
  name: ${name}
  namespace: ${name}
roleRef:
  kind: Role
  name: ${name}-admin-role
  apiGroup: rbac.authorization.k8s.io
EOF
  
  # 创建Token Secret
  execute_kubectl "创建Token Secret" kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${name}-secret
  namespace: ${name}
  labels:
    managed-by: prepare-ns-script
  annotations:
    kubernetes.io/service-account.name: ${name}
type: kubernetes.io/service-account-token
EOF
  
  log "INFO" "✓ ServiceAccount和RBAC创建完成: $name"
  return 0
}

# ==================== 生成kubeconfig ====================
create_config() {
  local name="$1"
  local max_retries=10
  local retry_count=0
  
  log "INFO" "生成kubeconfig文件: $name"
  
  # 等待secret准备完成
  local SECRET_NAME
  while [[ $retry_count -lt $max_retries ]]; do
    SECRET_NAME=$(kubectl get secret "${name}-secret" -n "${name}" -o name 2>/dev/null | cut -d'/' -f2)
    if [[ -n "$SECRET_NAME" ]] && 
       kubectl get secret "$SECRET_NAME" -n "${name}" -o jsonpath='{.data.token}' &>/dev/null; then
      break
    fi
    log "WARN" "等待secret准备完成，重试 $((retry_count + 1))/$max_retries"
    sleep 3
    ((retry_count++))
  done
  
  if [[ -z "$SECRET_NAME" ]] || [[ $retry_count -eq $max_retries ]]; then
    log "ERROR" "无法获取有效的secret: ${name}-secret"
    return 1
  fi
  
  # 获取token和证书
  local TOKEN CA_CERT
  TOKEN=$(kubectl get secret "$SECRET_NAME" -o jsonpath='{.data.token}' -n "${name}" | base64 --decode)
  CA_CERT=$(kubectl get secret "$SECRET_NAME" -o jsonpath='{.data.ca\.crt}' -n "${name}")
  
  if [[ -z "$TOKEN" ]] || [[ -z "$CA_CERT" ]]; then
    log "ERROR" "无法获取token或CA证书"
    return 1
  fi
  
  # 获取集群信息
  local CLUSTER_NAME CLUSTER_SERVER
  CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
  CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
  
  if [[ -z "$CLUSTER_NAME" ]] || [[ -z "$CLUSTER_SERVER" ]]; then
    log "ERROR" "无法获取集群信息"
    return 1
  fi
  
  # 生成kubeconfig文件
  local OUTPUT_KUBECONFIG="${name}-admin-config"
  
  # 备份现有文件
  if [[ -f "$OUTPUT_KUBECONFIG" ]]; then
    cp "$OUTPUT_KUBECONFIG" "$BACKUP_DIR/${OUTPUT_KUBECONFIG}_$(date +%Y%m%d_%H%M%S).bak"
  fi
  
  # 复制模板并替换变量
  cp "$CONFIG_TEMPLATE" "$OUTPUT_KUBECONFIG"
  sed -i "s|<CLUSTER_NAME>|$CLUSTER_NAME|g" "$OUTPUT_KUBECONFIG"
  sed -i "s|<CLUSTER_SERVER>|$CLUSTER_SERVER|g" "$OUTPUT_KUBECONFIG"
  sed -i "s|<certificate-authority-data>|$CA_CERT|g" "$OUTPUT_KUBECONFIG"
  sed -i "s|<token>|$TOKEN|g" "$OUTPUT_KUBECONFIG"
  sed -i "s|<name>|$name|g" "$OUTPUT_KUBECONFIG"
  
  chmod 600 "$OUTPUT_KUBECONFIG"
  
  # 验证kubeconfig
  if kubectl --kubeconfig="$OUTPUT_KUBECONFIG" auth can-i get pods -n "$name" &>/dev/null; then
    log "INFO" "✓ Kubeconfig文件生成并验证成功: $OUTPUT_KUBECONFIG"
  else
    log "WARN" "Kubeconfig文件已生成但权限验证失败: $OUTPUT_KUBECONFIG"
  fi
  
  return 0
}

# ==================== 验证命名空间设置 ====================
verify_namespace_setup() {
  local namespace="$1"
  log "INFO" "验证命名空间设置: $namespace"
  
  local errors=0
  local resources=("namespace/$namespace" "resourcequota/${namespace}-quota" "limitrange/${namespace}-limits" 
                   "serviceaccount/$namespace" "role/${namespace}-admin-role" "rolebinding/${namespace}-admin-role-binding" 
                   "secret/${namespace}-secret")
  
  for resource in "${resources[@]}"; do
    local type=${resource%/*}
    local name=${resource#*/}
    local ns_flag=""
    [[ "$type" != "namespace" ]] && ns_flag="-n $namespace"
    
    if kubectl get "$type" "$name" $ns_flag &>/dev/null; then
      log "INFO" "✓ $type 存在"
    else
      log "ERROR" "✗ $type 不存在"
      ((errors++))
    fi
  done
  
  if [[ $errors -eq 0 ]]; then
    log "INFO" "✓ 命名空间 $namespace 验证通过"
    return 0
  else
    log "ERROR" "✗ 命名空间 $namespace 验证失败，发现 $errors 个错误"
    return 1
  fi
}

# ==================== 处理单个命名空间 ====================
process_namespace() {
  local line="$1"
  
  # 跳过空行和注释
  [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]] && return 0
  
  # 解析配置行
  local namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory
  read -r namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory <<<"$line"
  
  # 验证参数
  if [[ -z "$namespace" ]] || [[ -z "$quota_memory" ]]; then
    log "ERROR" "配置行格式错误: $line"
    return 1
  fi
  
  print_bold "\n======== 处理命名空间 $namespace ========"
  
  # 执行创建流程
  create_namespace "$namespace" "$cpu_request" "$cpu_limit" "$memory_request" "$memory_limit" "$quota_cpu" "$quota_memory" &&
  create_sa "$namespace" &&
  create_config "$namespace" &&
  create_linux_user "$namespace" "$namespace" &&
  distribute_kubeconfig "$namespace" "$namespace" &&
  verify_namespace_setup "$namespace"
  
  local result=$?
  print_bold "======== 命名空间 $namespace 处理完成 ========\n"
  return $result
}

# ==================== 主处理逻辑 ====================
main() {
  local success_count=0 failure_count=0 total_count=0
  local start_time=$(date +%s)
  
  log "INFO" "开始处理命名空间配置文件: $NAMESPACE_FILE"
  log "INFO" "Linux用户创建功能: $([[ "$CREATE_LINUX_USERS" == "true" ]] && echo "启用" || echo "禁用")"
  
  while IFS= read -r line; do
    ((total_count++))
    if process_namespace "$line"; then
      ((success_count++))
      log "INFO" "✓ 第 $total_count 个命名空间处理成功"
    else
      ((failure_count++))
      log "ERROR" "✗ 第 $total_count 个命名空间处理失败"
    fi
  done <"$NAMESPACE_FILE"
  
  local duration=$(($(date +%s) - start_time))
  
  # 输出统计结果
  print_bold "\n==================== 处理结果统计 ===================="
  log "INFO" "总计: $total_count, 成功: $success_count, 失败: $failure_count, 耗时: ${duration}秒"
  log "INFO" "日志文件: $LOG_FILE"
  
  if [[ "$CREATE_LINUX_USERS" == "true" ]] && [[ -f "$USER_PASSWORD_FILE" ]]; then
    log "INFO" "用户密码文件: $USER_PASSWORD_FILE"
    print_yellow "⚠️  请及时安全分发临时密码并删除密码文件"
  fi
  
  if [[ $failure_count -eq 0 ]]; then
    print_green "🎉 所有命名空间准备完成！"
    return 0
  else
    print_red "⚠️  部分命名空间处理失败，请检查日志"
    return 1
  fi
}

# ==================== 清理函数 ====================
cleanup_namespace() {
  local namespace="$1"
  [[ -z "$namespace" ]] && { log "ERROR" "清理需要命名空间参数"; return 1; }
  
  log "INFO" "清理命名空间: $namespace"
  
  # 删除kubeconfig文件
  for config_file in "${namespace}-admin-config" "${namespace}.config"; do
    [[ -f "$config_file" ]] && rm -f "$config_file" && log "INFO" "已删除: $config_file"
  done
  
  # 删除Linux用户
  if id "$namespace" &>/dev/null && [[ $EUID -eq 0 ]]; then
    local user_home
    user_home=$(getent passwd "$namespace" | cut -d: -f6)
    [[ -n "$user_home" ]] && [[ -d "$user_home" ]] && 
      tar -czf "$BACKUP_DIR/${namespace}_home_$(date +%Y%m%d_%H%M%S).tar.gz" "$user_home" 2>/dev/null
    
    userdel -r "$namespace" 2>>"$LOG_FILE" && 
      log "INFO" "已删除用户: $namespace" && 
      audit_log "DELETE_USER" "$namespace" "$namespace"
  fi
  
  # 删除命名空间
  kubectl get namespace "$namespace" &>/dev/null && 
    execute_kubectl "删除命名空间 $namespace" kubectl delete namespace "$namespace"
  
  log "INFO" "命名空间 $namespace 清理完成"
}

# ==================== 帮助和工具函数 ====================
show_help() {
  cat <<EOF
用法: $0 [选项]

选项:
  -h, --help              显示帮助信息
  -c, --cleanup <ns>      清理指定命名空间
  -l, --list              列出所有命名空间
  -v, --verify <ns>       验证命名空间设置
  -u, --create-users      启用Linux用户创建（需要root权限）
  --batch-cleanup         批量清理所有命名空间
  --show-passwords        显示密码文件位置
  --version               显示版本信息

示例:
  $0                      # 仅创建K8s资源
  sudo $0 -u              # 创建K8s资源和Linux用户
  $0 -c nju03             # 清理nju03命名空间
  $0 -l                   # 列出所有命名空间

EOF
}

list_namespaces() {
  printf "\n%-20s %-10s %-15s %-15s\n" "命名空间" "K8s状态" "Linux用户" "Kubeconfig"
  printf "%-20s %-10s %-15s %-15s\n" "--------------------" "----------" "---------------" "---------------"
  
  while IFS= read -r line; do
    if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      local namespace
      read -r namespace _ <<<"$line"
      [[ -n "$namespace" ]] || continue
      
      local k8s_status="不存在" user_status="不存在" config_status="不存在"
      kubectl get namespace "$namespace" &>/dev/null && k8s_status="存在"
      id "$namespace" &>/dev/null && user_status="存在"
      [[ -f "${namespace}-admin-config" ]] && config_status="存在"
      
      printf "%-20s %-10s %-15s %-15s\n" "$namespace" "$k8s_status" "$user_status" "$config_status"
    fi
  done <"$NAMESPACE_FILE"
  echo
}

batch_cleanup() {
  log "INFO" "开始批量清理..."
  local cleanup_count=0 error_count=0
  
  while IFS= read -r line; do
    if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      local namespace
      read -r namespace _ <<<"$line"
      [[ -n "$namespace" ]] || continue
      
      if cleanup_namespace "$namespace"; then
        ((cleanup_count++))
      else
        ((error_count++))
      fi
    fi
  done <"$NAMESPACE_FILE"
  
  log "INFO" "批量清理完成 - 成功: $cleanup_count, 失败: $error_count"
}

show_version() {
  cat <<EOF
Kubernetes命名空间管理脚本 (Ubuntu简化版)
版本: 2.1-ubuntu
作者: 云原生开发团队
适用: Ubuntu 18.04+

系统信息:
  操作系统: $(uname -s)
  内核版本: $(uname -r)
  kubectl版本: $(kubectl version --client --short 2>/dev/null || echo "未安装")
EOF
}

show_passwords() {
  local password_files=()
  for file in /tmp/user_passwords_*.txt ./user_passwords_*.txt; do
    [[ -f "$file" ]] && password_files+=("$file")
  done
  
  if [[ ${#password_files[@]} -eq 0 ]]; then
    log "INFO" "未找到密码文件"
  else
    log "INFO" "找到密码文件:"
    for file in "${password_files[@]}"; do
      local file_age=$(stat -c %Y "$file" 2>/dev/null)
      local age_hours=$((($(date +%s) - file_age) / 3600))
      printf "  %s (创建于 %d 小时前)\n" "$file" "$age_hours"
    done
    print_yellow "⚠️  请及时处理密码文件"
  fi
}

# ==================== 信号处理 ====================
cleanup_on_exit() {
  local exit_code=$?
  [[ $exit_code -ne 0 ]] && log "ERROR" "脚本异常退出，退出码: $exit_code"
  exit $exit_code
}

trap cleanup_on_exit EXIT
trap 'log "WARN" "收到中断信号，正在退出..."; exit 130' INT TERM

# ==================== 参数解析 ====================
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help) show_help; exit 0 ;;
    -c|--cleanup) [[ -z "$2" ]] && { log "ERROR" "需要指定命名空间"; exit 1; }; cleanup_namespace "$2"; exit $? ;;
    -l|--list) list_namespaces; exit 0 ;;
    -v|--verify) [[ -z "$2" ]] && { log "ERROR" "需要指定命名空间"; exit 1; }; verify_namespace_setup "$2"; exit $? ;;
    -u|--create-users) CREATE_LINUX_USERS="true"; shift ;;
    --batch-cleanup) batch_cleanup; exit $? ;;
    --show-passwords) show_passwords; exit 0 ;;
    --version) show_version; exit 0 ;;
    *) log "ERROR" "未知选项: $1"; show_help; exit 1 ;;
  esac
done

# ==================== 执行主逻辑 ====================
check_prerequisites

print_bold "\n🚀 Kubernetes命名空间管理脚本 (Ubuntu简化版) v2.1"
log "INFO" "配置文件: $NAMESPACE_FILE"
log "INFO" "日志文件: $LOG_FILE"
log "INFO" "备份目录: $BACKUP_DIR"

main
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
  print_green "\n🎉 脚本执行成功！"
else
  print_red "\n❌ 脚本执行失败！请检查日志: $LOG_FILE"
fi

exit $exit_code