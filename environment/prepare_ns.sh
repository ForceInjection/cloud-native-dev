#!/bin/bash

# 严格错误处理
set -euo pipefail

# 配置变量
CONFIG_TEMPLATE="config"
NAMESPACE_FILE="namespaces.txt"
LOG_FILE="prepare_ns_$(date +%Y%m%d_%H%M%S).log"

# 日志函数
log() {
  local level="$1"
  local message="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# 检查先决条件
check_prerequisites() {
  # 检查 kubectl 可用性
  if ! command -v kubectl &>/dev/null; then
    log "ERROR" "kubectl 未安装或不在 PATH 中"
    exit 1
  fi

  # 检查集群连接
  if ! kubectl cluster-info &>/dev/null; then
    log "ERROR" "无法连接到 Kubernetes 集群"
    exit 1
  fi

  # 检查必要文件
  if [[ ! -f "$NAMESPACE_FILE" ]]; then
    log "ERROR" "文件 $NAMESPACE_FILE 不存在！"
    exit 1
  fi

  if [[ ! -f "$CONFIG_TEMPLATE" ]]; then
    log "ERROR" "配置模板文件 $CONFIG_TEMPLATE 不存在！"
    exit 1
  fi

  log "INFO" "先决条件检查通过"
}

# 验证资源配置参数
validate_resources() {
  local cpu_request=$1 cpu_limit=$2 memory_request=$3 memory_limit=$4

  # 验证 CPU 格式
  if ! [[ $cpu_request =~ ^[0-9]+m?$ ]] || ! [[ $cpu_limit =~ ^[0-9]+m?$ ]]; then
    log "ERROR" "CPU 配置格式无效: $cpu_request, $cpu_limit"
    return 1
  fi

  # 验证内存格式
  if ! [[ $memory_request =~ ^[0-9]+(Mi|Gi)$ ]] || ! [[ $memory_limit =~ ^[0-9]+(Mi|Gi)$ ]]; then
    log "ERROR" "内存配置格式无效: $memory_request, $memory_limit"
    return 1
  fi

  return 0
}

# 增强的 kubectl 执行函数
execute_kubectl() {
  local description="$1"
  shift

  if "$@" &>>"$LOG_FILE"; then
    log "INFO" "成功: $description"
    return 0
  else
    log "ERROR" "失败: $description"
    return 1
  fi
}

# 跨平台兼容的 sed 操作
sed_inplace() {
  local pattern="$1"
  local file="$2"

  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$pattern" "$file"
  else
    sed -i "$pattern" "$file"
  fi
}

# 执行先决条件检查
check_prerequisites

function print_red() {
  echo -e "\x1b[1;31m$1\x1b[0m"
}

function print_green() {
  echo -e "\x1b[1;32m$1\x1b[0m"
}

function print_bold() {
  echo -e "\033[1;m$1\033[0m"
}

# 创建 namespaces，指定 resource quota 和 limit ranger
create_namespace() {
  local namespace=$1
  local cpu_request=$2
  local cpu_limit=$3
  local memory_request=$4
  local memory_limit=$5
  local quota_cpu=$6
  local quota_memory=$7

  # 验证资源配置
  if ! validate_resources "$cpu_request" "$cpu_limit" "$memory_request" "$memory_limit"; then
    log "ERROR" "命名空间 $namespace 的资源配置验证失败"
    return 1
  fi

  # 检查命名空间是否存在
  if kubectl get ns "$namespace" >/dev/null 2>&1; then
    log "INFO" "命名空间 $namespace 已存在"
  else
    # 创建命名空间
    if ! execute_kubectl "创建命名空间 $namespace" kubectl create ns "$namespace"; then
      return 1
    fi
  fi

  # 创建 resource quota
  if ! execute_kubectl "创建 ResourceQuota" kubectl apply -f - <<EOF; then
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${namespace}-quota
  namespace: $namespace
spec:
  hard:
    requests.cpu: "$quota_cpu"
    requests.memory: "$quota_memory"
    limits.cpu: "$quota_cpu"
    limits.memory: "$quota_memory"
EOF
    return 1
  fi

  # 创建 limit range
  if ! execute_kubectl "创建 LimitRange" kubectl apply -f - <<EOF; then
apiVersion: v1
kind: LimitRange
metadata:
  name: ${namespace}-limits
  namespace: $namespace
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
    return 1
  fi

  log "INFO" "命名空间 $namespace 资源配置完成"
  return 0
}

# 创建 sa 及相关资源
create_sa() {
  local name=$1

  log "INFO" "开始创建 ServiceAccount 和 RBAC 资源: $name"

  # 创建 service account
  if ! execute_kubectl "创建 ServiceAccount" kubectl apply -f - <<EOF; then
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${name}
  namespace: ${name}
EOF
    return 1
  fi

  # 创建 role（使用最小权限原则）
  if ! execute_kubectl "创建 Role" kubectl apply -f - <<EOF; then
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${name}
  name: ${name}-admin-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets", "persistentvolumeclaims", "events"]
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
EOF
    return 1
  fi

  # 创建 RoleBinding
  if ! execute_kubectl "创建 RoleBinding" kubectl apply -f - <<EOF; then
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${name}-admin-role-binding
  namespace: ${name}
subjects:
- kind: ServiceAccount
  name: ${name}
  namespace: ${name}
roleRef:
  kind: Role
  name: ${name}-admin-role
  apiGroup: rbac.authorization.k8s.io
EOF
    return 1
  fi

  # 创建 token secret
  if ! execute_kubectl "创建 Token Secret" kubectl apply -f - <<EOF; then
apiVersion: v1
kind: Secret
metadata:
  name: ${name}-secret
  namespace: ${name}
  annotations:
    kubernetes.io/service-account.name: ${name}
type: kubernetes.io/service-account-token
EOF
    return 1
  fi

  log "INFO" "ServiceAccount 和 RBAC 资源创建完成: $name"
  return 0
}

# 创建相关 kubectl config
create_config() {
  local name=$1
  local max_retries=5
  local retry_count=0

  log "INFO" "开始生成 kubeconfig 文件: $name"

  # 等待 secret 创建完成并重试机制
  local SECRET_NAME
  while [[ $retry_count -lt $max_retries ]]; do
    SECRET_NAME=$(kubectl get secret "${name}-secret" -n "${name}" -o name 2>/dev/null | cut -d'/' -f2)
    if [[ -n "$SECRET_NAME" ]]; then
      break
    fi
    log "WARN" "等待 secret 创建完成，重试 $((retry_count + 1))/$max_retries"
    sleep 2
    ((retry_count++))
  done

  if [[ -z "$SECRET_NAME" ]]; then
    log "ERROR" "无法获取 secret 名称: ${name}-secret"
    return 1
  fi

  log "INFO" "找到 SECRET_NAME: $SECRET_NAME"

  # 获取 token
  local TOKEN
  TOKEN=$(kubectl get secret "$SECRET_NAME" -o jsonpath='{.data.token}' -n "${name}" 2>/dev/null | base64 --decode)
  if [[ -z "$TOKEN" ]]; then
    log "ERROR" "无法获取访问令牌"
    return 1
  fi

  # 获取 CA 证书
  local CA_CERT
  CA_CERT=$(kubectl get secret "$SECRET_NAME" -o jsonpath='{.data.ca\.crt}' -n "${name}" 2>/dev/null)
  if [[ -z "$CA_CERT" ]]; then
    log "ERROR" "无法获取 CA 证书"
    return 1
  fi

  # 获取当前的集群上下文
  local CLUSTER_NAME CLUSTER_SERVER
  CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}' 2>/dev/null)
  CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null)

  if [[ -z "$CLUSTER_NAME" ]] || [[ -z "$CLUSTER_SERVER" ]]; then
    log "ERROR" "无法获取集群信息"
    return 1
  fi

  # 生成 kubeconfig 文件
  local OUTPUT_KUBECONFIG="${name}-admin-config"

  if ! cp "$CONFIG_TEMPLATE" "$OUTPUT_KUBECONFIG"; then
    log "ERROR" "无法复制配置模板"
    return 1
  fi

  # 使用跨平台兼容的 sed 操作
  sed_inplace "s|<CLUSTER_NAME>|$CLUSTER_NAME|g" "$OUTPUT_KUBECONFIG"
  sed_inplace "s|<CLUSTER_SERVER>|$CLUSTER_SERVER|g" "$OUTPUT_KUBECONFIG"
  sed_inplace "s|<certificate-authority-data>|$CA_CERT|g" "$OUTPUT_KUBECONFIG"
  sed_inplace "s|<token>|$TOKEN|g" "$OUTPUT_KUBECONFIG"
  sed_inplace "s|<name>|$name|g" "$OUTPUT_KUBECONFIG"

  # 设置安全权限
  chmod 600 "$OUTPUT_KUBECONFIG"

  # 验证生成的 kubeconfig
  if kubectl --kubeconfig="$OUTPUT_KUBECONFIG" get pods -n "$name" &>/dev/null; then
    log "INFO" "Kubeconfig 文件已生成并验证成功: $OUTPUT_KUBECONFIG"
  else
    log "WARN" "Kubeconfig 文件已生成但验证失败，可能需要等待权限生效: $OUTPUT_KUBECONFIG"
  fi

  return 0
}

