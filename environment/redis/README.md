# Redis on Kubernetes 部署文件

本目录包含在 Kubernetes 上部署单节点 Redis 的所有配置文件和脚本。

## 文件说明

### YAML 配置文件

- **`redis-deployment.yaml`** - Redis Deployment 和 Service 配置
  - 包含 Redis 7-alpine 镜像的 Deployment
  - 配置了资源限制、健康检查
  - 包含 ClusterIP 类型的 Service

- **`redis-configmap.yaml`** - Redis 自定义配置（可选）
  - 包含 Redis 配置文件
  - 设置内存限制、缓存策略等

- **`redis-network-policy.yaml`** - 网络安全策略（可选）
  - 限制对 Redis 的网络访问
  - 只允许特定标签的 Pod 访问

### 脚本文件

- **`deploy-redis.sh`** - 自动化部署脚本
  - 一键部署 Redis 到 Kubernetes
  - 等待 Pod 就绪并验证部署状态

- **`test-redis.sh`** - 功能验证测试脚本
  - 全面的 Redis 功能测试
  - 包括连接、读写、性能和故障恢复测试

- **`cleanup-redis.sh`** - 资源清理脚本
  - 清理所有 Redis 相关资源
  - 安全删除，避免影响其他服务

## 快速开始

### 1. 基本部署

```bash
# 部署 Redis
./deploy-redis.sh

# 验证部署
./test-redis.sh
```

### 2. 手动部署

```bash
# 部署基本配置
kubectl apply -f redis-deployment.yaml -n redis

# 可选：部署自定义配置
kubectl apply -f redis-configmap.yaml -n redis

# 可选：部署网络策略
kubectl apply -f redis-network-policy.yaml -n redis
```

### 3. 访问 Redis

```bash
# 方法1：临时客户端 Pod
kubectl run redis-client --rm -it --image=redis:7-alpine -n redis -- redis-cli -h redis-service -p 6379

# 方法2：端口转发
kubectl port-forward svc/redis-service 6379:6379 -n redis
redis-cli -h localhost -p 6379
```

### 4. 清理资源

```bash
# 清理所有 Redis 资源
./cleanup-redis.sh
```

## 配置说明

### 资源配置

- **CPU**: 请求 100m，限制 500m
- **内存**: 请求 128Mi，限制 512Mi
- **存储**: 无持久化存储（适合开发/测试环境）

### 健康检查

- **Liveness Probe**: TCP 端口检查
- **Readiness Probe**: Redis PING 命令检查

### 安全配置

- 默认无密码认证
- 可通过环境变量或 Secret 配置密码
- 支持网络策略限制访问

## 自定义配置

### 启用密码认证

1. 创建 Secret：

```bash
kubectl create secret generic redis-secret --from-literal=password=your-secure-password -n redis
```

2. 修改 `redis-deployment.yaml` 中的环境变量：

```yaml
env:
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: redis-secret
      key: password
```

### 使用自定义配置

1. 修改 `redis-configmap.yaml` 中的配置
2. 在 `redis-deployment.yaml` 中添加卷挂载：

```yaml
# 在 containers 部分添加
volumeMounts:
- name: redis-config
  mountPath: /usr/local/etc/redis/redis.conf
  subPath: redis.conf
command: ["redis-server", "/usr/local/etc/redis/redis.conf"]

# 在 spec.template.spec 部分添加
volumes:
- name: redis-config
  configMap:
    name: redis-config
```

## 故障排除

### 常见问题

1. **Pod 无法启动**

```bash
kubectl describe pod -l app=redis -n redis
kubectl logs -l app=redis -n redis
```

2. **无法连接 Redis**

```bash
kubectl get svc redis-service -n redis
kubectl describe svc redis-service -n redis
```

3. **健康检查失败**

```bash
kubectl describe pod -l app=redis -n redis
```

### 调试命令

```bash
# 进入容器
kubectl exec -it deployment/redis -n redis -- /bin/sh

# 检查进程
kubectl exec -it deployment/redis -n redis -- ps aux

# 检查网络
kubectl exec -it deployment/redis -n redis -- netstat -tlnp
```

## 注意事项

- 此配置适用于开发和测试环境
- 生产环境建议启用持久化存储
- 建议配置密码认证和网络策略
- 定期备份重要数据
