#!/bin/bash

# config template
CONFIG_TEMPLATE="config"

# 存储 namespace 信息的外部文件中
NAMESPACE_FILE="namespaces.txt"


# 检查文件是否存在
if [[ ! -f "$NAMESPACE_FILE" ]]; then
  echo "文件 $NAMESPACE_FILE 不存在！"
  exit 1
fi


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

  # 检查命名空间是否存在
  if kubectl get ns $namespace > /dev/null 2>&1; then
    print_bold "命名空间 $namespace 已存在"
  else
    # 创建命名空间
    kubectl create ns $namespace
  fi

  # 创建 resource quota
  cat <<EOF | kubectl apply -f -
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

  # 创建 limit range
  cat <<EOF | kubectl apply -f -
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
}

# 创建 sa 及相关资源
create_sa() {
  local name=$1

  # 创建 service account
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${name}
  namespace: ${name}
EOF

  # 创建 role
  cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${name}
  name: ${name}-admin-role
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
EOF

  # 创建 RoleBinding
  cat <<EOF | kubectl apply -f -
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

  # 创建 token
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${name}-secret
  annotations:
    kubernetes.io/service-account.name: ${name}
type: kubernetes.io/service-account-token
EOF
}

# 创建相关 kubectl config
create_config() {
  # name
  local name=$1

  SERVICE_ACCOUNT_NAME=${name}

  # 获取 secret 名称
  SECRET_NAME=$(kubectl get sa $SERVICE_ACCOUNT_NAME -o jsonpath='{.secrets[0].name}' -n ${name})

  print_bold "SECRET_NAME: $SECRET_NAME"

  # 获取 token
  TOKEN=$(kubectl get secret $SECRET_NAME -o jsonpath='{.data.token}' -n ${name} | base64 --decode)

  # 获取 CA 证书
  CA_CERT=$(kubectl get secret $SECRET_NAME -o jsonpath='{.data.ca\.crt}' -n ${name})

  # 获取当前的集群上下文
  CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
  CLUSTER_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

  # 生成 kubeconfig 文件
  OUTPUT_KUBECONFIG="${name}-admin-config"

  cp $CONFIG_TEMPLATE $OUTPUT_KUBECONFIG
  sed -i "s|<CLUSTER_NAME>|$CLUSTER_NAME|g" $OUTPUT_KUBECONFIG
  sed -i "s|<CLUSTER_SERVER>|$CLUSTER_SERVER|g" $OUTPUT_KUBECONFIG
  sed -i "s|<certificate-authority-data>|$CA_CERT|g" $OUTPUT_KUBECONFIG
  sed -i "s|<token>|$TOKEN|g" $OUTPUT_KUBECONFIG
  sed -i "s|<name>|$name|g" $OUTPUT_KUBECONFIG

  print_green "Kubeconfig 文件已生成: $OUTPUT_KUBECONFIG"
}

# 读取文件中的每行数据，来创建 namespace
while IFS= read -r line; do
  # 解析每行数据
  IFS=' ' read -r namespace cpu_request cpu_limit memory_request memory_limit quota_cpu quota_memory <<< "$line"

  # 调用函数创建命名空间
  print_bold "------创建命名空间 $namespace 相关资源------"
  create_namespace $namespace $cpu_request $cpu_limit $memory_request $memory_limit $quota_cpu $quota_memory
  create_sa "$namespace"
  create_config "$namespace"
  print_bold "------命名空间 $namespace 相关资源创建完毕------"

done < "$NAMESPACE_FILE"

print_green "所有 namespaces 准备完成!"