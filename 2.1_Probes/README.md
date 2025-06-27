# Kubernetes 探针演示项目

## 项目概述

此项目提供了一个完整的 Kubernetes 探针（Probes）学习环境，包含：

- **演示容器镜像**：基于 NGINX 的轻量级容器，支持模拟慢启动和故障场景
- **多种探针配置示例**：涵盖就绪探针、存活探针和启动探针的各种组合
- **故障注入机制**："麻烦制造者"模式用于模拟真实的故障场景
- **完整的实践指南**：从镜像构建到部署观察的全流程

## 核心概念

### 什么是 Kubernetes 探针？

Kubernetes 探针（Probes）是一种健康检查机制，用于监控容器的运行状态。kubelet 使用探针来了解何时重启容器、何时将流量路由到 Pod，以及何时认为容器已经准备好接收流量。

### 探针的工作原理

探针是由 kubelet 对容器执行的定期诊断。kubelet 通过调用由容器实现的处理程序来执行诊断：

- **ExecAction**：在容器内执行指定命令。如果命令退出时返回码为 0 则认为诊断成功
- **TCPSocketAction**：对指定端口上的容器的 IP 地址进行 TCP 检查。如果端口打开，则诊断被认为是成功的
- **HTTPGetAction**：对指定的端口和路径上的容器的 IP 地址执行 HTTP Get 请求。如果响应的状态码大于等于200 且小于 400，则诊断被认为是成功的

### 探针检查结果

每次探针检查都会得到以下三种结果之一：

- **Success（成功）**：容器通过了诊断
- **Failure（失败）**：容器未通过诊断
- **Unknown（未知）**：诊断失败，因此不会采取任何行动

### 为什么需要探针？

在微服务架构中，服务的健康状态直接影响整个系统的可用性：

1. **自动故障恢复**：当容器出现问题时，Kubernetes 可以自动重启或替换故障容器
2. **流量管理**：确保只有健康的 Pod 接收用户请求，避免请求发送到故障实例
3. **优雅启动**：保护需要较长启动时间的应用，避免过早的健康检查导致误判
4. **服务可靠性**：提高整体服务的可用性和用户体验

## 探针类型详解

### 就绪探针 (Readiness Probe)

**作用**：确定容器是否准备好接收请求

- **检查路径**：`GET /readinesscheck.txt`
- **失败影响**：Pod 会从 Service 的端点列表中移除，不再接收流量
- **适用场景**：
  - 应用需要加载配置文件
  - 需要建立数据库连接
  - 依赖外部服务初始化

### 存活探针 (Liveness Probe)

**作用**：检测容器是否正在运行

- **检查路径**：`GET /livenesscheck.txt`
- **失败影响**：kubelet 会杀死容器，并根据重启策略决定是否重启
- **适用场景**：
  - 检测应用死锁
  - 发现内存泄漏
  - 处理僵尸进程

### 启动探针 (Startup Probe)

**作用**：检测容器内的应用是否已经启动

- **检查路径**：`GET /startupcheck.txt`
- **失败影响**：容器会被杀死，并根据重启策略处理
- **特殊性**：启动探针成功后，其他探针才会接管
- **适用场景**：
  - 慢启动的遗留应用
  - 需要长时间初始化的服务

### 探针配置参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `initialDelaySeconds` | 容器启动后首次探测的延迟时间 | 0 秒 |
| `periodSeconds` | 探测的频率（间隔时间） | 10 秒 |
| `timeoutSeconds` | 探测的超时时间 | 1 秒 |
| `successThreshold` | 连续成功次数阈值 | 1 次 |
| `failureThreshold` | 连续失败次数阈值 | 3 次 |

## 探针类型对比

| 探针类型 | 检查路径 | 主要作用 | 失败后果 |
|---------|---------|----------|----------|
| 就绪探针 (Readiness) | `GET /readinesscheck.txt` | 控制流量路由 | 从 Service 端点移除 |
| 存活探针 (Liveness) | `GET /livenesscheck.txt` | 检测容器健康 | 重启容器 |
| 启动探针 (Startup) | `GET /startupcheck.txt` | 保护慢启动应用 | 重启容器（启动阶段） |

## 快速开始

### 1. 构建演示镜像

```bash
# 进入镜像目录
cd image/

# 构建镜像
docker build -t k8s-probes-demo:2024 .

# 验证镜像
docker images | grep k8s-probes-demo
```

### 2. 基础功能测试

```bash
# 运行基础容器（无延迟）
docker run -d -p 8080:80 --name probe-test k8s-probes-demo:2024

# 测试探针端点
curl http://localhost:8080/readinesscheck.txt
curl http://localhost:8080/livenesscheck.txt
curl http://localhost:8080/startupcheck.txt

# 清理
docker stop probe-test && docker rm probe-test
```

### 3. 模拟慢启动容器

```bash
# 运行带启动延迟的容器
docker run -d -p 8080:80 -e START_DELAY=30 --name slow-start k8s-probes-demo:2024

# 观察启动过程
docker logs -f slow-start
```

