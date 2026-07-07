# Linux 入门课程演示脚本

本目录包含课程所有演示脚本和配套文件，对应 `chapters/` 下的各个章节。所有 `.sh` 脚本均可独立运行。

## 脚本列表

### 01 - Linux 系统概述（无脚本，概念章节）

### 02 - Linux 基础操作

| 脚本                  | 说明                                                                             |
| --------------------- | -------------------------------------------------------------------------------- |
| `basic_commands.sh`   | 文件和目录操作 (mkdir, ls, touch)、文件查看 (cat, head, tail)、搜索 (find, grep) |
| `file_permissions.sh` | 数字/符号权限、目录权限、特殊权限 (sticky bit)、umask                            |

### 03 - 文件操作和文本处理

> 本章以命令行为主，对应 `shell_scripting.sh` 中的管道和文本处理演示。

### 04 - 进程和系统管理

| 脚本                    | 说明                                                      |
| ----------------------- | --------------------------------------------------------- |
| `process_management.sh` | 进程查看 (ps, jobs)、后台进程、系统资源监控、网络连接状态 |
| `disk_monitor.sh`       | 磁盘使用监控与告警                                        |

### 05 - 网络和安全基础

| 脚本                  | 说明                                                     |
| --------------------- | -------------------------------------------------------- |
| `network_security.sh` | 网络接口配置查看、DNS 测试、防火墙状态检查、SSH 配置查看 |

### 06 - 软件包管理

| 脚本                    | 说明                                                       |
| ----------------------- | ---------------------------------------------------------- |
| `package_management.sh` | 自动检测系统类型，演示对应的包管理器命令、源码编译安装概念 |

### 07 - Shell 脚本编程

| 脚本                 | 说明                                                         |
| -------------------- | ------------------------------------------------------------ |
| `shell_scripting.sh` | 变量和参数、条件判断、循环、数组、函数、字符串处理、管道操作 |
| `system_monitor.sh`  | 完整系统监控脚本，支持 cpu/memory/disk/network 等模式        |
| `log_analyzer.sh`    | Web 服务器日志分析工具，支持统计、状态码、IP 分析、实时监控  |
| `auto_deploy.sh`     | 自动化部署脚本，支持 deploy/rollback/status/restart 等操作   |

### 08 - 为容器技术做准备

| 脚本                         | 说明                                                             |
| ---------------------------- | ---------------------------------------------------------------- |
| `container_demo.sh`          | 容器技术基础概念演示（namespace, cgroup, union FS, Docker, K8s） |
| `check_container_support.sh` | 检查系统对容器的支持（内核特性、cgroup、Docker/K8s 状态）        |
| `container_communication.sh` | 容器间通信概念与网络模型演示                                     |
| `process_isolation_demo.sh`  | 进程隔离机制演示（namespace 对比）                               |
| `image_layers_demo.sh`       | Docker 镜像分层构建演示                                          |
| `layered_fs_demo.sh`         | OverlayFS 分层文件系统实验演示                                   |
| `k8s_concepts_demo.sh`       | Kubernetes 集群架构与核心概念演示                                |
| `k8s_storage_demo.sh`        | K8s 存储类型、PV/PVC/StorageClass 概念演示                       |
| `service_discovery_demo.sh`  | 服务发现机制演示（DNS、负载均衡）                                |

### 其他辅助文件

| 文件                         | 说明                                             |
| ---------------------------- | ------------------------------------------------ |
| `optimize_for_containers.sh` | 容器环境内核参数建议（仅展示，不修改系统）       |
| `performance_test.sh`        | CPU/内存/磁盘 I/O/网络延迟性能对比测试           |
| `resource_monitor.sh`        | 系统资源使用监控（CPU/内存/磁盘/网络）           |
| `hello.c`                    | C 语言 Hello World，用于源码编译安装演示（ch06） |
| `memory_eater.py`            | 内存消耗脚本，用于 cgroup 内存限制实验（ch08）   |
| `ssh_config`                 | SSH 客户端配置模板（ch05）                       |
| `container_learning_path.md` | 容器技术学习路径清单                             |

## 学习路径

建议按以下顺序学习：

1. `basic_commands.sh` → 熟悉基础命令（ch02）
2. `file_permissions.sh` → 理解权限管理（ch02）
3. `process_management.sh` → 学习进程管理（ch04）
4. `network_security.sh` → 了解网络配置（ch05）
5. `package_management.sh` → 掌握软件包管理（ch06）
6. `shell_scripting.sh` → 学习脚本编程基础（ch07）
7. `system_monitor.sh` → 实践系统监控（ch07）
8. `log_analyzer.sh` → 实践日志分析（ch07）
9. `auto_deploy.sh` → 实践自动化部署（ch07）
10. `container_demo.sh` → 了解容器技术基础（ch08）

## 故障排除

1. 确认脚本有执行权限：`chmod +x *.sh`
2. 部分脚本需要 root 权限，会明确提示
3. 脚本仅在 macOS 和 Linux 上测试
4. 脚本会创建临时文件，运行后自动清理（部分交互式脚本会询问是否保留）
