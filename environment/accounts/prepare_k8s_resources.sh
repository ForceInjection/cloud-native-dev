#!/bin/bash

set -euo pipefail

# ==================== 配置变量 ====================
NAMESPACE_FILE="namespaces.txt"
CONFIG_TEMPLATE="config"
BACKUP_DIR="./backup"

# ==================== 颜色输出函数 ====================
print_green() { echo -e "\033[32m$1\033[0m"; }
print_red() { echo -e "\033[31m$1\033[0m"; }
print_yellow() { echo -e "\033[33m$1\033[0m"; }
print_blue() { echo -e "\033[34m$1\033[0m"; }

# ==================== 创建必要目录 ====================
mkdir -p "$BACKUP_DIR"

# ==================== 先决条件检查 ====================
check_prerequisites() {
  # 检查kubectl
  if ! command -v kubectl >/dev/null 2>&1; then
    print_red "错误: kubectl未安装，请先安装kubectl"
    exit 1
  fi
  
  # 检查集群连接
  if ! kubectl cluster-info >/dev/null 2>&1; then
    print_red "错误: 无法连接到Kubernetes集群"
    exit 1
  fi
  
  # 检查配置文件
  if [[ ! -f "$NAMESPACE_FILE" ]]; then
    print_red "错误: 配置文件不存在: $NAMESPACE_FILE"
    exit 1
  fi
  
  if [[ ! -f "$CONFIG_TEMPLATE" ]]; then
    print_red "错误: 模板文件不存在: $CONFIG_TEMPLATE"
    exit 1
  fi
  
  # 检查权限
  if [[ ! -r "$NAMESPACE_FILE" ]]; then
    print_red "错误: 无法读取配置文件: $NAMESPACE_FILE"
    exit 1
  fi
  
  if [[ ! -r "$CONFIG_TEMPLATE" ]]; then
    print_red "错误: 无法读取模板文件: $CONFIG_TEMPLATE"
    exit 1
  fi
}

# ==================== 资源配置验证 ====================
validate_resources() {
  local cpu_request="$1"
  local cpu_limit="$2"
  local memory_request="$3"
  local memory_limit="$4"
  
  # CPU资源格式验证
  if [[ ! "$cpu_request" =~ ^[0-9]+m?$ ]] || [[ ! "$cpu_limit" =~ ^[0-9]+m?$ ]]; then
    print_red "错误: CPU资源格式错误: 请求=$cpu_request, 限制=$cpu_limit"
    return 1
  fi
  
  # 内存资源格式验证
  if [[ ! "$memory_request" =~ ^[0-9]+[MG]i?$ ]] || [[ ! "$memory_limit" =~ ^[0-9]+[MG]i?$ ]]; then
    print_red "错误: 内存资源格式错误: 请求=$memory_request, 限制=$memory_limit"
    return 1
  fi
  
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
  
  # 验证资源配置
  if ! validate_resources "$cpu_request" "$cpu_limit" "$memory_request" "$memory_limit"; then
    return 1
  fi
  
  # 检查命名空间是否已存在
  if ! kubectl get ns "$namespace" >/dev/null 2>&1; then
    kubectl create ns "$namespace"
  fi
  
  # 创建ResourceQuota
  kubectl apply -f - <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${namespace}-quota
  namespace: $namespace
  labels:
    managed-by: k8s-resources-script
    created-date: "$(date +%Y%m%d)"
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
  kubectl apply -f - <<EOF
apiVersion: v1
kind: LimitRange
metadata:
  name: ${namespace}-limits
  namespace: $namespace
  labels:
    managed-by: k8s-resources-script
    created-date: "$(date +%Y%m%d)"
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
  
  return 0
}

