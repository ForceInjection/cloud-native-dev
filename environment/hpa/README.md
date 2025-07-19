# Kubernetes HPA (Horizontal Pod Autoscaler) 本地部署方案

本目录包含在本地 Kubernetes 集群中部署和配置 HPA 组件的完整解决方案，专为 Kubernetes v1.23.17 本地环境优化。

## 📁 目录结构

```bash
hpa/
├── README.md                                    # 主文档
├── quick-start.sh                              # 快速启动脚本
├── scripts/                                    # 脚本文件
│   ├── deploy-hpa.sh                           # 主部署脚本
│   ├── check-compatibility.sh                  # 兼容性检查
│   ├── validate-hpa-deployment.sh              # 部署验证
│   ├── load-test.sh                            # 负载测试
│   └── hpa-tuning.sh                           # 性能调优
├── configs/                                    # 配置文件
│   ├── metrics-server/
│   │   └── metrics-server.yaml                 # Metrics Server 配置
│   └── prometheus-adapter/
│       ├── prometheus-adapter-values.yaml      # Helm values 配置
│       └── prometheus-adapter-springboot-config.yaml # 自定义配置
└── examples/                                   # HPA 示例
    ├── hpa-basic-resource-metrics.yaml         # 基础资源指标 HPA
    ├── hpa-pod-level-custom-metrics.yaml       # Pod 级别自定义指标 HPA
    └── hpa-namespace-level-custom-metrics.yaml # Namespace 级别自定义指标 HPA
```

## 1. 环境要求

- **Kubernetes 版本**: v1.23.17
- **kubectl 版本**: v1.20+
- **部署环境**: 本地集群 (minikube, kind, k3s 等)
- **镜像加速**: 已配置 DaoCloud 镜像加速源，提升国内网络环境下的镜像拉取速度
- **前提条件**:
  - Kubernetes 集群已启动并可访问
  - kubectl 已配置并可访问集群
  - 集群节点有足够资源

### 1.1 镜像加速配置

> 🚀 **网络优化**: 本方案已针对国内网络环境进行优化，所有镜像均使用 DaoCloud 镜像加速源，相比官方源下载速度提升 5-10 倍。

**使用的加速镜像**：

- **Nginx**: `docker.m.daocloud.io/library/nginx:1.21`
- **Metrics Server**: `k8s.m.daocloud.io/metrics-server/metrics-server:v0.6.4`

**如需自定义镜像配置或故障排除，请参考**: 📖 [镜像加速配置详细文档](IMAGE_ACCELERATION.md)

## 2. 快速开始

### 2.1 使用快速启动脚本（推荐）

我们提供了 `quick-start.sh` 脚本来简化常用操作：

```bash
# 查看所有可用命令
./quick-start.sh help

# 完整部署 HPA 环境
./quick-start.sh deploy

# 验证部署状态
./quick-start.sh validate

# 部署 HPA 示例
./quick-start.sh apply-basic-hpa

# 运行负载测试
./quick-start.sh load-test
```

### 2.2 手动执行步骤

如果你更喜欢手动控制每个步骤：

1. **检查环境兼容性**：

   ```bash
   ./scripts/check-compatibility.sh
   ```

2. **本地验证部署脚本**：

   在开始部署之前，建议先运行验证脚本确保环境和配置正确：

   ```bash
   # 运行部署验证脚本
   ./scripts/validate-hpa-deployment.sh
   ```

   验证脚本会检查：

   - ✅ 环境依赖（kubectl、集群连接、版本兼容性）
   - ✅ 文件完整性和权限
   - ✅ YAML 配置语法
   - ✅ 镜像加速配置
   - ✅ 脚本语法正确性
   - ✅ 网络连通性
   - ✅ 模拟部署测试（可选）

   验证通过后会生成详细报告，确保部署过程顺利进行。

3. **一键部署 HPA 环境**：

   ```bash
   ./scripts/deploy-hpa.sh
   ```

4. **验证部署结果**：

   ```bash
   ./scripts/load-test.sh
   ```

### 2.3 一键部署（推荐）

1. **部署 HPA 基础环境**：

   ```bash
   ./scripts/deploy-hpa.sh
   ```

