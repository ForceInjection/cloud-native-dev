# Kubernetes 环境准备工具

本目录包含用于准备 Kubernetes 命名空间和相关资源的自动化脚本。

## 文件说明

- `prepare_ns.sh` - 主要的环境准备脚本
- `namespaces.txt` - 命名空间配置文件
- `config` - kubeconfig 模板文件

## 功能特性

### 1. 命名空间管理

- 自动创建 Kubernetes 命名空间
- 配置资源配额 (ResourceQuota)
- 设置资源限制 (LimitRange)

### 2. RBAC 权限管理

- 为每个命名空间创建专用的 ServiceAccount
- 创建命名空间级别的 Role 和 RoleBinding
- 生成访问令牌 (Token)

### 3. Kubeconfig 生成

- 自动生成每个命名空间的独立 kubeconfig 文件
- 基于模板替换配置参数
- 支持命名空间隔离访问

## 使用方法

### 1. 配置命名空间信息

编辑 `namespaces.txt` 文件，每行包含一个命名空间的配置信息：

```text
命名空间名称 CPU请求 CPU限制 内存请求 内存限制 配额CPU 配额内存
```

示例：

```text
nju03 2000m 2000m 1000Mi 1000Mi 8 16Gi
```

参数说明：

- `命名空间名称`: 要创建的命名空间名称
- `CPU请求`: 容器默认 CPU 请求量 (如: 2000m)
- `CPU限制`: 容器默认 CPU 限制量 (如: 2000m)
- `内存请求`: 容器默认内存请求量 (如: 1000Mi)
- `内存限制`: 容器默认内存限制量 (如: 1000Mi)
- `配额CPU`: 命名空间总 CPU 配额 (如: 8)
- `配额内存`: 命名空间总内存配额 (如: 16Gi)

### 2. 运行脚本

```bash
# 确保脚本有执行权限
chmod +x prepare_ns.sh

# 运行脚本
./prepare_ns.sh
```

### 3. 使用生成的 kubeconfig

脚本会为每个命名空间生成一个独立的 kubeconfig 文件，命名格式为 `{命名空间名称}-admin-config`。

使用方法：

```bash
# 使用生成的 kubeconfig
export KUBECONFIG=./nju03-admin-config

# 验证访问权限
kubectl get pods

# 或者直接指定 kubeconfig 文件
kubectl --kubeconfig=./nju03-admin-config get pods
```

## 脚本执行流程

1. **检查依赖文件**
   - 验证 `namespaces.txt` 文件是否存在
   - 检查 `config` 模板文件

2. **读取配置**
   - 解析 `namespaces.txt` 中的每行配置
   - 提取命名空间参数

3. **创建命名空间资源**
   - 创建命名空间（如果不存在）
   - 应用 ResourceQuota 配置
   - 应用 LimitRange 配置

4. **配置 RBAC**
   - 创建 ServiceAccount
   - 创建 Role（具有命名空间内的完全权限）
   - 创建 RoleBinding
   - 生成访问令牌

5. **生成 kubeconfig**
   - 获取集群信息
   - 提取 CA 证书和访问令牌
   - 基于模板生成独立的 kubeconfig 文件

## 资源配置详情

### ResourceQuota

为每个命名空间设置资源配额，限制：

- CPU 请求和限制总量
- 内存请求和限制总量

### LimitRange

为命名空间内的容器设置默认资源限制：

- 默认 CPU 请求和限制
- 默认内存请求和限制

### RBAC 权限

每个命名空间的 ServiceAccount 具有：

- 命名空间内所有资源的完全访问权限
- 仅限于指定命名空间的操作范围

## 注意事项

1. **权限要求**
   - 运行脚本需要集群管理员权限
   - 需要能够创建命名空间、RBAC 资源等

2. **文件依赖**
   - 确保 `namespaces.txt` 和 `config` 文件存在
   - 配置文件格式必须正确

3. **资源规划**
   - 合理设置资源配额，避免超出集群总容量
   - 根据实际需求调整默认资源限制

4. **安全考虑**
   - 生成的 kubeconfig 文件包含访问令牌，请妥善保管
   - 定期轮换访问令牌以提高安全性

## 故障排除

### 常见问题

1. **文件不存在错误**

   ```text
   文件 namespaces.txt 不存在！
   ```

   解决方案：确保 `namespaces.txt` 文件存在且格式正确

2. **权限不足**

   ```text
   Error from server (Forbidden): ...
   ```

   解决方案：确保当前用户具有集群管理员权限

3. **资源配额超限**

   ```text
   Error: exceeded quota
   ```

   解决方案：检查并调整资源配额设置

### 验证步骤

1. **验证命名空间创建**

   ```bash
   kubectl get namespaces
   ```

2. **验证资源配额**

   ```bash
   kubectl get resourcequota -n <namespace>
   kubectl describe resourcequota -n <namespace>
   ```

3. **验证 RBAC 配置**

   ```bash
   kubectl get sa,role,rolebinding -n <namespace>
   ```

4. **测试 kubeconfig**

   ```bash
   kubectl --kubeconfig=./<namespace>-admin-config get pods
   ```

## 扩展功能

可以根据需要扩展脚本功能：

1. **网络策略**: 添加命名空间间的网络隔离
2. **存储配额**: 限制持久卷的使用
3. **镜像策略**: 配置镜像拉取策略
4. **监控集成**: 添加监控和日志收集配置

## 清理资源

如需清理创建的资源：

```bash
# 删除命名空间（会同时删除命名空间内的所有资源）
kubectl delete namespace <namespace-name>

# 删除生成的 kubeconfig 文件
rm <namespace>-admin-config
```