# 验证命名空间设置
verify_namespace_setup() {
  local namespace="$1"

  # 验证命名空间存在
  if ! kubectl get namespace "$namespace" &>/dev/null; then
    log "ERROR" "命名空间 $namespace 不存在"
    return 1
  fi

  # 验证 ResourceQuota
  if ! kubectl get resourcequota "${namespace}-quota" -n "$namespace" &>/dev/null; then
    log "ERROR" "ResourceQuota 未正确创建"
    return 1
  fi

  # 验证 LimitRange
  if ! kubectl get limitrange "${namespace}-limits" -n "$namespace" &>/dev/null; then
    log "ERROR" "LimitRange 未正确创建"
    return 1
  fi

  # 验证 ServiceAccount
  if ! kubectl get serviceaccount "$namespace" -n "$namespace" &>/dev/null; then
    log "ERROR" "ServiceAccount 未正确创建"
    return 1
  fi

  log "INFO" "命名空间 $namespace 验证通过"
  return 0
}

# 处理单个命名空间
process_namespace() {
  local line="$1"
  local namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory

  # 跳过空行和注释行
  if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
    return 0
  fi

  # 解析每行数据
  IFS=' ' read -r namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory <<<"$line"

  # 验证必要参数
  if [[ -z "$namespace" ]] || [[ -z "$cpu_request" ]] || [[ -z "$cpu_limit" ]] ||
    [[ -z "$memory_request" ]] || [[ -z "$memory_limit" ]] ||
    [[ -z "$quota_cpu" ]] || [[ -z "$quota_memory" ]]; then
    log "ERROR" "配置行格式错误: $line"
    return 1
  fi

  log "INFO" "======开始处理命名空间 $namespace======"

  # 创建命名空间资源
  if ! create_namespace "$namespace" "$cpu_request" "$cpu_limit" "$memory_request" "$memory_limit" "$quota_cpu" "$quota_memory"; then
    log "ERROR" "创建命名空间 $namespace 失败"
    return 1
  fi

  # 创建 ServiceAccount 和 RBAC
  if ! create_sa "$namespace"; then
    log "ERROR" "创建 ServiceAccount $namespace 失败"
    return 1
  fi

  # 生成 kubeconfig
  if ! create_config "$namespace"; then
    log "ERROR" "生成 kubeconfig $namespace 失败"
    return 1
  fi

  # 验证设置
  if ! verify_namespace_setup "$namespace"; then
    log "ERROR" "验证命名空间 $namespace 失败"
    return 1
  fi

  log "INFO" "======命名空间 $namespace 处理完成======"
  return 0
}