# ==================== 创建ServiceAccount和RBAC ====================
create_sa() {
  local name="$1"
  
  # 创建ServiceAccount
  kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${name}
  namespace: ${name}
  labels:
    managed-by: k8s-resources-script
    created-date: "$(date +%Y%m%d)"
EOF
  
  # 创建Role
  kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${name}
  name: ${name}-admin-role
  labels:
    managed-by: k8s-resources-script
    created-date: "$(date +%Y%m%d)"
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims", "events", "endpoints"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: [""]
  resources: ["pods/attach", "pods/exec", "pods/log", "pods/portforward"]
  verbs: ["get", "list", "create"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "daemonsets", "statefulsets"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses", "networkpolicies"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["get", "list", "create", "update", "patch", "delete", "watch"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers/status"]
  verbs: ["get", "update", "patch"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
- apiGroups: ["custom.metrics.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list"]
- apiGroups: ["external.metrics.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list"]
EOF
  
  # 创建RoleBinding
  kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${name}-admin-binding
  namespace: ${name}
  labels:
    managed-by: k8s-resources-script
    created-date: "$(date +%Y%m%d)"
subjects:
- kind: ServiceAccount
  name: ${name}
  namespace: ${name}
roleRef:
  kind: Role
  name: ${name}-admin-role
  apiGroup: rbac.authorization.k8s.io
EOF
  
  return 0
}

# ==================== 创建kubeconfig ====================
create_config() {
  local name="$1"
  local config_file="${name}-admin-config"
  
  # 备份现有配置
  if [[ -f "$config_file" ]]; then
    local backup_file="$BACKUP_DIR/${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$config_file" "$backup_file"
  fi
  
  # 获取ServiceAccount token
  local token_name
  token_name=$(kubectl get sa "$name" -n "$name" -o jsonpath='{.secrets[0].name}' 2>/dev/null)
  
  if [[ -z "$token_name" ]]; then
    # 为Kubernetes 1.24+创建token
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${name}-token
  namespace: ${name}
  annotations:
    kubernetes.io/service-account.name: ${name}
type: kubernetes.io/service-account-token
EOF
    token_name="${name}-token"
    
    # 等待token生成，增加重试机制
    local retry_count=0
    local max_retries=10
    while [[ $retry_count -lt $max_retries ]]; do
      sleep 2
      if kubectl get secret "$token_name" -n "$name" >/dev/null 2>&1; then
        break
      fi
      retry_count=$((retry_count + 1))
    done
    
    if [[ $retry_count -eq $max_retries ]]; then
      print_red "错误: token secret创建超时"
      return 1
    fi
  fi
  
  # 获取token，增加重试机制
  local token
  local retry_count=0
  local max_retries=10
  
  while [[ $retry_count -lt $max_retries ]]; do
    token=$(kubectl get secret "$token_name" -n "$name" -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null)
    if [[ -n "$token" ]]; then
      break
    fi
    sleep 2
    retry_count=$((retry_count + 1))
  done
  
  if [[ -z "$token" ]]; then
    print_red "错误: 无法获取ServiceAccount token，已重试 $max_retries 次"
    return 1
  fi
  
  # 获取集群信息
  local server
  server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
  local ca_data
  ca_data=$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
  
  # 生成kubeconfig
  cat > "$config_file" <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $ca_data
    server: $server
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: $name
    user: $name
  name: ${name}@kubernetes
current-context: ${name}@kubernetes
users:
- name: $name
  user:
    token: $token
EOF
  
  chmod 600 "$config_file"
  return 0
}

# ==================== 验证命名空间设置 ====================
verify_namespace_setup() {
  local namespace="$1"
  
  # 检查命名空间
  if ! kubectl get ns "$namespace" >/dev/null 2>&1; then
    print_red "错误: 命名空间不存在: $namespace"
    return 1
  fi
  
  # 检查ResourceQuota
  if ! kubectl get resourcequota "${namespace}-quota" -n "$namespace" >/dev/null 2>&1; then
    print_red "错误: ResourceQuota不存在: ${namespace}-quota"
    return 1
  fi
  
  # 检查LimitRange
  if ! kubectl get limitrange "${namespace}-limits" -n "$namespace" >/dev/null 2>&1; then
    print_red "错误: LimitRange不存在: ${namespace}-limits"
    return 1
  fi
  
  # 检查ServiceAccount
  if ! kubectl get sa "$namespace" -n "$namespace" >/dev/null 2>&1; then
    print_red "错误: ServiceAccount不存在: $namespace"
    return 1
  fi
  
  # 检查Role
  if ! kubectl get role "${namespace}-admin-role" -n "$namespace" >/dev/null 2>&1; then
    print_red "错误: Role不存在: ${namespace}-admin-role"
    return 1
  fi
  
  # 检查RoleBinding
  if ! kubectl get rolebinding "${namespace}-admin-binding" -n "$namespace" >/dev/null 2>&1; then
    print_red "错误: RoleBinding不存在: ${namespace}-admin-binding"
    return 1
  fi
  
  # 检查kubeconfig文件
  local config_file="${namespace}-admin-config"
  if [[ ! -f "$config_file" ]]; then
    print_red "错误: Kubeconfig文件不存在: $config_file"
    return 1
  fi
  
  return 0
}

# ==================== 处理单个命名空间 ====================
process_namespace() {
  local line="$1"
  local line_number="$2"
  
  # 解析配置行
  local namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory
  read -r namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory <<< "$line"
  
  if [[ -z "$namespace" ]]; then
    return 0
  fi
  
  print_blue "处理命名空间: $namespace (第 $line_number 行)"
  
  # 验证参数完整性
  if [[ -z "$cpu_request" || -z "$cpu_limit" || -z "$memory_request" || -z "$memory_limit" || -z "$quota_cpu" || -z "$quota_memory" ]]; then
    print_red "错误: 第 $line_number 行配置参数不完整: $line"
    print_yellow "期望格式: namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory"
    return 1
  fi
  
  # 按顺序执行各个步骤
  if ! create_namespace "$namespace" "$cpu_request" "$cpu_limit" "$memory_request" "$memory_limit" "$quota_cpu" "$quota_memory"; then
    print_red "错误: 创建命名空间失败: $namespace"
    return 1
  fi
  
  if ! create_sa "$namespace"; then
    print_red "错误: 创建ServiceAccount失败: $namespace"
    return 1
  fi
  
  if ! create_config "$namespace"; then
    print_red "错误: 创建kubeconfig失败: $namespace"
    return 1
  fi
  
  if ! verify_namespace_setup "$namespace"; then
    print_red "错误: 验证命名空间设置失败: $namespace"
    return 1
  fi
  
  print_green "✓ 命名空间 $namespace 处理完成"
  return 0
}

# ==================== 主函数 ====================
main() {
  print_blue "开始批量处理命名空间配置"
  
  local total_count=0 success_count=0 error_count=0 line_number=0
  
  while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # 跳过空行和注释行
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
      continue
    fi
    
    total_count=$((total_count + 1))
    
    if process_namespace "$line" "$line_number"; then
      success_count=$((success_count + 1))
    else
      error_count=$((error_count + 1))
    fi
    
    echo  # 添加空行分隔
  done < "$NAMESPACE_FILE"
  
  # 输出处理结果统计
  print_blue "批量处理完成"
  print_blue "总计: $total_count 个配置"
  print_green "成功: $success_count 个"
  print_red "失败: $error_count 个"
  
  if [[ $error_count -gt 0 ]]; then
    return 1
  fi
  
  return 0
}

# ==================== 清理函数 ====================
cleanup_namespace() {
  local namespace="$1"
  
  print_blue "开始清理命名空间: $namespace"
  
  # 删除kubeconfig文件
  local config_file="${namespace}-admin-config"
  if [[ -f "$config_file" ]]; then
    rm -f "$config_file"
    print_green "✓ 已删除kubeconfig文件: $config_file"
  fi
  
  # 删除命名空间（会自动删除其中的所有资源）
  if kubectl get ns "$namespace" >/dev/null 2>&1; then
    kubectl delete ns "$namespace"
  fi
  
  print_green "✓ 命名空间清理完成: $namespace"
  return 0
}

# ==================== 列出命名空间 ====================
list_namespaces() {
  print_blue "列出所有管理的命名空间"
  
  echo
  printf "%-20s %-15s %-15s\n" "命名空间" "K8s状态" "配置文件"
  printf "%-20s %-15s %-15s\n" "--------" "-------" "--------"
  
  while IFS= read -r line; do
    if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      local namespace
      read -r namespace _ <<< "$line"
      [[ -n "$namespace" ]] || continue
      
      local k8s_status="不存在" config_status="不存在"
      kubectl get ns "$namespace" >/dev/null 2>&1 && k8s_status="存在"
      [[ -f "${namespace}-admin-config" ]] && config_status="存在"
      
      printf "%-20s %-15s %-15s\n" "$namespace" "$k8s_status" "$config_status"
    fi
  done < "$NAMESPACE_FILE"
  echo
}

# ==================== 帮助信息 ====================
show_help() {
  cat <<EOF
Kubernetes资源管理脚本（简化版）

用法: $0 [选项]

选项:
  -h, --help              显示此帮助信息
  -c, --cleanup <ns>      清理指定命名空间
  -l, --list              列出所有命名空间状态
  -v, --verify <ns>       验证指定命名空间设置
  --batch-cleanup         批量清理所有命名空间

配置文件格式 ($NAMESPACE_FILE):
  namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory

示例:
  nju03 500m 1000m 256Mi 1000Mi 4 8Gi
EOF
}

# ==================== 参数解析 ====================
case "${1:-}" in
-h | --help)
  show_help
  exit 0
  ;;
