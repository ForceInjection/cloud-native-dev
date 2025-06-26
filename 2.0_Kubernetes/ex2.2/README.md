# Kubernetes Python Web 服务部署教程

## 概述

本教程演示如何在 Kubernetes 集群中部署一个简单的 Python Web 服务。我们提供了两种不同的部署方式：

1. **方式一**：使用自定义 Docker 镜像部署
2. **方式二**：使用 ConfigMap 和官方 Python 镜像部署

## 项目结构

```text
ex2.2/
├── Dockerfile                    # Docker 镜像构建文件
├── server.py                     # Python Web 服务源码
├── python-deployment.yaml        # 方式一：使用自定义镜像的部署配置
├── python-deployment2.yaml       # 方式二：使用 ConfigMap 的部署配置
├── python-service.yaml           # Service 服务配置
└── README.md                     # 本教程文档
```

## 应用介绍

### Python Web 服务功能

我们的 Python 应用是一个简单的 HTTP 服务器，具有以下特性：

- 监听端口：8000
- 功能：返回包含主机名的 HTML 页面
- 用途：演示 Kubernetes 负载均衡和多副本部署

### 服务响应示例

访问服务时，会返回类似以下内容的 HTML 页面：

```html
<html>
<body>
  <h2>Hello world, I'm host: </h2><br/>
  <h1>python-deployment-xxx-yyy</h1>
</body>
</html>
```

## 部署方式一：使用自定义 Docker 镜像

### 步骤 1：构建 Docker 镜像

首先，我们需要构建包含应用代码的 Docker 镜像：

```bash
# 进入项目目录
cd /path/to/ex2.2

# 构建 Docker 镜像
docker build -t python-server:v1 .

# 验证镜像构建成功
docker images | grep python-server
```

**Dockerfile 解析：**

```dockerfile
FROM python:3.9.19-slim    # 使用轻量级 Python 基础镜像
COPY server.py /home        # 复制应用代码到容器
WORKDIR /home              # 设置工作目录
CMD ["python", "server.py"] # 启动命令
EXPOSE 8000               # 暴露端口
```

### 步骤 2：部署应用

```bash
# 部署应用
kubectl apply -f python-deployment.yaml

# 部署服务
kubectl apply -f python-service.yaml
```

**部署配置解析（python-deployment.yaml）：**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python
  labels:
    app: python
spec:
  replicas: 10                    # 部署 10 个副本
  selector:
    matchLabels:
      app: python
  template:
    metadata:
      labels:
        app: python
    spec:
      containers:
      - name: python
        image: python-server:v1      # 使用自定义镜像
        imagePullPolicy: IfNotPresent # 镜像拉取策略
        ports:
        - containerPort: 8000
        resources:                    # 资源限制
          requests:
            cpu: 500m                # 请求 0.5 CPU
            memory: 100Mi            # 请求 100MB 内存
          limits:
            cpu: 500m                # 限制 0.5 CPU
            memory: 100Mi            # 限制 100MB 内存
```

### 步骤 3：验证部署

```bash
# 查看 Pod 状态
kubectl get pods -l app=python

# 查看 Deployment 状态
kubectl get deployment python

# 查看服务状态
kubectl get service python
```

## 部署方式二：使用 ConfigMap

这种方式不需要构建自定义镜像，而是将应用代码存储在 ConfigMap 中，然后挂载到容器内。

### 步骤 1：部署应用和 ConfigMap

```bash
# 一次性部署 ConfigMap 和 Deployment
kubectl apply -f python-deployment2.yaml

# 部署服务（如果还没有部署）
kubectl apply -f python-service.yaml
```

**配置解析（python-deployment2.yaml）：**

该文件包含两个资源：

1. **ConfigMap**：存储 Python 应用代码

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: python-program
data:
  server.py: |                    # 将 Python 代码存储在 ConfigMap 中
    import http.server
    import socketserver
    # ... 完整的 Python 代码
```

2. **Deployment**：使用官方 Python 镜像并挂载 ConfigMap

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python
spec:
  replicas: 2                     # 部署 2 个副本
  template:
    spec:
      containers:
      - name: python
        image: python:3.9.19-slim    # 使用官方 Python 镜像
        command: ["python"]
        args: ["/home/server.py"]
        volumeMounts:
        - name: python-program-volume
          mountPath: /home/server.py  # 挂载到容器内的文件路径
          subPath: server.py
      volumes:
      - name: python-program-volume
        configMap:
          name: python-program        # 引用 ConfigMap
```

### 步骤 2：验证部署

```bash
# 查看 ConfigMap
kubectl get configmap python-program
kubectl describe configmap python-program

# 查看 Pod 状态
kubectl get pods -l app=python

# 查看挂载的文件
kubectl exec -it <pod-name> -- cat /home/server.py
```

## 服务配置说明

**Service 配置解析（python-service.yaml）：**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: python
  labels:
    app: python
spec:
  type: NodePort                  # 使用 NodePort 类型
  ports:
    - port: 8000                  # 服务端口
      targetPort: 8000            # 目标端口（Pod 端口）
  selector:
    app: python                   # 选择标签为 app=python 的 Pod
```

## 访问应用

### 方法 1：使用 NodePort

