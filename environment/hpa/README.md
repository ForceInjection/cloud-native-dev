# Kubernetes HPA (Horizontal Pod Autoscaler) 部署方案

本目录包含在 Kubernetes 集群中部署和配置 HPA 组件的完整解决方案。

## 目录结构

```bash
hpa/
├── README.md                      # 本文件，完整的 HPA 部署方案文档
├── check-compatibility.sh         # 兼容性检查脚本
├── metrics-server.yaml            # Metrics Server 部署配置（开发/测试）
├── metrics-server-production.yaml # Metrics Server 生产环境配置
├── hpa-example.yaml               # HPA 示例配置（包含示例应用）
├── deploy-hpa.sh                  # 自动化部署脚本
└── load-test.sh                   # 负载测试脚本
```

## 环境信息

- Kubernetes 版本: v1.23.17+ (支持多版本)
- 客户端版本: v1.20+
- 支持环境: 开发、测试、生产环境

## 版本兼容性

HPA 功能已内置在 Kubernetes 中，但需要部署 metrics-server 来提供资源指标。

### 支持的 Kubernetes 版本

| K8s 版本 | HPA v2 API | 多指标支持 | 扩缩容行为 | Metrics Server 版本 | 兼容性等级 |
|----------|------------|------------|------------|-------------------|------------|
| v1.25+   | ✅ 完全支持 | ✅ 完全支持 | ✅ 完全支持 | v0.6.4           | 优秀 |
| v1.23-v1.24 | ✅ 支持 | ✅ 支持 | ✅ 支持 | v0.6.4           | 良好 |
| v1.20-v1.22 | ✅ 支持 | ⚠️ 部分支持 | ⚠️ 部分支持 | v0.5.2           | 一般 |
| v1.16-v1.19 | ⚠️ 有限支持 | ❌ 不支持 | ❌ 不支持 | v0.4.6           | 有限 |

### Metrics Server 版本选择

- **生产环境**: 推荐使用 v0.6.4，具有更好的稳定性和安全性
- **开发/测试环境**: 可使用 v0.6.4 或更新版本
- **旧版本 K8s**: 根据兼容性表选择对应版本

## 快速开始

### 前提条件

- Kubernetes 集群 (v1.16+，推荐 v1.23+)
- kubectl 已配置并可访问集群
- 集群节点有足够资源
- 对于生产环境，需要正确的 TLS 证书配置

### 兼容性检查

在部署前，建议先检查环境兼容性：

```bash
# 进入 HPA 目录
cd environment/hpa

# 基本检查
./check-compatibility.sh

# 启用调试模式（如果遇到问题）
./check-compatibility.sh --debug
```

该脚本会：

- 检查 Kubernetes 版本兼容性
- 推荐合适的 Metrics Server 配置
- 验证集群环境
- 提供部署建议

**注意**：如果脚本无法获取版本信息，调试模式会显示详细的诊断信息，帮助排查问题。

### 一键部署

```bash
# 运行自动化部署脚本
./deploy-hpa.sh
```

脚本会自动检测环境并选择合适的配置文件。

## 详细部署步骤

### 1. 部署 Metrics Server

Metrics Server 是 HPA 正常工作的前提条件，用于收集集群中 Pod 和 Node 的资源使用情况。

```bash
# 部署 metrics-server (开发/测试环境)
kubectl apply -f metrics-server.yaml

# 部署 metrics-server (生产环境)
kubectl apply -f metrics-server-production.yaml

# 等待部署完成
kubectl wait --for=condition=available --timeout=300s deployment/metrics-server -n kube-system
```

### 2. 验证 Metrics Server

部署完成后需要验证 metrics-server 是否正常工作。

```bash
# 检查 metrics-server pod 状态
kubectl get pods -n kube-system -l k8s-app=metrics-server

# 验证 metrics API 可用性
kubectl top nodes
kubectl top pods
```

### 3. 创建 HPA 配置

根据实际需求创建 HPA 资源配置。

```bash
# 部署示例应用和 HPA
kubectl apply -f hpa-example.yaml

# 检查 HPA 状态
kubectl get hpa
kubectl describe hpa nginx-hpa-demo
```

### 4. 测试 HPA 功能

通过负载测试验证 HPA 自动扩缩容功能。

```bash
# 运行负载测试
./load-test.sh
```

## 监控 HPA

```bash
# 实时监控 HPA 状态
watch kubectl get hpa

# 实时监控 Pod 数量
watch kubectl get pods -l app=nginx-hpa-demo

# 查看 HPA 事件
kubectl get events --field-selector involvedObject.kind=HorizontalPodAutoscaler
```

## HPA 配置说明

### 基本配置

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-hpa-demo
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 高级配置

- **多指标支持**: 支持 CPU、内存、自定义指标
- **扩缩容行为**: 可配置扩缩容速度和稳定窗口
- **目标类型**: 支持 Utilization 和 AverageValue

### 生产环境 HPA 配置建议

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: production-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: production-app
  minReplicas: 3  # 生产环境建议最少3个副本
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60  # 生产环境建议较低阈值
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # 5分钟稳定窗口
      policies:
      - type: Percent
        value: 10  # 每次最多缩容10%
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 60   # 1分钟稳定窗口
      policies:
      - type: Percent
        value: 50  # 每次最多扩容50%
        periodSeconds: 60
      - type: Pods
        value: 5   # 每次最多增加5个Pod
        periodSeconds: 60
      selectPolicy: Min  # 选择较保守的策略