2. **验证部署结果**：

   ```bash
   kubectl get hpa
   kubectl top nodes
   kubectl top pods
   ```

3. **运行负载测试**：

   ```bash
   ./scripts/load-test.sh
   ```

## 3. 部署方式详解

### 3.1 自动化部署脚本

`scripts/deploy-hpa.sh` 脚本会自动完成：

- 检查并部署 Metrics Server
- 使用 Helm 和 `configs/prometheus-adapter/prometheus-adapter-values.yaml` 部署 Prometheus Adapter
- 清理冲突资源，确保部署顺利
- 验证自定义指标 API 可用性
- 提供完整的验证和使用指导

```bash
# 部署 HPA 基础环境（包含 Metrics Server）
./scripts/deploy-hpa.sh
```

### 3.2 手动部署步骤

如果需要更精细的控制，可以按以下步骤手动部署：

1. **部署 Metrics Server**：

   ```bash
   kubectl apply -f configs/metrics-server/metrics-server.yaml
   kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=300s
   ```

2. **验证 Metrics API**：

   ```bash
   kubectl top nodes
   kubectl top pods
   ```

3. **部署 Prometheus Adapter（可选，用于自定义指标）**：

   ```bash
   # 使用 Helm 和 values.yaml 文件部署
   helm repo add prometheus-community https://helm-charts.itboon.top/prometheus-community
   helm repo update
   kubectl create namespace monitor
   helm install prometheus-adapter prometheus-community/prometheus-adapter \
       --namespace monitor \
       --values configs/prometheus-adapter/prometheus-adapter-values.yaml
   ```

4. **部署示例应用和 HPA**：

   ```bash
   kubectl apply -f examples/hpa-basic-resource-metrics.yaml
   kubectl wait --for=condition=ready pod -l app=hpa-example --timeout=300s
   ```

5. **验证 HPA 状态**：

   ```bash
   kubectl get hpa
   kubectl describe hpa hpa-example
   ```

## 4. HPA 配置详解

### 4.1 基础 HPA 配置

基础 HPA 配置示例（来自 `examples/hpa-basic-resource-metrics.yaml`）：

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: prometheus-test-demo-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: prometheus-test-demo
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60
```

### 4.2 自定义指标 HPA 配置

自定义指标 HPA 配置示例（来自 `examples/hpa-pod-level-custom-metrics.yaml`）：

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: prometheus-test-demo-custom-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: prometheus-test-demo
  minReplicas: 1
  maxReplicas: 5
  metrics:
  # CPU 资源指标
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  # 自定义指标：每秒请求数
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
```

## 5. 自定义指标支持

### 5.1 Prometheus Adapter 配置文件

本方案使用 Helm 和 `configs/prometheus-adapter/prometheus-adapter-values.yaml` 配置文件来部署 Prometheus Adapter，提供更清晰、更易维护的配置管理方式。

**配置文件结构**：

```yaml
# Prometheus 连接配置
prometheus:
  url: http://monitor-kube-prometheus-st-prometheus.monitor.svc.cluster.local
  port: 9090

# 自定义指标规则配置
rules:
  custom:
    # Pod 维度指标：用于 HPA
    - seriesQuery: 'http_server_requests_seconds_count{namespace!="",pod!=""}'
      name:
        as: "http_requests_per_second"
      metricsQuery: |
        sum(rate(http_server_requests_seconds_count{<<.LabelMatchers>>}[2m])) by (namespace, pod)
    
    # Application 聚合指标：用于观测监控
    - seriesQuery: 'http_server_requests_seconds_count{namespace!="",application!=""}'
      name:
        as: "http_requests_per_second_by_app"
      metricsQuery: |
        sum(rate(http_server_requests_seconds_count{<<.LabelMatchers>>}[2m])) by (namespace, application)
```

### 5.2 部署 Prometheus Adapter

如果需要使用自定义指标，需要先部署 Prometheus Adapter：

```bash
# 运行 HPA 部署脚本（包含 Prometheus Adapter）
./scripts/deploy-hpa.sh
```

该脚本会自动完成：