```bash
# 获取 NodePort 端口
kubectl get service python

# 获取节点 IP
kubectl get nodes -o wide

# 访问应用
curl http://<NODE_IP>:<NODE_PORT>
```

### 方法 2：使用端口转发

```bash
# 端口转发
kubectl port-forward service/python 8000:8000

# 在另一个终端访问
curl http://localhost:8000
```

### 方法 3：在集群内访问

```bash
# 创建临时 Pod 进行测试
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- sh

# 在 Pod 内执行
curl http://python:8000
```

## 测试负载均衡

由于我们部署了多个副本，可以测试 Kubernetes 的负载均衡功能：

```bash
# 多次访问，观察主机名变化
for i in {1..10}; do
  curl http://localhost:8000 2>/dev/null | grep -o 'python-[^<]*'
done
```

## 监控和调试

### 查看日志

```bash
# 查看所有 Pod 的日志
kubectl logs -l app=python

# 查看特定 Pod 的日志
kubectl logs <pod-name>

# 实时查看日志
kubectl logs -f <pod-name>
```

### 进入容器调试

```bash
# 进入容器
kubectl exec -it <pod-name> -- bash

# 查看进程
kubectl exec <pod-name> -- ps aux

# 测试网络连接
kubectl exec <pod-name> -- netstat -tlnp
```

### 查看资源使用情况

```bash
# 查看 Pod 资源使用
kubectl top pods -l app=python

# 查看节点资源使用
kubectl top nodes
```

## 扩缩容操作

### 手动扩缩容

```bash
# 扩容到 15 个副本
kubectl scale deployment python --replicas=15

# 缩容到 3 个副本
kubectl scale deployment python --replicas=3

# 查看扩缩容状态
kubectl get deployment python
kubectl get pods -l app=python
```

### 自动扩缩容（HPA）

```bash
# 创建 HPA（需要 metrics-server）
kubectl autoscale deployment python --cpu-percent=50 --min=2 --max=20

# 查看 HPA 状态
kubectl get hpa
```

## 更新和回滚

### 滚动更新

```bash
# 更新镜像版本
kubectl set image deployment/python python=python-server:v2

# 查看更新状态
kubectl rollout status deployment/python

# 查看更新历史
kubectl rollout history deployment/python
```

### 回滚操作

```bash
# 回滚到上一个版本
kubectl rollout undo deployment/python

# 回滚到指定版本
kubectl rollout undo deployment/python --to-revision=1
```

## 清理资源

```bash
# 删除部署
kubectl delete deployment python

# 删除服务
kubectl delete service python

# 删除 ConfigMap（如果使用方式二）
kubectl delete configmap python-program

# 或者一次性删除所有相关资源
kubectl delete -f python-deployment.yaml
kubectl delete -f python-deployment2.yaml
kubectl delete -f python-service.yaml
```

## 两种部署方式对比

| 特性 | 方式一（自定义镜像） | 方式二（ConfigMap） |
|------|---------------------|--------------------|
| **镜像大小** | 较大（包含应用代码） | 较小（仅基础镜像） |
| **构建时间** | 需要构建镜像 | 无需构建 |
| **代码更新** | 需要重新构建镜像 | 只需更新 ConfigMap |
| **版本管理** | 通过镜像标签 | 通过 ConfigMap 版本 |
| **安全性** | 代码打包在镜像中 | 代码存储在 ConfigMap |
| **适用场景** | 生产环境，正式发布 | 开发测试，快速迭代 |
| **依赖管理** | 镜像中包含所有依赖 | 需要基础镜像包含依赖 |

## 最佳实践建议

### 1. 资源管理

- 始终设置资源请求和限制
- 根据实际负载调整 CPU 和内存配置
- 使用 HPA 实现自动扩缩容

### 2. 安全性

- 使用非 root 用户运行容器
- 定期更新基础镜像
- 使用 Secret 管理敏感信息

### 3. 监控和日志

- 配置健康检查（liveness 和 readiness probe）
- 集中化日志收集
- 设置监控和告警

### 4. 网络和服务

- 根据需求选择合适的 Service 类型
- 使用 Ingress 进行外部访问管理
- 配置网络策略增强安全性

## 故障排除

### 常见问题

1. **Pod 无法启动**

   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **服务无法访问**

   ```bash
   kubectl get endpoints python
   kubectl describe service python
   ```

3. **镜像拉取失败**

   ```bash
   # 检查镜像是否存在
   docker images | grep python-server
   
   # 修改 imagePullPolicy
   kubectl patch deployment python -p '{"spec":{"template":{"spec":{"containers":[{"name":"python","imagePullPolicy":"Never"}]}}}}'
   ```

4. **ConfigMap 挂载问题**

   ```bash
   kubectl describe configmap python-program
   kubectl exec <pod-name> -- ls -la /home/
   ```

## 总结

本教程展示了在 Kubernetes 中部署 Python Web 服务的两种方式，每种方式都有其适用场景。通过实践这些示例，您可以：

- 理解 Kubernetes Deployment 和 Service 的基本概念
- 掌握使用 ConfigMap 管理应用配置的方法
- 学会基本的 Kubernetes 运维操作
- 了解容器化应用的最佳实践

建议在学习过程中多实践，尝试修改配置参数，观察不同配置对应用行为的影响。
