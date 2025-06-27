# MySQL 数据库部署

## 概述

本项目为 `ex3.2` 中的 Spring Boot 微服务应用提供 MySQL 数据库支持。包含用户服务 (user-service)、管理服务 (admin-service) 和注册中心 (eureka-server) 所需的数据存储。

## 项目结构

```bash
ex3.1/
├── mysql-deployment.yaml     # MySQL 服务和部署配置
├── mysql-pv.yaml            # 持久化卷配置
└── README.md                # 部署说明
```

## 数据库配置

### 连接信息

- **服务名称**: `mysql`
- **端口**: `3306`
- **数据库**: `user`
- **用户名**: `root`
- **密码**: `dangerous`
- **连接URL**: `jdbc:mysql://mysql:3306/user?charset=utf8mb4&useSSL=false&allowPublicKeyRetrieval=true`

### 微服务集成

此数据库主要为以下微服务提供数据存储：

- **user-service** (端口 9090): 用户管理服务
- **admin-service**: 管理后台服务  
- **eureka-server** (端口 8080): 服务注册中心

## 快速部署

### 前置条件

1. 确保 Kubernetes 集群可用
2. 创建数据存储目录：

```bash
sudo mkdir -p /Users/wangtianqing/data
sudo chmod 755 /Users/wangtianqing/data
```

### 部署步骤

```bash
# 1. 部署持久化存储
kubectl apply -f mysql-pv.yaml

# 2. 部署 MySQL 服务
kubectl apply -f mysql-deployment.yaml

# 3. 验证部署状态
kubectl get pods -l app=mysql
kubectl get svc mysql
```

### 验证部署

```bash
# 检查 Pod 状态
kubectl get pods -l app=mysql

# 检查服务状态  
kubectl get svc mysql

# 查看 Pod 日志
kubectl logs -l app=mysql
```

## 连接测试

### 从集群内连接

```bash
# 创建临时客户端测试连接
kubectl run mysql-client --image=mysql:8.0.33 -it --rm --restart=Never -- mysql -h mysql -u root -pdangerous
```

### 端口转发连接

```bash
# 设置端口转发到本地
kubectl port-forward svc/mysql 3306:3306

# 在另一个终端连接
mysql -h 127.0.0.1 -P 3306 -u root -pdangerous
```

## 资源清理

```bash
# 删除所有资源
kubectl delete -f mysql-deployment.yaml
kubectl delete -f mysql-pv.yaml

# 清理数据目录（可选）
sudo rm -rf /Users/wangtianqing/data/*
```

## 注意事项

- 数据存储在 `/Users/wangtianqing/data` 目录
- 默认密码为 `dangerous`，生产环境请使用 Secret 管理
- 服务名称为 `mysql`，微服务通过此名称连接数据库