-l | --list)
  list_namespaces
  exit 0
  ;;
-c | --cleanup)
  [[ -z "${2:-}" ]] && {
    print_red "错误: 需要指定命名空间"
    exit 1
  }
  cleanup_namespace "$2"
  exit $?
  ;;
-v | --verify)
  [[ -z "${2:-}" ]] && {
    print_red "错误: 需要指定命名空间"
    exit 1
  }
  verify_namespace_setup "$2"
  exit $?
  ;;
--batch-cleanup)
  print_yellow "警告: 即将删除所有管理的命名空间"
  read -p "确认删除? (输入 'yes' 确认): " -r
  if [[ "$REPLY" == "yes" ]]; then
    while IFS= read -r line; do
      if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
        local namespace
        read -r namespace _ <<<"$line"
        [[ -n "$namespace" ]] || continue
        cleanup_namespace "$namespace"
      fi
    done <"$NAMESPACE_FILE"
  else
    print_blue "操作已取消"
  fi
  exit 0
  ;;
"")
  # 默认操作：创建资源
  ;;
*)
  print_red "错误: 未知选项 $1"
  show_help
  exit 1
  ;;
esac

# ==================== 执行主逻辑 ====================
print_blue "Kubernetes资源管理脚本启动"
print_blue "配置文件: $NAMESPACE_FILE"
print_blue "备份目录: $BACKUP_DIR"

check_prerequisites

print_blue "🚀 Kubernetes资源管理脚本（简化版）"

main
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
  print_green "🎉 Kubernetes资源创建成功！"
else
  print_red "❌ Kubernetes资源创建失败！"
fi

exit $exit_code