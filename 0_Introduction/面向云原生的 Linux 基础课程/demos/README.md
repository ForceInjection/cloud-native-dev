# Linux 入门课程演示脚本

本目录包含了《Linux 入门》课程的所有演示脚本，这些脚本对应课程文档中的各个章节，可以独立运行来演示相关的 Linux 概念和命令。

## 一、脚本列表

### 1. basic_commands.sh

**对应章节**: 第二章 - Linux 基础操作

**功能**: 演示 Linux 基础命令的使用

- 文件和目录操作 (mkdir, ls, touch, etc.)
- 文件查看命令 (cat, head, tail)
- 文件搜索 (find, grep)
- 文件权限基础

**使用方法**:

```bash
chmod +x basic_commands.sh
./basic_commands.sh
```

### 2. file_permissions.sh

**对应章节**: 第三章 - 文件系统和权限管理

**功能**: 详细演示文件权限管理

- 数字权限和符号权限
- 目录权限
- 特殊权限 (sticky bit)
- umask 概念

**使用方法**:

```bash
chmod +x file_permissions.sh
./file_permissions.sh
```

### 3. process_management.sh

**对应章节**: 第四章 - 进程和系统管理

**功能**: 演示进程管理和系统监控

- 进程查看 (ps, jobs)
- 后台进程管理
- 系统资源监控
- 网络连接状态

**使用方法**:

```bash
chmod +x process_management.sh
./process_management.sh
```

### 4. network_security.sh

**对应章节**: 第五章 - 网络配置和安全基础

**功能**: 演示网络配置和安全检查

- 网络接口配置查看
- DNS 配置和测试
- 网络连通性测试
- 防火墙状态检查
- SSH 配置查看

**使用方法**:

```bash
chmod +x network_security.sh
./network_security.sh
```

### 5. package_management.sh

**对应章节**: 第六章 - 软件包管理

**功能**: 演示不同系统的包管理

- 自动检测系统类型
- 演示对应的包管理器命令
- 源码编译安装概念
- 包管理最佳实践

**使用方法**:

```bash
chmod +x package_management.sh
./package_management.sh
```

### 6. shell_scripting.sh

**对应章节**: 第七章 - Shell 脚本编程

**功能**: 全面演示 Shell 脚本编程概念

- 变量和参数
- 条件判断和循环
- 数组和函数
- 字符串处理
- 输入输出重定向
- 管道操作

**使用方法**:

```bash
chmod +x shell_scripting.sh
./shell_scripting.sh [参数1] [参数2] [参数3]
```

### 7. system_monitor.sh

**对应章节**: 第七章 - Shell 脚本编程 (实用脚本示例)

**功能**: 完整的系统监控脚本

- CPU、内存、磁盘监控
- 网络状态检查
- 进程分析
- 生成监控报告
- 支持多种监控模式

**使用方法**:

```bash
chmod +x system_monitor.sh
./system_monitor.sh [monitor|report|cpu|memory|disk|network|help]
```

**示例**:

```bash
./system_monitor.sh              # 完整监控
./system_monitor.sh report       # 生成报告文件
./system_monitor.sh cpu          # 仅监控 CPU
./system_monitor.sh help         # 显示帮助
```

### 8. log_analyzer.sh

**对应章节**: 第七章 - Shell 脚本编程 (实用脚本示例)

**功能**: Web 服务器日志分析工具

- 基本统计信息
- HTTP 状态码分析
- IP 地址分析
- URL 访问统计
- 安全威胁检测
- 实时监控模式

**使用方法**:

```bash
chmod +x log_analyzer.sh

# 创建示例日志
./log_analyzer.sh -s

# 分析日志
./log_analyzer.sh [选项] [日志文件]
```

**示例**:

```bash
./log_analyzer.sh -s                    # 创建示例日志
./log_analyzer.sh                       # 分析示例日志
./log_analyzer.sh -r /var/log/access.log # 生成详细报告
./log_analyzer.sh -m /var/log/access.log # 实时监控
```

### 9. auto_deploy.sh

**对应章节**: 第七章 - Shell 脚本编程 (实用脚本示例)

**功能**: 自动化部署脚本

- 完整的部署流程
- 备份和回滚功能
- 健康检查
- 应用生命周期管理
- 日志记录

**使用方法**:

```bash
chmod +x auto_deploy.sh
./auto_deploy.sh [deploy|rollback|status|start|stop|restart|health|cleanup|help]
```

**示例**:

```bash
./auto_deploy.sh deploy          # 执行部署
./auto_deploy.sh status          # 查看状态
./auto_deploy.sh rollback        # 回滚到上一版本
./auto_deploy.sh restart         # 重启应用
```

### 10. container_demo.sh

**对应章节**: 第八章 - 为容器技术做准备

**功能**: 容器技术基础概念演示

- Linux 命名空间
- 控制组 (cgroups)
- 联合文件系统
- 容器与虚拟机对比
- Docker 基础概念
- Dockerfile 示例
- 容器网络和存储
- Kubernetes 预备知识

**使用方法**:

```bash
chmod +x container_demo.sh
./container_demo.sh [namespaces|cgroups|unionfs|comparison|docker|dockerfile|networking|storage|kubernetes|all|help]
```

**示例**:

```bash
./container_demo.sh              # 运行所有演示
./container_demo.sh docker       # 仅演示 Docker 概念
./container_demo.sh dockerfile   # 仅演示 Dockerfile
```

## 二、使用建议

### 1. 权限设置

在运行脚本之前，确保给脚本添加执行权限：

```bash
chmod +x *.sh
```

### 2. 系统兼容性

- 脚本主要在 macOS 和 Linux 系统上测试
- 某些功能可能需要特定的系统权限
- 网络相关功能可能需要网络连接

### 3. 安全注意事项

- 脚本仅用于学习和演示目的
- 在生产环境中使用前请仔细审查
- 某些脚本会创建临时文件，运行后会自动清理

### 4. 学习路径

建议按照以下顺序学习和运行脚本：

1. `basic_commands.sh` - 熟悉基础命令
2. `file_permissions.sh` - 理解权限管理
3. `process_management.sh` - 学习进程管理
4. `network_security.sh` - 了解网络配置
5. `package_management.sh` - 掌握软件包管理
6. `shell_scripting.sh` - 学习脚本编程基础
7. `system_monitor.sh` - 实践系统监控
8. `log_analyzer.sh` - 实践日志分析
9. `auto_deploy.sh` - 实践自动化部署
10. `container_demo.sh` - 了解容器技术基础

### 5. 故障排除

如果脚本运行出现问题：

1. 检查脚本是否有执行权限
2. 确认系统是否支持相关命令
3. 查看脚本输出的错误信息
4. 某些功能可能需要管理员权限

### 6. 扩展学习

- 可以修改脚本参数来测试不同场景
- 尝试组合使用多个脚本
- 基于这些脚本创建自己的工具
- 将脚本集成到实际的工作流程中

## 三、输出文件说明

脚本运行过程中可能会在以下位置创建文件：

- `/tmp/` - 临时文件和演示文件
- `/tmp/log_analysis/` - 日志分析报告
- `/tmp/deploy/` - 部署相关文件
- `/tmp/backup/` - 备份文件

这些文件大多会在脚本运行结束后自动清理，或者可以手动删除。

---

**注意**: 这些脚本是为了教学目的而创建的，主要用于演示概念和命令的使用。