## Kubernetes 部署实践

### 场景一：基础探针配置

#### 1.1 仅就绪探针

```bash
# 部署仅包含就绪探针的应用
kubectl apply -f readiness-simple.yaml

# 观察 Pod 状态变化
kubectl get pods -l app=readiness-simple -w

# 查看探针检查详情
kubectl describe pod -l app=readiness-simple
```

#### 1.2 仅存活探针

```bash
# 部署仅包含存活探针的应用
kubectl apply -f liveness-simple.yaml

# 观察 Pod 重启情况
kubectl get pods -l app=liveness-simple -w
```

#### 1.3 就绪+存活探针组合

```bash
# 部署包含两种探针的应用
kubectl apply -f readiness-liveness.yaml

# 创建服务以观察流量路由
kubectl get svc readiness-liveness

# 测试服务可用性
kubectl port-forward svc/readiness-liveness 8080:80
curl http://localhost:8080
```

### 场景二：启动探针保护

```bash
# 部署包含启动探针的应用（适用于慢启动应用）
kubectl apply -f readiness-liveness-with-startup-probe.yaml

# 观察启动过程中的探针行为
kubectl get pods -l app=readiness-liveness-with-startup-probe -w

# 查看事件日志
kubectl get events --sort-by=.metadata.creationTimestamp
```

### 场景三：故障注入与观察

#### 3.1 部署故障制造者

```bash
# 部署包含故障制造者的应用
kubectl apply -f liveness-with-troublemaker.yaml

# 观察 Pod 状态的频繁变化
kubectl get pods -l app=liveness-with-troublemaker -w

# 查看故障制造者的日志
kubectl logs -l app=liveness-with-troublemaker -c troublemaker -f
```

#### 3.2 观察探针失败的影响

```bash
# 查看 Pod 重启次数
kubectl get pods -l app=liveness-with-troublemaker

# 查看详细事件
kubectl describe pod -l app=liveness-with-troublemaker

# 监控服务端点变化
kubectl get endpoints -w
```

## 重要概念说明

### Docker 与 Kubernetes 的对应关系

| Docker | Kubernetes | 说明 |
|--------|------------|------|
| `ENTRYPOINT` | `command` | 容器启动命令 |
| `CMD` | `args` | 命令参数 |

⚠️ **注意**：在 Kubernetes 中指定 `command` 时，Dockerfile 中的 `CMD` 会被忽略，必须同时提供 `args`。

## 故障制造者工作原理

### 架构设计

```text
┌─────────────────┐    ┌──────────────────┐
│   主容器        │    │  故障制造者容器   │
│   (NGINX)       │    │  (Troublemaker)  │
│                 │    │                  │
│ /usr/share/     │◄──►│ /shared/         │
│ nginx/html/     │    │                  │
└─────────────────┘    └──────────────────┘
        │                       │
        └───── 共享卷 ──────────┘
```

### 故障注入机制

故障制造者通过以下方式模拟真实的应用故障：

1. **随机文件操作**：
   - 创建进程：随机间隔创建探针文件
   - 删除进程：随机间隔删除探针文件
   - 模拟间歇性服务故障

2. **共享存储**：
   - 主容器挂载点：`/usr/share/nginx/html/`
   - 故障制造者挂载点：`/shared/`
   - 通过 `emptyDir` 卷实现文件共享

3. **影响范围**：
   - 就绪探针：影响流量路由
   - 存活探针：触发容器重启
   - 启动探针：影响启动阶段检查

## 实践练习建议

### 练习一：探针参数调优

1. 修改 `initialDelaySeconds`、`periodSeconds`、`failureThreshold` 参数
2. 观察不同配置对 Pod 行为的影响
3. 找到适合不同应用类型的最佳配置

### 练习二：故障场景模拟

1. 部署故障制造者应用
2. 观察并记录 Pod 状态变化
3. 分析探针失败对服务可用性的影响

### 练习三：监控与告警

```bash
# 监控 Pod 状态
kubectl get pods --watch

# 查看探针失败事件
kubectl get events --field-selector reason=Unhealthy

# 监控服务端点
kubectl get endpoints --watch
```

## 清理环境

```bash
# 删除所有演示应用
kubectl delete deployment --all
kubectl delete service --all

# 删除本地镜像
docker rmi k8s-probes-demo:2024
```

## 最佳实践总结

1. **启动探针**：用于保护慢启动应用，避免过早的健康检查
2. **就绪探针**：控制流量路由，确保只有准备好的 Pod 接收请求
3. **存活探针**：检测并恢复僵死容器，但要避免过于敏感的配置
4. **参数调优**：根据应用特性合理设置延迟、间隔和失败阈值
5. **监控观察**：通过日志、事件和指标监控探针行为

## 扩展学习

- 📖 查看 `Introduction-to-Kubernetes-Probes.pdf` 了解理论基础
- 🔧 尝试修改 YAML 配置文件进行更多实验
- 📊 结合 Prometheus 监控探针指标
- 🚀 在生产环境中应用学到的最佳实践
