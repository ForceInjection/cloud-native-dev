# Redis 部署文档

## 1. 文件说明

本目录包含在 Kubernetes 上部署单节点 Redis 的所有必要文件：

- `redis-deployment.yaml` - Redis Deployment 和 Service 配置
- `redis-configmap.yaml` - Redis 自定义配置（可选）
- `deploy-redis.sh` - 自动部署脚本
- `cleanup-redis.sh` - 清理脚本

## 2. 快速开始

### 2.1 一键部署

```bash
# 部署 Redis
./deploy-redis.sh

# 验证部署
kubectl get pods -n redis
kubectl get svc -n redis
```

### 2.2 手动部署

```bash
# 创建命名空间并部署
kubectl create namespace redis
kubectl apply -f redis-deployment.yaml -n redis

# 验证部署状态
kubectl get pods -n redis
```

## 3. 访问 Redis

### 3.1 同命名空间访问

```bash
# 在 redis 命名空间中创建临时客户端
kubectl run redis-client --rm -it --image=redis:7-alpine -n redis -- redis-cli -h redis-service -p 6379 ping
```

### 3.2 跨命名空间访问

**方法一：使用完整的 Service DNS 名称（推荐）:**

```bash
# 在其他命名空间访问 Redis
kubectl run redis-client --rm -it --image=redis:7-alpine -n default -- redis-cli -h redis-service.redis.svc.cluster.local -p 6379 ping
```

**方法二：在应用配置中使用完整 DNS 名称:**

在应用配置中设置 Redis 主机为：`redis-service.redis.svc.cluster.local:6379`

**方法三：端口转发（本地测试）:**

```bash
# 将 Redis 端口转发到本地
kubectl port-forward svc/redis-service 6379:6379 -n redis

# 在另一个终端连接
redis-cli -h localhost -p 6379
```

## 4. 基础测试

### 4.1 连通性测试

```bash
# DNS 解析测试
kubectl run dns-test --rm -it --image=busybox -n default -- nslookup redis-service.redis.svc.cluster.local

# 网络连通性测试
kubectl run network-test --rm -it --image=nicolaka/netshoot -n default -- nc -zv redis-service.redis.svc.cluster.local 6379

# Redis 功能测试
kubectl run redis-client --rm -it --image=redis:7-alpine -n default -- redis-cli -h redis-service.redis.svc.cluster.local -p 6379 ping
```

### 4.2 数据操作测试

```bash
# 进入交互式客户端
kubectl run redis-client --rm -it --image=redis:7-alpine -n default -- redis-cli -h redis-service.redis.svc.cluster.local -p 6379

# 在客户端中执行：
# PING
# SET mykey "Hello World"
# GET mykey
# EXIT
```

## 5. 清理资源

```bash
# 使用脚本清理
./cleanup-redis.sh

# 或手动清理
kubectl delete -f redis-deployment.yaml -n redis
kubectl delete namespace redis
```

## 6. 配置说明

### 6.1 默认配置

- **资源限制**：内存 512Mi，CPU 500m
- **健康检查**：使用 `redis-cli ping` 进行存活和就绪检查
- **安全**：默认无密码，仅集群内访问
- **存储**：使用 emptyDir（重启后数据丢失）

### 6.2 自定义配置

如需自定义 Redis 配置，编辑 `redis-configmap.yaml` 并重新部署：

```bash
kubectl apply -f redis-configmap.yaml -n redis
kubectl rollout restart deployment/redis-deployment -n redis
```

## 7. 故障排除

### 7.1 常见问题

**Pod 无法启动：**

```bash
kubectl get pods -n redis
kubectl describe pod <pod-name> -n redis
kubectl logs <pod-name> -n redis
```

**无法连接 Redis：**

```bash
kubectl get svc -n redis
kubectl get endpoints redis-service -n redis
```

**跨命名空间访问失败：**

```bash
# 检查 DNS 解析
kubectl run dns-debug --rm -it --image=busybox -n default -- nslookup redis-service.redis.svc.cluster.local

# 检查网络连通性
kubectl run network-debug --rm -it --image=nicolaka/netshoot -n default -- nc -zv redis-service.redis.svc.cluster.local 6379
```

### 7.2 调试命令

```bash
# 进入 Redis 容器
kubectl exec -it <pod-name> -n redis -- /bin/sh

# 检查 Redis 状态
kubectl exec -it <pod-name> -n redis -- redis-cli INFO server

# 查看详细日志
kubectl logs <pod-name> -n redis --tail=50 -f
```

## 8. 注意事项

### 8.1 环境适用性

- **开发/测试环境**：当前配置适用于开发和测试环境
- **生产环境**：生产环境建议启用密码认证、持久化存储和资源监控
- **数据持久化**：当前使用 emptyDir，Pod 重启后数据会丢失

### 8.2 跨命名空间访问注意事项

- **DNS 依赖**：跨命名空间访问依赖于 CoreDNS 正常运行
- **网络策略**：生产环境建议配置 NetworkPolicy 控制访问
- **RBAC 权限**：确保应用有适当的跨命名空间访问权限
- **服务发现**：建议使用配置中心或环境变量管理服务地址

### 8.3 生产环境建议

- 启用 Redis 密码认证
- 使用持久化存储（PVC）
- 配置资源监控和告警
- 考虑 Redis Cluster 或 Sentinel 实现高可用
- 定期备份数据
