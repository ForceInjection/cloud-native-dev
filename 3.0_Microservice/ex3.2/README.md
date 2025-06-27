# Spring Boot 微服务架构示例

## 项目概述

这是一个基于 Spring Boot 和 Spring Cloud 构建的微服务架构示例项目，展示了如何使用 Eureka 服务注册与发现、OpenFeign 服务间通信以及 Kubernetes 容器化部署。

## 项目结构

```bash
ex3.2/
├── eureka-server/          # Eureka 服务注册中心
├── user-service/           # 用户服务（数据服务）
└── admin-service/          # 管理服务（业务服务）
```

## 技术栈

- **Spring Boot 2.3.x** - 微服务框架
- **Spring Cloud Hoxton.SR6** - 微服务治理
- **Eureka Server** - 服务注册与发现
- **OpenFeign** - 声明式服务调用
- **Spring Data JPA** - 数据持久化
- **MySQL** - 数据库
- **Docker** - 容器化
- **Kubernetes** - 容器编排

## 服务架构

### 1. Eureka Server (注册中心)

- **端口**: 8080
- **功能**: 服务注册与发现中心
- **配置**: 禁用自我保护机制，快速响应服务变化

### 2. User Service (用户服务)

- **端口**: 9090
- **功能**: 用户数据管理，提供用户 CRUD 操作
- **数据库**: MySQL (连接到 `mysql:3306/user`)
- **API 接口**:
  - `POST /user` - 创建用户
  - `GET /user?id={id}` - 获取用户信息
  - `GET /port` - 获取服务端口信息

### 3. Admin Service (管理服务)

- **端口**: 10000
- **功能**: 业务管理服务，通过 Feign 调用 User Service
- **API 接口**:
  - `POST /user` - 通过代理创建用户
  - `GET /user?id={id}` - 通过代理获取用户信息

## 服务间通信

```text
Admin Service --[Feign]--> User Service --[JPA]--> MySQL
       ↓                          ↓
   Eureka Client            Eureka Client
       ↓                          ↓
       └────── Eureka Server ──────┘
```

## 快速开始

### 前置条件

1. **数据库准备**

   ```bash
   # 部署 MySQL 数据库（参考 ../ex3.1/README.md）
   cd ../ex3.1
   kubectl apply -f mysql-pv.yaml
   kubectl apply -f mysql-deployment.yaml
   ```

2. **构建 Docker 镜像**

   ```bash
   # 构建 Eureka Server
   cd eureka-server
   docker build -t eureka-server:2025 .
   
   # 构建 User Service
   cd ../user-service
   docker build -t user-service:2025 .
   
   # 构建 Admin Service
   cd ../admin-service
   docker build -t admin-service:2025 .
   ```

### 部署到 Kubernetes

1. **部署 Eureka Server**

   ```bash
   cd eureka-server
   kubectl apply -f eureka-service.yaml
   kubectl apply -f eureka-deployment.yaml
   ```

2. **部署 User Service**

   ```bash
   cd ../user-service
   kubectl apply -f user-service.yaml
   kubectl apply -f user-deployment.yaml
   ```

3. **部署 Admin Service**

   ```bash
   cd ../admin-service
   kubectl apply -f admin-service.yaml
   kubectl apply -f admin-deployment.yaml
   ```

### 验证部署

```bash
# 查看所有 Pod 状态
kubectl get pods

# 查看服务状态
kubectl get services

# 查看 Eureka 注册中心
kubectl port-forward service/eureka 8080:8080
# 访问 http://localhost:8080
```

## API 使用示例

### 1. 通过 User Service 直接操作

```bash
# 端口转发
kubectl port-forward service/user-service 9090:9090

# 创建用户
curl -X POST http://localhost:9090/user \
  -H "Content-Type: application/json" \
  -d '{"name":"张三","pwd":"123456"}'

# 查询用户
curl "http://localhost:9090/user?id=1"
```

### 2. 通过 Admin Service 代理操作

```bash
# 端口转发
kubectl port-forward service/admin-service 10000:10000

# 创建用户（通过 Admin Service）
curl -X POST http://localhost:10000/user \
  -H "Content-Type: application/json" \
  -d '{"name":"李四","pwd":"654321"}'

# 查询用户（通过 Admin Service）
curl "http://localhost:10000/user?id=1"
```

## 负载均衡测试

User Service 配置了 2 个副本，可以测试负载均衡效果：

```bash
# 使用提供的压测脚本
cd user-service
./bench.sh

# 或手动测试
for i in {1..10}; do
  curl "http://localhost:10000/user?id=1"
  echo
done
```

## 监控和调试

### 查看服务日志

```bash
# 查看 Eureka Server 日志
kubectl logs -f deployment/eureka-server

# 查看 User Service 日志
kubectl logs -f deployment/user-service

# 查看 Admin Service 日志
kubectl logs -f deployment/admin-service
```

### 健康检查

```bash
# User Service 健康检查
kubectl port-forward service/user-service 8081:8081
curl http://localhost:8081/actuator/health
```

## 扩缩容操作

```bash
# 扩展 User Service 到 3 个副本
kubectl scale deployment user-service --replicas=3

# 扩展 Admin Service 到 2 个副本
kubectl scale deployment admin-service --replicas=2

# 查看扩容结果
kubectl get pods -l app=user-service
```

## 故障排除

### 常见问题

1. **服务无法注册到 Eureka**
   - 检查 Eureka Server 是否正常运行
   - 确认环境变量 `EUREKA_URL` 配置正确
   - 查看服务日志中的注册信息

2. **数据库连接失败**
   - 确认 MySQL 服务已部署并运行
   - 检查数据库连接配置（host: mysql, port: 3306）
   - 验证数据库用户名密码

3. **服务间调用失败**
   - 确认所有服务都已注册到 Eureka
   - 检查 Feign 客户端配置
   - 查看网络策略是否阻止服务间通信

### 调试命令

```bash
# 进入容器调试
kubectl exec -it deployment/user-service -- /bin/bash

# 查看服务发现状态
kubectl port-forward service/eureka 8080:8080
# 访问 http://localhost:8080 查看注册的服务

# 测试服务间网络连通性
kubectl exec -it deployment/admin-service -- curl http://user-service:9090/actuator/health
```

## 清理资源

```bash
# 删除所有微服务
kubectl delete -f admin-service/admin-deployment.yaml
kubectl delete -f admin-service/admin-service.yaml
kubectl delete -f user-service/user-deployment.yaml
kubectl delete -f user-service/user-service.yaml
kubectl delete -f eureka-server/eureka-deployment.yaml
kubectl delete -f eureka-server/eureka-service.yaml

# 删除数据库（可选）
cd ../ex3.1
kubectl delete -f mysql-deployment.yaml
kubectl delete -f mysql-pv.yaml
```

---

## 相关文档

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Spring Cloud 官方文档](https://spring.io/projects/spring-cloud)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [MySQL 数据库部署指南](../ex3.1/README.md)

---

**注意**: 本项目仅用于学习和演示目的，生产环境使用请根据实际需求进行安全加固和性能优化。
