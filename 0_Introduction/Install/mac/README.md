# 基于 Colima 虚拟机在 Mac 上搭建容器化开发环境

本文介绍了基于 Colima 虚拟机在 Mac 上搭建容器化开发环境的详细步骤，包括 Docker 和 Kubernetes 的安装配置。

## 🚀 快速开始

### 安装 Docker

```bash
# 基础安装
./install-docker.sh

# 自定义配置
./install-docker.sh -m 4096 -c 4 -D 30000
```

### 安装 Kubernetes + Docker

```bash
# 安装 K8s 环境
./install-docker.sh -k

# 推荐配置
./install-docker.sh -k -m 8192 -c 6 -D 50000
```

## 📋 系统要求

| 模式 | 内存 | CPU | 磁盘 |
|------|------|-----|------|
| Docker | 2GB+ | 2核+ | 20GB+ |
| Kubernetes | 4GB+ | 4核+ | 30GB+ |

## 🔍 方案对比

### Colima vs Docker Desktop vs VirtualBox

| 特性 | Colima | Docker Desktop | VirtualBox |
|------|--------|----------------|------------|
| **许可证** | 完全开源免费 | 商业使用需付费 | 开源免费 |
| **资源占用** | 轻量级 | 较重 | 重量级 |
| **Apple Silicon支持** | 原生支持 | 支持 | 兼容性差 |
| **启动速度** | 快 | 中等 | 慢 |
| **稳定性** | 高 | 高 | macOS上不稳定 |
| **定制性** | 高度可定制 | 有限 | 高度可定制 |
| **维护状态** | 积极维护 | 积极维护 | macOS更新慢 |
| **集成度** | 专为容器优化 | 完整生态 | 通用虚拟化 |

### 为什么选择 Colima？

- **成本优势**：完全免费，无商业许可限制
- **性能优异**：专为容器工作负载优化，资源占用更少
- **兼容性好**：在 Apple Silicon 和 Intel 芯片上都有优秀表现
- **隐私保护**：不收集用户数据，适合企业环境
- **简单易用**：命令行操作，易于自动化和脚本化

## ⚙️ 常用命令

```bash
# 系统检查
./install-docker.sh --system-check-only

# 验证安装
./install-docker.sh --verify-only

# 完全卸载
./install-docker.sh --uninstall

# 模拟运行（不实际执行）
./install-docker.sh --dry-run

# 详细输出
./install-docker.sh -v

# 强制重装
./install-docker.sh -f
```

## 🔧 日常管理

```bash
# Colima 管理
colima start/stop/restart
colima status
colima list

# Docker 测试
docker run hello-world

# Kubernetes 测试
kubectl get nodes
kubectl cluster-info
```

## 📖 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-m` | 内存大小（MB） | 4096 |
| `-c` | CPU核心数 | 2 |
| `-D` | 磁盘大小（MB） | 25000 |
| `-k` | 启用 Kubernetes | false |
| `-v` | 详细输出 | false |
| `-f` | 强制重装 | false |
| `--dry-run` | 模拟运行 | false |

### 查看日志

```bash
# 安装日志
tail -f logs/install.log

# 错误日志
tail -f logs/error.log
```

## 🚨 常见问题

### Docker 无法启动

```bash
colima restart
colima logs
```

### 镜像拉取失败

```bash
./install-docker.sh -f
docker pull hello-world
```

### Kubernetes 集群问题

```bash
colima stop
colima start --kubernetes
kubectl get nodes
```

## 📚 参考链接

- [Colima 官方文档](https://github.com/abiosoft/colima)
- [Docker 官方文档](https://docs.docker.com/)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)
