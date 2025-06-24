# Cgroup 和 Namespace 学习教程

## 目录

- [Cgroup 和 Namespace 学习教程](#cgroup-和-namespace-学习教程)
  - [目录](#目录)
  - [学习目标](#学习目标)
  - [第一部分：Linux Namespace 详解](#第一部分linux-namespace-详解)
    - [1.1 什么是 Namespace？](#11-什么是-namespace)
    - [1.2 Namespace 的类型](#12-namespace-的类型)
      - [1.2.1 User Namespace](#121-user-namespace)
      - [1.2.2 PID Namespace](#122-pid-namespace)
      - [1.2.3 Network Namespace](#123-network-namespace)
      - [1.2.4 Mount Namespace](#124-mount-namespace)
      - [1.2.5 IPC Namespace](#125-ipc-namespace)
      - [1.2.6 UTS Namespace](#126-uts-namespace)
    - [1.3 PID Namespace 层次结构示例](#13-pid-namespace-层次结构示例)
  - [第二部分：实践练习 - 创建 Namespace](#第二部分实践练习---创建-namespace)
    - [2.1 准备工作](#21-准备工作)
    - [2.2 使用 unshare 命令创建 Namespace](#22-使用-unshare-命令创建-namespace)
    - [2.3 验证 Namespace 创建](#23-验证-namespace-创建)
    - [2.4 从外部查看 Namespace](#24-从外部查看-namespace)
  - [第三部分：Linux Cgroup 详解](#第三部分linux-cgroup-详解)
    - [3.1 什么是 Cgroup？](#31-什么是-cgroup)
    - [3.2 Cgroup 的特性](#32-cgroup-的特性)
      - [3.2.1 资源限制](#321-资源限制)
      - [3.2.2 优先级管理](#322-优先级管理)
      - [3.2.3 资源监控](#323-资源监控)
      - [3.2.4 进程控制](#324-进程控制)
    - [3.3 Cgroup 版本](#33-cgroup-版本)
  - [第四部分：实践练习 - 创建和使用 Cgroup](#第四部分实践练习---创建和使用-cgroup)
    - [4.1 创建内存限制的 Cgroup](#41-创建内存限制的-cgroup)
    - [4.2 创建测试脚本](#42-创建测试脚本)
    - [4.3 将进程分配到 Cgroup](#43-将进程分配到-cgroup)
    - [4.4 验证 Cgroup 配置](#44-验证-cgroup-配置)
  - [第五部分：容器技术中的应用](#第五部分容器技术中的应用)
    - [5.1 Docker 中的 Namespace 和 Cgroup](#51-docker-中的-namespace-和-cgroup)
    - [5.2 Kubernetes 中的应用](#52-kubernetes-中的应用)
  - [第六部分：高级主题](#第六部分高级主题)
    - [6.1 Namespace 的嵌套](#61-namespace-的嵌套)
    - [6.2 Cgroup 的层次管理](#62-cgroup-的层次管理)
    - [6.3 性能调优建议](#63-性能调优建议)
  - [第七部分：故障排除](#第七部分故障排除)
    - [7.1 常见问题](#71-常见问题)
    - [7.2 调试工具](#72-调试工具)
  - [第八部分：实验练习](#第八部分实验练习)
    - [练习 1：创建隔离的网络环境](#练习-1创建隔离的网络环境)
    - [练习 2：实现资源限制](#练习-2实现资源限制)
    - [练习 3：模拟容器环境](#练习-3模拟容器环境)
  - [总结](#总结)
    - [关键要点](#关键要点)
    - [进一步学习](#进一步学习)
    - [参考资源](#参考资源)

## 学习目标

通过本教程，您将能够：

- 理解 Linux Namespace 和 Cgroup 的基本概念
- 掌握不同类型的 Namespace 及其作用
- 学会创建和管理 Namespace
- 理解 Cgroup 的资源控制机制
- 实践创建和配置 Cgroup
- 了解 Namespace 和 Cgroup 在容器技术中的应用

## 第一部分：Linux Namespace 详解

### 1.1 什么是 Namespace？

Namespace 是 Linux 内核提供的一种进程隔离机制，它允许不同的进程组拥有独立的系统资源视图。

**历史背景：**

- 2002年：Namespace 首次出现在 Linux 内核中
- 2013年：Linux 内核添加了真正的容器支持
- 现在：成为容器技术的核心基础

**核心特性：**

- **进程隔离**：不同 namespace 中的进程相互隔离
- **资源独立**：每个 namespace 拥有独立的系统资源视图
- **安全性**：减少不同服务之间的相互影响

### 1.2 Namespace 的类型

Linux 内核提供了多种类型的 namespace，每种都负责隔离特定的系统资源：

#### 1.2.1 User Namespace

- **功能**：隔离用户 ID 和组 ID
- **特点**：进程可以在自己的 namespace 中拥有 root 权限，而不影响其他 namespace
- **应用场景**：容器安全，非特权容器

#### 1.2.2 PID Namespace

- **功能**：隔离进程 ID 空间
- **特点**：每个 namespace 都有独立的 PID 编号，从 1 开始
- **应用场景**：容器进程隔离

#### 1.2.3 Network Namespace

- **功能**：隔离网络资源
- **包含资源**：
  - 独立的路由表
  - IP 地址集
  - 套接字列表
  - 连接跟踪表
  - 防火墙规则

#### 1.2.4 Mount Namespace

- **功能**：隔离文件系统挂载点
- **特点**：可以在 namespace 内挂载/卸载文件系统，不影响主机
- **应用场景**：容器文件系统隔离

#### 1.2.5 IPC Namespace

- **功能**：隔离进程间通信资源
- **包含资源**：消息队列、信号量、共享内存

#### 1.2.6 UTS Namespace

- **功能**：隔离主机名和域名
- **特点**：不同进程可以看到不同的主机名

### 1.3 PID Namespace 层次结构示例

```text
父 Namespace
├── PID 1 (init)
├── PID 2 ──→ 子 Namespace A (PID 1)
├── PID 3 ──→ 子 Namespace B (PID 1)
└── PID 4
```

**关键特点：**

- 父 namespace 可以看到所有进程
- 子 namespace 只能看到自己内部的进程
- 子 namespace 中的 PID 1 看不到父 namespace 中的其他进程

## 第二部分：实践练习 - 创建 Namespace

### 2.1 准备工作

首先检查当前用户身份：

```bash
$ id
uid=1000(user) gid=1000(user) groups=1000(user)
```

### 2.2 使用 unshare 命令创建 Namespace

**命令解释：**

```bash
unshare --user --pid --map-root-user --mount-proc --fork bash
```

**参数说明：**

- `--user`：创建新的 user namespace
- `--pid`：创建新的 PID namespace
- `--map-root-user`：将当前用户映射为新 namespace 中的 root
- `--mount-proc`：挂载新的 proc 文件系统
- `--fork`：fork 一个新进程

### 2.3 验证 Namespace 创建

**在新 namespace 中执行：**

```bash
# 查看进程列表
ps -ef
UID         PID     PPID  C STIME TTY        TIME CMD
root          1        0  0 14:46 pts/0  00:00:00 bash
root         15        1  0 14:46 pts/0  00:00:00 ps -ef

# 确认用户身份
id
uid=0(root) gid=0(root) groups=0(root)
```

**观察结果：**

- 只能看到 namespace 内的进程
- 当前用户变成了 root
- 进程完全隔离

### 2.4 从外部查看 Namespace

在另一个终端中执行：

```bash
# 列出所有 namespace
lsns --output-all | head -1; lsns --output-all | grep user
```

## 第三部分：Linux Cgroup 详解

### 3.1 什么是 Cgroup？

Cgroup（Control Groups）是 Linux 内核提供的一种机制，用于限制、记录和隔离进程组的资源使用。

**核心功能：**

- **资源限制**：限制进程对 CPU、内存、磁盘 I/O、网络的使用
- **优先级控制**：管理资源分配的优先级
- **资源监控**：记录和报告资源使用情况
- **进程控制**：统一管理进程组的状态

### 3.2 Cgroup 的特性

#### 3.2.1 资源限制

- 内存使用限制
- CPU 使用限制
- 磁盘 I/O 限制
- 网络带宽限制

#### 3.2.2 优先级管理

- CPU 调度优先级
- 内存分配优先级
- I/O 调度优先级

#### 3.2.3 资源监控

- 实时资源使用统计
- 历史使用数据记录
- 资源使用报告

#### 3.2.4 进程控制

- 批量进程管理
- 进程状态控制（冻结、停止、重启）

### 3.3 Cgroup 版本

**Cgroup v1（2007-2008）：**

- 首个版本，功能基础
- 层次结构相对复杂

**Cgroup v2（2016）：**

- 简化的树形结构
- 改进的接口设计
- 更好的 rootless 容器支持

## 第四部分：实践练习 - 创建和使用 Cgroup

### 4.1 创建内存限制的 Cgroup

**步骤 1：创建 cgroup 目录：**

```bash
sudo mkdir -p /sys/fs/cgroup/memory/demo-group
```

**步骤 2：设置内存限制（50MB）：**

```bash
echo 50000000 | sudo tee /sys/fs/cgroup/memory/demo-group/memory.limit_in_bytes
```

### 4.2 创建测试脚本

创建 `test-memory.sh` 脚本：

```bash
#!/bin/bash
echo "进程 PID: $$"
echo "开始内存测试..."
sleep 20s
# 这里可以添加内存消耗程序
echo "测试完成"
```

### 4.3 将进程分配到 Cgroup

**步骤 1：启动测试脚本：**

```bash
./test-memory.sh &
[1] 12345
```

**步骤 2：将进程添加到 cgroup：**

```bash
echo 12345 | sudo tee /sys/fs/cgroup/memory/demo-group/cgroup.procs
```

### 4.4 验证 Cgroup 配置

**查看进程所属的 cgroup：**

```bash
ps -o cgroup 12345
CGROUP
6:memory:/demo-group,...
```

**监控内存使用：**

```bash
cat /sys/fs/cgroup/memory/demo-group/memory.usage_in_bytes
```

## 第五部分：容器技术中的应用

### 5.1 Docker 中的 Namespace 和 Cgroup

Docker 容器运行时自动创建和管理 namespace 和 cgroup：

**Namespace 使用：**

- PID namespace：进程隔离
- Network namespace：网络隔离
- Mount namespace：文件系统隔离
- User namespace：用户权限隔离

**Cgroup 使用：**

- 内存限制：`docker run -m 512m`
- CPU 限制：`docker run --cpus="1.5"`
- I/O 限制：`docker run --device-read-bps`

### 5.2 Kubernetes 中的应用

**Pod 级别的资源管理：**

```yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    resources:
      limits:
        memory: "512Mi"
        cpu: "500m"
      requests:
        memory: "256Mi"
        cpu: "250m"
```

## 第六部分：高级主题

### 6.1 Namespace 的嵌套

- User namespace 可以嵌套
- PID namespace 支持层次结构
- 嵌套 namespace 提供更细粒度的隔离

### 6.2 Cgroup 的层次管理

```text
/sys/fs/cgroup/memory/
├── system.slice/
│   ├── docker.service/
│   └── kubelet.service/
├── user.slice/
│   └── user-1000.slice/
└── machine.slice/
    ├── docker-container1.scope
    └── docker-container2.scope
```

### 6.3 性能调优建议

**Namespace 优化：**

- 合理选择需要的 namespace 类型
- 避免不必要的 namespace 创建
- 监控 namespace 的资源开销

**Cgroup 优化：**

- 根据应用特点设置合适的资源限制
- 使用 cgroup v2 获得更好的性能
- 定期监控和调整资源配置

## 第七部分：故障排除

### 7.1 常见问题

**问题 1：权限不足：**

```bash
# 错误信息
unshare: unshare failed: Operation not permitted

# 解决方案
sudo unshare --user --pid --map-root-user --mount-proc --fork bash
```

**问题 2：Cgroup 挂载点不存在：**

```bash
# 检查 cgroup 挂载
mount | grep cgroup

# 手动挂载（如果需要）
sudo mount -t cgroup -o memory cgroup /sys/fs/cgroup/memory
```

### 7.2 调试工具

**查看 namespace：**

```bash
lsns                    # 列出所有 namespace
readlink /proc/self/ns/* # 查看当前进程的 namespace
```

**查看 cgroup：**

```bash
systemd-cgls            # 查看 cgroup 树
systemd-cgtop           # 实时监控 cgroup 资源使用
```

## 第八部分：实验练习

### 练习 1：创建隔离的网络环境

**目标：**创建一个具有独立网络栈的 namespace

**步骤：**

1. 创建 network namespace
2. 配置虚拟网络接口
3. 测试网络隔离效果

### 练习 2：实现资源限制

**目标：**创建一个内存和 CPU 都受限的进程组

**步骤：**

1. 创建 memory 和 cpu cgroup
2. 设置资源限制
3. 运行测试程序验证限制效果

### 练习 3：模拟容器环境

**目标：**使用 namespace 和 cgroup 手动创建类似容器的隔离环境

**步骤：**

1. 组合使用多种 namespace
2. 配置相应的 cgroup 限制
3. 在隔离环境中运行应用程序

## 总结

### 关键要点

1. **Namespace 提供隔离**：
   - 进程隔离是容器技术的基础
   - 不同类型的 namespace 隔离不同的系统资源
   - namespace 支持嵌套和层次结构

2. **Cgroup 提供控制**：
   - 精确控制资源使用量
   - 支持资源监控和统计
   - 是容器资源管理的核心机制

3. **容器技术的基石**：
   - Docker、Podman 等容器运行时的底层技术
   - Kubernetes 资源管理的基础
   - 现代云原生应用的重要支撑

### 进一步学习

- 深入学习容器运行时（containerd、CRI-O）
- 研究 Kubernetes 的资源管理机制
- 探索安全容器技术（gVisor、Kata Containers）
- 学习容器编排和调度算法

### 参考资源

- [Linux Manual Pages](https://man7.org/linux/man-pages/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Container Runtime Interface](https://github.com/kubernetes/cri-api)

---

**注意：**本教程中的所有命令都应在安全的测试环境中执行，避免在生产系统上进行实验。
