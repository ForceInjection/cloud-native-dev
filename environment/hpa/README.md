# Kubernetes HPA (Horizontal Pod Autoscaler) 本地部署方案

本目录包含在本地 Kubernetes 集群中部署和配置 HPA 组件的完整解决方案，专为 Kubernetes v1.23.17 本地环境优化。

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

### 2.1 本地验证部署脚本

在开始部署之前，建议先运行验证脚本确保环境和配置正确：

```bash
# 运行部署验证脚本
./validate-deployment.sh
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

### 2.2 一键部署（推荐）

1. **部署 HPA 基础环境**：

   ```bash
   ./deploy-hpa.sh
   ```

2. **验证部署结果**：

   ```bash
   kubectl get hpa
   kubectl top nodes
   kubectl top pods
   ```

3. **运行负载测试**：

   ```bash
   ./load-test.sh
   ```

## 3. 部署方式详解

### 3.1 自动化部署脚本

`deploy-hpa.sh` 脚本会自动完成：

- 检查并部署 Metrics Server
- 部署示例应用和 HPA 配置
- 验证部署状态
- 等待所有组件就绪

```bash
# 部署 HPA 基础环境（包含 Metrics Server）
./deploy-hpa.sh
```

### 3.2 手动部署步骤

如果需要更精细的控制，可以按以下步骤手动部署：

1. **部署 Metrics Server**：

   ```bash
   kubectl apply -f metrics-server.yaml
   kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=300s
   ```

2. **验证 Metrics API**：

   ```bash
   kubectl top nodes
   kubectl top pods
   ```

3. **部署示例应用和 HPA**：

   ```bash
   kubectl apply -f hpa-example.yaml
   kubectl wait --for=condition=ready pod -l app=hpa-example --timeout=300s
   ```

4. **验证 HPA 状态**：

   ```bash
   kubectl get hpa
   kubectl describe hpa hpa-example
   ```

## 4. HPA 配置详解

### 4.1 基础 HPA 配置

基础 HPA 配置示例（来自 `hpa-example.yaml`）：

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa-demo
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-hpa-demo
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

自定义指标 HPA 配置示例（来自 `hpa-custom-metrics-example.yaml`）：

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-custom-metrics-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app-custom-metrics
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

### 5.1 部署 Prometheus Adapter

如果需要使用自定义指标，需要先部署 Prometheus Adapter：

```bash
# 运行自定义指标部署脚本
./deploy-custom-metrics.sh
```

该脚本会自动完成：

1. 检查依赖条件
2. 部署 Prometheus Adapter
3. 验证自定义指标 API
4. 部署自定义指标示例应用

### 5.2 部署自定义指标示例

```bash
# 部署自定义指标示例应用
kubectl apply -f hpa-custom-metrics-example.yaml

# 检查自定义指标 HPA 状态
kubectl get hpa web-app-custom-metrics-hpa
```

## 6. 负载测试和验证

### 6.1 使用自动化负载测试脚本

提供了专门的负载测试脚本来验证 HPA 功能：

```bash
# 运行自动化负载测试
./load-test.sh
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
kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://nginx-hpa-demo-service; done"

# 在另一个终端监控 HPA 状态
watch kubectl get hpa nginx-hpa-demo

# 监控 Pod 数量变化
watch kubectl get pods -l app=nginx-hpa-demo

# 清理负载测试
kubectl delete pod load-generator
```

## 7. 性能调优和分析

### 7.1 使用调优脚本

`hpa-tuning.sh` 提供了 HPA 性能分析和调优功能：

```bash
# 运行 HPA 性能调优脚本
./hpa-tuning.sh
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
kubectl delete -f hpa-example.yaml
kubectl delete -f hpa-custom-metrics-example.yaml

# 删除负载测试 Pod
kubectl delete pod load-generator --ignore-not-found=true
```

### 10.2 清理 Metrics Server（可选）

```bash
# 如果需要完全清理环境
kubectl delete -f metrics-server.yaml
```

## 11. 参考资源

- [Kubernetes HPA 官方文档](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Metrics Server GitHub](https://github.com/kubernetes-sigs/metrics-server)
- [HPA Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)
- [DaoCloud 镜像加速服务](https://github.com/DaoCloud/public-image-mirror)