# 主处理逻辑
main() {
  local success_count=0
  local failure_count=0
  local total_count=0

  log "INFO" "开始处理命名空间配置文件: $NAMESPACE_FILE"

  # 读取文件中的每行数据，来创建 namespace
  while IFS= read -r line; do
    ((total_count++))

    if process_namespace "$line"; then
      ((success_count++))
    else
      ((failure_count++))
      log "ERROR" "处理失败，继续下一个命名空间"
    fi

  done <"$NAMESPACE_FILE"

  # 输出处理结果统计
  log "INFO" "处理完成 - 总计: $total_count, 成功: $success_count, 失败: $failure_count"

  if [[ $failure_count -eq 0 ]]; then
    log "INFO" "所有命名空间准备完成！"
    return 0
  else
    log "WARN" "部分命名空间处理失败，请检查日志: $LOG_FILE"
    return 1
  fi
}

# 清理函数
cleanup_namespace() {
  local namespace="$1"

  if [[ -z "$namespace" ]]; then
    log "ERROR" "清理函数需要命名空间参数"
    return 1
  fi

  log "INFO" "开始清理命名空间: $namespace"

  # 删除 kubeconfig 文件
  local config_file="${namespace}.config"
  if [[ -f "$config_file" ]]; then
    rm -f "$config_file"
    log "INFO" "已删除 kubeconfig 文件: $config_file"
  fi

  # 删除命名空间（会级联删除所有资源）
  if kubectl get namespace "$namespace" &>/dev/null; then
    execute_kubectl "delete namespace $namespace"
    log "INFO" "已删除命名空间: $namespace"
  else
    log "WARN" "命名空间 $namespace 不存在，跳过删除"
  fi
}