1. 检查依赖条件（kubectl、helm、集群连接）
2. 部署 Metrics Server（如果未部署）
3. 清理可能的冲突资源
4. 使用 Helm 和 `configs/prometheus-adapter/prometheus-adapter-values.yaml` 部署 Prometheus Adapter
5. 验证自定义指标 API 可用性
6. 提供详细的使用指导

**手动部署方式**：

如果需要手动部署 Prometheus Adapter：

```bash
# 添加 Helm 仓库
helm repo add prometheus-community https://helm-charts.itboon.top/prometheus-community
helm repo update

# 创建命名空间
kubectl create namespace monitor

# 使用 values.yaml 部署
helm install prometheus-adapter prometheus-community/prometheus-adapter \
    --namespace monitor \
    --values configs/prometheus-adapter/prometheus-adapter-values.yaml

# 验证部署
kubectl get pods -n monitor -l app.kubernetes.io/name=prometheus-adapter
```

### 5.3 自定义配置说明

`configs/prometheus-adapter/prometheus-adapter-values.yaml` 文件包含以下关键配置：

- **Prometheus 连接**: 指向集群内的 Prometheus 服务
- **自定义指标规则**: 定义如何从 Prometheus 指标生成 Kubernetes 自定义指标
- **资源配置**: Pod 的 CPU 和内存限制
- **资源指标规则**: 支持基础的 CPU 和内存指标

**修改配置**：

如需修改配置，编辑 `configs/prometheus-adapter/prometheus-adapter-values.yaml` 文件后重新部署：

```bash
# 升级配置
helm upgrade prometheus-adapter prometheus-community/prometheus-adapter \
    --namespace monitor \
    --values configs/prometheus-adapter/prometheus-adapter-values.yaml
```

### 5.4 部署自定义指标示例

```bash
# 部署自定义指标示例应用
kubectl apply -f examples/hpa-pod-level-custom-metrics.yaml

# 检查自定义指标 HPA 状态
kubectl get hpa prometheus-test-demo-custom-hpa
```

## 6. 负载测试和验证

### 6.1 使用自动化负载测试脚本

提供了专门的负载测试脚本来验证 HPA 功能：

```bash
# 运行自动化负载测试
./scripts/load-test.sh
```

该脚本会自动完成：

1. 检查示例应用和 HPA 是否存在
2. 创建负载测试 Pod
3. 监控 HPA 扩容过程
4. 停止负载并观察缩容过程
5. 显示最终状态

### 6.2 手动负载测试

如果需要手动控制负载测试：

```bash
# 创建负载测试 Pod
kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://prometheus-test-demo:8998; done"

# 在另一个终端监控 HPA 状态
watch kubectl get hpa prometheus-test-demo-hpa

# 监控 Pod 数量变化
watch kubectl get pods -l app=prometheus-test-demo

# 清理负载测试
kubectl delete pod load-generator
```

## 7. 性能调优和分析

### 7.1 使用调优脚本

`scripts/hpa-tuning.sh` 提供了 HPA 性能分析和调优功能：

```bash
# 运行 HPA 性能调优脚本
./scripts/hpa-tuning.sh
```

### 7.2 关键调优参数

根据 Kubernetes 官方文档建议，以下参数对 HPA 性能影响较大：

1. **扩缩容策略**：
   - `scaleUp.stabilizationWindowSeconds`: 扩容稳定窗口（推荐 60-180 秒）
   - `scaleDown.stabilizationWindowSeconds`: 缩容稳定窗口（推荐 300-600 秒）

2. **指标阈值**：
   - CPU 利用率：推荐设置为 70-80%
   - 内存利用率：推荐设置为 80-90%

3. **副本数限制**：
   - `minReplicas`: 最小副本数（建议 ≥ 2 保证高可用）
   - `maxReplicas`: 最大副本数（根据资源限制设定）

### 7.3 性能监控指标

重要的监控指标包括：

- HPA 决策延迟
- 扩缩容频率
- 资源利用率趋势
- 应用响应时间

## 8. 监控和故障排除

### 8.1 常用监控命令

```bash
# 查看 HPA 状态
kubectl get hpa

# 查看 HPA 详细信息
kubectl describe hpa <hpa-name>

# 查看 HPA 事件
kubectl get events --field-selector involvedObject.kind=HorizontalPodAutoscaler

# 查看资源使用情况
kubectl top pods
kubectl top nodes

# 查看 Metrics Server 日志
kubectl logs -n kube-system -l k8s-app=metrics-server
```