```

### 自定义配置

#### 修改 HPA 参数

编辑 `hpa-example.yaml` 文件中的 HPA 配置：

- `minReplicas`: 最小副本数
- `maxReplicas`: 最大副本数
- `averageUtilization`: CPU/内存使用率阈值
- `behavior`: 扩缩容行为策略

#### 应用到现有部署

将 HPA 配置应用到你的现有部署：

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
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 生产环境部署

### 版本要求

- **推荐版本**: Kubernetes v1.23.17+
- **最低版本**: Kubernetes v1.16+
- **最佳体验**: Kubernetes v1.25+

### 生产环境配置

```bash
# 使用生产环境配置
kubectl apply -f metrics-server-production.yaml
```

生产环境配置特点：

- 移除了 `--kubelet-insecure-tls` 参数（需要正确的 TLS 证书）
- 增加了资源限制和容忍策略
- 优化了安全配置

### 生产环境部署注意事项

#### 安全配置

1. **TLS 证书**: 生产环境应使用正确的 TLS 证书，移除 `--kubelet-insecure-tls` 参数
2. **资源限制**: 为 metrics-server 设置合适的资源限制
3. **网络策略**: 配置适当的网络策略限制访问
4. **RBAC**: 验证服务账户权限配置

#### 高可用配置

1. **多副本**: 生产环境可考虑运行多个 metrics-server 副本
2. **节点容忍**: 配置容忍策略确保在控制平面节点上运行
3. **监控告警**: 配置 metrics-server 的监控和告警

#### 性能优化

1. **采集间隔**: 根据需要调整 `--metric-resolution` 参数
2. **资源配置**: 根据集群规模调整 CPU 和内存配置
3. **存储**: 使用高性能存储提升响应速度

## 监控和故障排除

### 常用命令

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

# 查看 metrics-server 日志
kubectl logs -n kube-system -l k8s-app=metrics-server
```

### 常见问题

1. **版本检查脚本报错**

   ```bash
   # 启用调试模式查看详细信息
   ./check-compatibility.sh --debug
   
   # 手动检查 kubectl 连接
   kubectl cluster-info
   kubectl version
   
   # 检查权限
   kubectl auth can-i get nodes
   kubectl auth can-i list apiservices
   ```

2. **HPA 显示 "unknown" 状态**
   - 检查 metrics-server 是否正常运行
   - 确认目标 Pod 设置了资源请求 (requests)
   - 验证 metrics API 是否可用

3. **扩缩容不生效**
   - 检查指标阈值设置是否合理
   - 确认扩缩容策略配置
   - 查看 HPA 事件日志

4. **频繁扩缩容**
   - 调整稳定窗口时间
   - 优化扩缩容策略
   - 检查应用负载模式

5. **Metrics Server 启动失败**
   - 检查 TLS 证书配置
   - 验证网络连接
   - 查看详细错误日志

### 生产环境监控指标

建议监控以下指标：

- HPA 状态和事件
- Pod 副本数变化
- 资源使用率趋势
- 扩缩容频率
- Metrics Server 可用性
- API 响应时间

## 最佳实践

### 开发和测试环境

1. **资源请求设置**: 确保 Pod 设置了合理的 CPU 和内存请求
2. **阈值设置**: 使用较高的阈值进行测试
3. **快速验证**: 使用负载测试快速验证功能

### 生产环境

1. **保守配置**: 使用较低的扩容阈值和较长的稳定窗口
2. **多指标**: 同时使用 CPU 和内存指标
3. **监控告警**: 配置完整的监控和告警系统
4. **容量规划**: 确保集群有足够的资源支持扩容
5. **测试验证**: 在生产环境部署前充分测试
6. **渐进式部署**: 先在部分服务上启用 HPA
7. **文档记录**: 记录配置参数和调优过程

### 版本升级

1. **兼容性检查**: 升级前运行兼容性检查脚本
2. **分阶段升级**: 先升级 metrics-server，再更新 HPA 配置
3. **回滚准备**: 准备回滚方案
4. **监控验证**: 升级后密切监控系统状态

## 文件说明

- `check-compatibility.sh`: 兼容性检查脚本
  - 支持多种版本检测方法，自动适应不同 K8s 环境
  - 提供 `--debug` 模式用于故障排查
  - 根据版本推荐合适的 Metrics Server 配置
  - 检查环境并提供部署建议
- `metrics-server.yaml`: Metrics Server 部署配置 (开发/测试环境)
  - 包含 `--kubelet-insecure-tls` 参数，简化开发环境部署
- `metrics-server-production.yaml`: Metrics Server 生产环境配置
  - 移除不安全参数，增强安全性
  - 添加资源限制，提高稳定性
- `hpa-example.yaml`: HPA 示例配置，包含示例应用和 HPA 规则
  - 包含 CPU 和内存指标的自动扩缩容配置
- `deploy-hpa.sh`: 自动化部署脚本
  - 根据环境自动选择合适的配置文件
  - 支持开发/测试和生产环境部署
- `load-test.sh`: 负载测试脚本
  - 用于测试 HPA 扩缩容功能

## 清理资源

```bash
# 删除示例应用和 HPA
kubectl delete -f hpa-example.yaml

# 删除 Metrics Server（可选）
kubectl delete -f metrics-server.yaml
# 或删除生产环境配置
kubectl delete -f metrics-server-production.yaml
```

## 支持的部署环境

- **云服务商**: AWS EKS, Google GKE, Azure AKS
- **本地部署**: kubeadm, kops, kubespray
- **开发环境**: minikube, kind, k3s
- **容器平台**: OpenShift, Rancher

## 许可证

本项目遵循 MIT 许可证。