# 显示帮助信息
show_help() {
  cat <<EOF
用法: $0 [选项]

选项:
  -h, --help     显示此帮助信息
  -c, --cleanup  清理指定的命名空间
  -l, --list     列出所有管理的命名空间
  -v, --verify   验证指定命名空间的设置

示例:
  $0                    # 创建所有命名空间
  $0 -c nju03          # 清理 nju03 命名空间
  $0 -l                # 列出所有命名空间
  $0 -v nju03          # 验证 nju03 命名空间

EOF
}

# 列出所有管理的命名空间
list_namespaces() {
  log "INFO" "管理的命名空间列表:"
  while IFS= read -r line; do
    if [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      local namespace
      IFS=' ' read -r namespace _ <<<"$line"
      if [[ -n "$namespace" ]]; then
        local status="不存在"
        if kubectl get namespace "$namespace" &>/dev/null; then
          status="存在"
        fi
        printf "  %-20s %s\n" "$namespace" "$status"
      fi
    fi
  done <"$NAMESPACE_FILE"
}

# 信号处理函数
cleanup_on_exit() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    log "ERROR" "脚本异常退出，退出码: $exit_code"
  fi
  exit $exit_code
}

# 设置信号处理
trap cleanup_on_exit EXIT
trap 'log "WARN" "收到中断信号，正在退出..."; exit 130' INT TERM

# 参数解析
while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    show_help
    exit 0
    ;;
  -c | --cleanup)
    if [[ -z "$2" ]]; then
      log "ERROR" "清理选项需要指定命名空间名称"
      exit 1
    fi
    cleanup_namespace "$2"
    exit $?
    ;;
  -l | --list)
    list_namespaces
    exit 0
    ;;
  -v | --verify)
    if [[ -z "$2" ]]; then
      log "ERROR" "验证选项需要指定命名空间名称"
      exit 1
    fi
    verify_namespace_setup "$2"
    exit $?
    ;;
  *)
    log "ERROR" "未知选项: $1"
    show_help
    exit 1
    ;;
  esac
done

# 执行主逻辑
main
exit_code=$?

# 根据执行结果设置退出码
if [[ $exit_code -eq 0 ]]; then
  log "INFO" "脚本执行成功完成"
else
  log "ERROR" "脚本执行失败，请检查日志: $LOG_FILE"
fi

exit $exit_code