### 8.2 常见问题解决

**1. HPA 显示 "unknown" 状态:**

```bash
# 检查 Metrics Server 是否正常运行
kubectl get pods -n kube-system -l k8s-app=metrics-server

# 确认目标 Pod 设置了资源请求
kubectl describe deployment <deployment-name>

# 验证 metrics API 是否可用
kubectl top pods
```

**2. 扩缩容不生效:**

```bash
# 检查指标阈值设置
kubectl describe hpa <hpa-name>

# 查看 HPA 事件日志
kubectl get events --field-selector involvedObject.name=<hpa-name>

# 检查 Pod 资源使用情况
kubectl top pods -l app=<app-label>
```

**3. Metrics Server 启动失败:**

```bash
# 查看 Metrics Server 日志
kubectl logs -n kube-system -l k8s-app=metrics-server

# 检查是否需要添加 --kubelet-insecure-tls 参数（本地环境）
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

**4. Prometheus Adapter 部署失败:**

```bash
# 检查 Helm 是否安装
helm version

# 查看 Prometheus Adapter 日志
kubectl logs -n monitor -l app.kubernetes.io/name=prometheus-adapter

# 检查 values.yaml 文件是否存在
ls -la prometheus-adapter-values.yaml

# 验证 Prometheus 连接
kubectl get pods -n monitor -l app.kubernetes.io/name=prometheus
```

**5. 自定义指标不可用:**

```bash
# 检查自定义指标 API 注册状态
kubectl get apiservices v1beta1.custom.metrics.k8s.io

# 查看可用的自定义指标
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1"

# 检查 Prometheus Adapter 配置
kubectl get configmap prometheus-adapter -n monitor -o yaml

# 重启 Prometheus Adapter
kubectl rollout restart deployment/prometheus-adapter -n monitor
```

**6. Helm 部署冲突:**

```bash
# 检查现有的 Helm releases
helm list -n monitor

# 清理冲突的资源
kubectl delete configmap prometheus-adapter -n monitor
kubectl delete deployment prometheus-adapter -n monitor
kubectl delete service prometheus-adapter -n monitor

# 重新部署
helm install prometheus-adapter prometheus-community/prometheus-adapter \
    --namespace monitor \
    --values configs/prometheus-adapter/prometheus-adapter-values.yaml
```

## 9. 自定义配置

### 9.1 修改现有 HPA

```bash
# 编辑 HPA 配置
kubectl edit hpa <hpa-name>

# 或者应用新的配置文件
kubectl apply -f your-hpa-config.yaml
```

### 9.2 应用到现有部署

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: your-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: your-deployment-name  # 修改为你的部署名称
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 10. 清理资源

### 10.1 清理示例应用

```bash
# 删除 HPA 配置
kubectl delete hpa --all

# 删除示例应用
kubectl delete -f examples/hpa-basic-resource-metrics.yaml
kubectl delete -f examples/hpa-pod-level-custom-metrics.yaml

# 删除负载测试 Pod
kubectl delete pod load-generator --ignore-not-found=true
```

### 10.2 清理 Metrics Server 和 Prometheus Adapter（可选）

```bash
# 清理 Prometheus Adapter（如果使用 Helm 部署）
helm uninstall prometheus-adapter -n monitor

# 清理 Metrics Server
kubectl delete -f configs/metrics-server/metrics-server.yaml

# 清理命名空间（如果不再需要）
kubectl delete namespace monitor
```

## 11. 参考资源

- [Kubernetes HPA 官方文档](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Metrics Server GitHub](https://github.com/kubernetes-sigs/metrics-server)
- [Prometheus Adapter GitHub](https://github.com/kubernetes-sigs/prometheus-adapter)
- [Prometheus Adapter Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-adapter)
- [HPA Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
- [Helm 官方文档](https://helm.sh/docs/)
- [DaoCloud 镜像加速服务](https://github.com/DaoCloud/public-image-mirror)
- [Kubernetes 自定义指标 API](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-custom-metrics)
