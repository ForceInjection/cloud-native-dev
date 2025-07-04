# Docker 安装脚本使用说明

> 🚀 **快速开始**: 选择您的操作系统 → [macOS](#2-macos-版本) | [Ubuntu](#3-ubuntu-版本) | [Minikube](#4-minikube-使用说明)

本目录包含了用于在不同操作系统上安装 Docker 的自动化脚本，支持 macOS 和 Ubuntu 系统，并根据网络环境自动选择合适的镜像源。

## 📋 目录

- [Docker 安装脚本使用说明](#docker-安装脚本使用说明)
  - [📋 目录](#-目录)
  - [1. 概述](#1-概述)
    - [1.1 目录结构](#11-目录结构)
    - [1.2 脚本功能对比](#12-脚本功能对比)
  - [2. macOS 版本](#2-macos-版本)
    - [2.1 快速开始](#21-快速开始)
    - [2.2 功能特性](#22-功能特性)
    - [2.3 命令行选项](#23-命令行选项)
      - [2.3.1 基本选项](#231-基本选项)
      - [2.3.2 虚拟机配置](#232-虚拟机配置)
      - [2.3.3 操作模式](#233-操作模式)
    - [2.4 使用示例](#24-使用示例)
    - [2.5 系统要求](#25-系统要求)
  - [3. Ubuntu 版本](#3-ubuntu-版本)
    - [3.1 功能特性](#31-功能特性)
      - [3.1.1 智能网络环境检测](#311-智能网络环境检测)
      - [3.1.2 支持的镜像源](#312-支持的镜像源)
      - [3.1.3 检测原理](#313-检测原理)
      - [3.1.4 镜像源对比](#314-镜像源对比)
    - [3.2 安装过程](#32-安装过程)
    - [3.3 使用方法](#33-使用方法)
      - [3.3.1 赋予执行权限](#331-赋予执行权限)
      - [3.3.2 运行安装脚本](#332-运行安装脚本)
      - [3.3.3 验证安装](#333-验证安装)
    - [3.4 安装内容](#34-安装内容)
    - [3.5 镜像加速器配置](#35-镜像加速器配置)
    - [3.6 系统要求](#36-系统要求)
    - [3.7 故障排除](#37-故障排除)
      - [3.7.1 网络连接问题](#371-网络连接问题)
      - [3.7.2 权限问题](#372-权限问题)
      - [3.7.3 GPG 密钥问题](#373-gpg-密钥问题)
  - [4. Minikube 使用说明](#4-minikube-使用说明)
    - [4.1 功能说明](#41-功能说明)
    - [4.2 使用方法](#42-使用方法)
    - [4.3 主要功能](#43-主要功能)
  - [5. 注意事项](#5-注意事项)
    - [5.1 macOS 版本](#51-macos-版本)
    - [5.2 Ubuntu 版本](#52-ubuntu-版本)
    - [5.3 通用注意事项](#53-通用注意事项)
  - [6. 相关文档](#6-相关文档)
  - [7. 技术支持](#7-技术支持)

## 1. 概述

### 1.1 目录结构

```bash
Install/
├── mac/                          # macOS 安装脚本
│   ├── install-docker.sh         # macOS Docker + Colima 安装脚本
│   ├── modules/                   # 模块化组件
│   │   ├── colima_driver.sh       # Colima 驱动管理
│   │   ├── registry_mirrors.sh    # 镜像源配置
│   │   ├── system_checks.sh       # 系统检查
│   │   ├── utils.sh               # 工具函数
│   │   └── verification.sh        # 安装验证
│   ├── config/                    # 配置文件
│   ├── logs/                      # 日志文件
│   └── README.md                  # macOS 详细说明
├── 阿里云/                        # Ubuntu/阿里云 ECS 安装脚本
│   ├── install_docker.sh          # Ubuntu Docker 安装脚本
│   └── minikube_start.sh          # Minikube 启动脚本
├── 2-安装和配置Docker环境.pdf      # 安装指南文档
├── Windows 快速安装 Docker Desktop.pdf  # Windows 安装指南
├── 通过 Minikube 安装 Kubernetes.pdf    # Kubernetes 安装指南
└── README.md                      # 本说明文档
```

### 1.2 脚本功能对比

| 特性 | macOS 版本 | Ubuntu 版本 |
|------|------------|-------------|
| **容器运行时** | Docker + Colima | Docker CE |
| **Kubernetes 支持** | ✅ 内置支持 | ⚠️ 需额外配置 |
| **镜像源优化** | ✅ DaoCloud | ✅ 阿里云镜像 |
| **网络环境检测** | ❌ | ✅ 自动检测内外网 |
| **模块化设计** | ✅ 高度模块化 | ❌ 单文件脚本 |
| **系统要求检查** | ✅ 完整检查 | ✅ 基础检查 |
| **安装验证** | ✅ 自动验证 | ✅ 基础验证 |

## 2. macOS 版本

### 2.1 快速开始

```bash
# 进入 macOS 安装目录
cd mac/

# 基本安装（推荐）
./install-docker.sh

# 安装并启用 Kubernetes
./install-docker.sh -k

# 详细输出模式
./install-docker.sh -v
```

### 2.2 功能特性

- **🐳 Docker + Colima 环境**: 基于 Colima 虚拟机的轻量级 Docker 环境
- **☸️ Kubernetes 支持**: 可选启用 Kubernetes 集群
- **🔧 智能化安装**: 自动检测系统环境和依赖
- **📊 资源配置**: 可自定义虚拟机 CPU、内存、磁盘大小
- **🔍 完整验证**: 自动验证安装结果和功能
- **📝 详细日志**: 完整的安装过程记录

### 2.3 命令行选项

#### 2.3.1 基本选项

- `-h, --help`: 显示帮助信息
- `-v, --verbose`: 启用详细输出模式
- `-q, --quiet`: 启用静默模式
- `-y, --yes`: 自动确认所有提示
- `-f, --force`: 强制重新安装
- `-k, --kubernetes`: 启用 Kubernetes 支持
- `--dry-run`: 模拟运行模式
- `--cleanup`: 执行系统清理操作

#### 2.3.2 虚拟机配置

- `-m, --memory SIZE`: 设置虚拟机内存大小（MB，默认: 2048）
- `-c, --cpu-count COUNT`: 设置虚拟机CPU核心数（默认: 2）
- `-D, --disk-size SIZE`: 设置虚拟机磁盘大小（MB，默认: 20000）

#### 2.3.3 操作模式

- `--system-check-only`: 仅运行系统兼容性检查
- `--install-only`: 仅安装 Docker 组件
- `--verify-only`: 仅运行安装验证测试
- `--uninstall`: 完全卸载 Docker 环境

### 2.4 使用示例

```bash
# 完整安装流程
./install-docker.sh

# 安装 Docker + Kubernetes
./install-docker.sh -k

# 自定义虚拟机配置
./install-docker.sh -m 4096 -c 4 -D 40000

# 模拟运行，预览将要执行的操作
./install-docker.sh --dry-run

# 仅检查系统兼容性
./install-docker.sh --system-check-only

# 执行系统清理操作
./install-docker.sh --cleanup

# 完全卸载
./install-docker.sh --uninstall
```

### 2.5 系统要求

- **操作系统**: macOS 10.15 或更高版本
- **内存**: 至少 4GB RAM（推荐 8GB+）
- **磁盘空间**: 至少 20GB 可用空间
- **依赖**: Homebrew 包管理器
- **权限**: 非 root 用户执行

## 3. Ubuntu 版本

### 3.1 功能特性

#### 3.1.1 智能网络环境检测

脚本会自动检测当前运行环境，并选择最优的镜像源：

- **阿里云内网环境**：自动使用 `mirrors.cloud.aliyuncs.com`
- **外网环境**：自动使用 `mirrors.aliyun.com`
- **手动指定**：支持通过参数手动指定镜像源

#### 3.1.2 支持的镜像源

1. **阿里云镜像源** (推荐用于阿里云ECS)
   - Docker: `https://mirrors.aliyun.com/docker-ce/linux/ubuntu`
   - 镜像加速器: `https://your-id.mirror.aliyuncs.com`

2. **官方源**
   - Docker: `https://download.docker.com/linux/ubuntu`

#### 3.1.3 检测原理

脚本通过访问阿里云元数据服务 `http://100.100.100.200/latest/meta-data/` 来判断是否运行在阿里云 ECS 实例上：

```bash
if curl -s --connect-timeout 3 http://100.100.100.200/latest/meta-data/ > /dev/null 2>&1; then
    # 阿里云内网环境
    DOCKER_MIRROR="mirrors.cloud.aliyuncs.com"
else
    # 外网环境
    DOCKER_MIRROR="mirrors.aliyun.com"
fi
```

#### 3.1.4 镜像源对比

| 环境 | 镜像源 | 优势 | 适用场景 |
|------|--------|------|----------|
| 阿里云内网 | `mirrors.cloud.aliyuncs.com` | 内网访问速度快，无流量费用 | 阿里云 ECS 实例 |
| 外网 | `mirrors.aliyun.com` | 公网可访问，稳定性好 | 本地开发环境、其他云服务商 |

### 3.2 安装过程

脚本执行以下步骤：

1. 检测系统环境和网络状况
2. 更新系统包列表
3. 安装必要的依赖包
4. 添加 Docker 官方 GPG 密钥
5. 添加 Docker 软件源
6. 安装 Docker CE
7. 配置 Docker 镜像加速器
8. 将当前用户添加到 docker 组
9. 启动并启用 Docker 服务
10. 验证安装结果

### 3.3 使用方法

#### 3.3.1 赋予执行权限

```bash
chmod +x install_docker.sh
```

#### 3.3.2 运行安装脚本

```bash
./install_docker.sh
```

#### 3.3.3 验证安装

脚本执行完成后，会自动运行 `docker version` 命令验证安装结果。

### 3.4 安装内容

脚本会自动完成以下操作：

1. **更新系统软件包**
2. **安装基础依赖**：ca-certificates、curl、gnupg、lsb-release
3. **网络环境检测**：自动选择合适的镜像源
4. **添加 Docker GPG 密钥**
5. **添加 Docker 软件源**
6. **安装 Docker 组件**：
   - docker-ce
   - docker-ce-cli
   - containerd.io
   - docker-buildx-plugin
7. **配置镜像加速器**：使用 DaoCloud 镜像加速
8. **启动 Docker 服务**

### 3.5 镜像加速器配置

脚本会自动配置 Docker 镜像加速器，提高镜像拉取速度：

```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io/"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
```

### 3.6 系统要求

- **操作系统**：Ubuntu 18.04+
- **架构**：x86_64/amd64
- **权限**：需要 sudo 权限
- **网络**：需要互联网连接

### 3.7 故障排除

#### 3.7.1 网络连接问题

如果遇到网络连接问题，可以手动指定镜像源：

```bash
# 手动设置为内网镜像源
export DOCKER_MIRROR="mirrors.cloud.aliyuncs.com"

# 手动设置为外网镜像源
export DOCKER_MIRROR="mirrors.aliyun.com"
```

#### 3.7.2 权限问题

确保当前用户具有 sudo 权限，或者使用 root 用户执行脚本。

#### 3.7.3 GPG 密钥问题

如果 GPG 密钥添加失败，可以尝试清理后重新运行：

```bash
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo rm -f /etc/apt/sources.list.d/docker.list
./install_docker.sh
```

## 4. Minikube 使用说明

### 4.1 功能说明

`minikube_start.sh` 脚本用于启动 Minikube Kubernetes 集群，适用于本地开发和测试环境。

### 4.2 使用方法

```bash
# 进入阿里云目录
cd 阿里云/

# 赋予执行权限
chmod +x minikube_start.sh

# 启动 Minikube
./minikube_start.sh
```

### 4.3 主要功能

- 启动 Minikube 集群
- 配置 Kubernetes 环境
- 验证集群状态
- 提供基本的使用指导

## 5. 注意事项

### 5.1 macOS 版本

- 确保系统版本为 macOS 10.15 或更高
- 需要预先安装 Homebrew
- 建议至少 8GB 内存用于 Kubernetes 环境
- 首次安装可能需要较长时间下载镜像

### 5.2 Ubuntu 版本

- 脚本会自动检测并选择最优镜像源，无需手动干预
- 在阿里云 ECS 上运行时，建议使用内网镜像源以获得更好的性能
- 脚本执行过程中需要网络连接，请确保网络畅通
- 安装完成后，建议重新登录或执行 `newgrp docker` 以使用户组变更生效

### 5.3 通用注意事项

- 确保网络连接稳定
- 安装过程中请勿中断脚本执行
- 如遇问题，可查看相应的日志文件进行排查
- 建议定期更新脚本以获得最新功能和修复

## 6. 相关文档

- [Docker 官方文档](https://docs.docker.com/)
- [Colima 项目](https://github.com/abiosoft/colima)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Minikube 官方文档](https://minikube.sigs.k8s.io/docs/)
- [阿里云容器镜像服务](https://cr.console.aliyun.com/)
- [DaoCloud 镜像加速器](https://www.daocloud.io/mirror)

## 7. 技术支持

如果在使用过程中遇到问题，可以：

1. 查看脚本生成的日志文件
2. 参考相关官方文档
3. 检查系统环境和网络连接
4. 尝试使用 `--dry-run` 模式预览操作
5. 使用 `--system-check-only` 检查系统兼容性
