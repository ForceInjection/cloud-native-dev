# Linux 入门课程

## 课程目标

- 理解 Linux 系统架构和文件系统
- 掌握 Linux 基础操作和命令
- 为后续 Docker/Kubernetes 学习打下坚实基础
- 培养云原生开发环境的使用能力

---

## 目录

- [Linux 入门课程](#linux-入门课程)
  - [课程目标](#课程目标)
  - [目录](#目录)
  - [第一章：Linux 系统概述](#第一章linux-系统概述)
    - [1.1 什么是 Linux](#11-什么是-linux)
      - [1.1.1 Linux 发展历史](#111-linux-发展历史)
      - [1.1.2 Linux 发行版介绍](#112-linux-发行版介绍)
      - [Linux 在云原生技术栈中的地位](#linux-在云原生技术栈中的地位)
      - [1.1.3 为什么容器技术选择 Linux](#113-为什么容器技术选择-linux)
    - [1.2 Linux 系统架构](#12-linux-系统架构)
      - [1.2.1 内核（Kernel）与用户空间](#121-内核kernel与用户空间)
        - [系统架构图解](#系统架构图解)
        - [内核空间（Kernel Space）详解](#内核空间kernel-space详解)
        - [用户空间（User Space）详解](#用户空间user-space详解)
        - [权限级别详解](#权限级别详解)
        - [实际例子：文件读取过程](#实际例子文件读取过程)
        - [为什么需要这种分离？](#为什么需要这种分离)
      - [1.2.2 系统调用接口](#122-系统调用接口)
      - [1.2.3 Shell 的作用](#123-shell-的作用)
      - [1.2.4 进程和线程概念](#124-进程和线程概念)
        - [进程（Process）详解](#进程process详解)
        - [线程（Thread）详解](#线程thread详解)
        - [进程状态转换详解](#进程状态转换详解)
        - [进程间通信（IPC）详解](#进程间通信ipc详解)
        - [在云原生开发中的重要性](#在云原生开发中的重要性)
        - [实践练习和监控](#实践练习和监控)
  - [第二章：Linux 基础操作](#第二章linux-基础操作)
    - [2.1 终端和 Shell](#21-终端和-shell)
      - [2.1.1 终端模拟器的使用](#211-终端模拟器的使用)
      - [2.1.2 Bash Shell 基础](#212-bash-shell-基础)
      - [2.1.3 命令行提示符解读](#213-命令行提示符解读)
      - [2.1.4 快捷键和命令历史](#214-快捷键和命令历史)
    - [2.2 文件系统导航](#22-文件系统导航)
      - [2.2.1 Linux 目录结构](#221-linux-目录结构)
        - [标准目录结构总览](#标准目录结构总览)
        - [重要目录详解](#重要目录详解)
          - [1. **/etc** - 系统配置文件目录](#1-etc---系统配置文件目录)
          - [2. **/var** - 变量数据目录](#2-var---变量数据目录)
          - [3. **/usr** - 用户程序目录](#3-usr---用户程序目录)
        - [特殊的虚拟文件系统](#特殊的虚拟文件系统)
          - [4. **/proc** - 进程和内核信息虚拟文件系统](#4-proc---进程和内核信息虚拟文件系统)
          - [5. **/sys** - 系统设备和内核信息文件系统](#5-sys---系统设备和内核信息文件系统)
          - [6. **/dev** - 设备文件目录](#6-dev---设备文件目录)
        - [其他重要目录](#其他重要目录)
          - [7. **/run** - 运行时数据](#7-run---运行时数据)
          - [8. **/tmp** - 临时文件](#8-tmp---临时文件)
        - [目录结构的重要性](#目录结构的重要性)
      - [2.1.2 绝对路径与相对路径](#212-绝对路径与相对路径)
      - [2.1.3 基础导航命令](#213-基础导航命令)
      - [2.1.4 文件和目录操作](#214-文件和目录操作)
    - [2.3 文件权限和所有权](#23-文件权限和所有权)
      - [2.3.1 用户、组和其他用户权限](#231-用户组和其他用户权限)
      - [2.3.2 权限表示方法](#232-权限表示方法)
      - [2.3.3 chmod 命令](#233-chmod-命令)
      - [2.3.4 chown 和 chgrp 命令](#234-chown-和-chgrp-命令)
      - [2.3.5 特殊权限](#235-特殊权限)
  - [第三章：文件操作和文本处理](#第三章文件操作和文本处理)
    - [3.1 文件查看和编辑](#31-文件查看和编辑)
      - [3.1.1 文件内容查看命令](#311-文件内容查看命令)
      - [3.1.2 文本编辑器](#312-文本编辑器)
      - [3.1.3 文件搜索](#313-文件搜索)
    - [3.2 文本处理工具](#32-文本处理工具)
      - [3.2.1 grep - 文本搜索工具](#321-grep---文本搜索工具)
      - [3.2.2 sed - 流编辑器](#322-sed---流编辑器)
      - [3.2.3 awk - 文本处理语言](#323-awk---文本处理语言)
      - [3.2.4 排序和去重](#324-排序和去重)
      - [3.2.5 文本统计](#325-文本统计)
    - [3.3 输入输出重定向](#33-输入输出重定向)
      - [3.3.1 标准输入、输出、错误](#331-标准输入输出错误)
      - [3.3.2 重定向操作符](#332-重定向操作符)
      - [3.3.3 管道操作](#333-管道操作)
      - [3.3.4 组合命令的强大功能](#334-组合命令的强大功能)
  - [第四章：进程和系统管理](#第四章进程和系统管理)
    - [4.1 进程管理](#41-进程管理)
      - [4.1.1 进程概念和生命周期](#411-进程概念和生命周期)
      - [4.1.2 进程管理命令](#412-进程管理命令)
      - [4.1.3 进程控制](#413-进程控制)
      - [4.1.4 后台进程](#414-后台进程)
    - [4.2 系统监控](#42-系统监控)
      - [4.2.1 系统资源监控](#421-系统资源监控)
      - [4.2.2 网络监控](#422-网络监控)
      - [4.2.3 系统信息](#423-系统信息)
    - [4.3 定时任务](#43-定时任务)
      - [4.3.1 cron 服务介绍](#431-cron-服务介绍)
      - [4.3.2 crontab 命令使用](#432-crontab-命令使用)
      - [4.3.3 定时任务实例](#433-定时任务实例)
  - [第五章：网络和安全基础](#第五章网络和安全基础)
    - [5.1 网络基础概念](#51-网络基础概念)
      - [5.1.1 网络基础知识](#511-网络基础知识)
    - [5.2 网络配置和诊断](#52-网络配置和诊断)
      - [5.2.1 网络接口管理](#521-网络接口管理)
      - [5.2.2 网络连通性测试](#522-网络连通性测试)
    - [5.3 SSH 远程连接](#53-ssh-远程连接)
      - [5.3.1 SSH 基础概念](#531-ssh-基础概念)
      - [5.3.2 SSH 客户端使用](#532-ssh-客户端使用)
      - [5.3.3 SSH 密钥认证](#533-ssh-密钥认证)
    - [5.4 防火墙基础](#54-防火墙基础)
      - [5.4.1 iptables 防火墙](#541-iptables-防火墙)
      - [5.4.1 ufw 简化防火墙](#541-ufw-简化防火墙)
    - [5.5 网络文件传输](#55-网络文件传输)
      - [5.5.1 scp 安全复制](#551-scp-安全复制)
      - [5.5.2 rsync 同步工具](#552-rsync-同步工具)
  - [第六章：软件包管理](#第六章软件包管理)
    - [6.1 包管理器概述](#61-包管理器概述)
      - [6.1.1 软件包管理基础概念](#611-软件包管理基础概念)
    - [6.2 APT 包管理（Debian/Ubuntu）](#62-apt-包管理debianubuntu)
      - [6.2.1 APT 基础操作](#621-apt-基础操作)
    - [6.3 YUM/DNF 包管理（CentOS/RHEL/Fedora）](#63-yumdnf-包管理centosrhelfedora)
      - [6.3.1 DNF 包管理器（现代工具）](#631-dnf-包管理器现代工具)
    - [6.4 源码编译安装](#64-源码编译安装)
      - [6.4.1 源码编译基础](#641-源码编译基础)
  - [第七章：Shell 脚本编程](#第七章shell-脚本编程)
    - [7.1 Shell 脚本基础](#71-shell-脚本基础)
      - [7.1.1 脚本文件创建和执行](#711-脚本文件创建和执行)
      - [7.1.2 变量定义和使用](#712-变量定义和使用)
      - [7.1.3 命令行参数处理](#713-命令行参数处理)
    - [7.2 控制结构](#72-控制结构)
      - [7.2.1 条件判断：if-then-else](#721-条件判断if-then-else)
      - [循环结构：for、while](#循环结构forwhile)
      - [7.2.2 函数定义和调用](#722-函数定义和调用)
      - [7.2.3 错误处理和退出状态](#723-错误处理和退出状态)
    - [7.3 实用脚本示例](#73-实用脚本示例)
      - [7.3.1 系统监控脚本](#731-系统监控脚本)
      - [7.3.2 日志分析脚本](#732-日志分析脚本)
      - [7.3.3 自动化部署脚本](#733-自动化部署脚本)
  - [第八章：为容器技术做准备](#第八章为容器技术做准备)
    - [8.1 Linux 容器相关概念](#81-linux-容器相关概念)
      - [8.1.1 命名空间（Namespaces）](#811-命名空间namespaces)
      - [8.1.2 控制组（Cgroups）](#812-控制组cgroups)
      - [8.1.3 联合文件系统（Union FS）](#813-联合文件系统union-fs)
      - [8.1.4 容器与虚拟机的区别](#814-容器与虚拟机的区别)
    - [8.2 Docker 预备知识](#82-docker-预备知识)
      - [8.2.1 Linux 内核特性](#821-linux-内核特性)
      - [8.2.2 文件系统层次](#822-文件系统层次)
      - [8.2.3 网络命名空间](#823-网络命名空间)
      - [8.2.4 进程隔离机制](#824-进程隔离机制)
    - [8.3 Kubernetes 预备知识](#83-kubernetes-预备知识)
      - [8.3.1 集群概念](#831-集群概念)
      - [8.2.5 网络通信基础](#825-网络通信基础)
      - [8.2.6 存储挂载](#826-存储挂载)
      - [8.2.7 服务发现机制](#827-服务发现机制)
  - [第九章：实践项目](#第九章实践项目)
    - [9.1 Web 服务器搭建](#91-web-服务器搭建)
    - [9.2 数据库服务](#92-数据库服务)
    - [9.3 综合项目](#93-综合项目)
  - [第十章：最佳实践和进阶](#第十章最佳实践和进阶)
    - [10.1 系统安全](#101-系统安全)
    - [10.2 性能优化](#102-性能优化)
    - [10.3 故障排查](#103-故障排查)
  - [第十一章：实验环境](#第十一章实验环境)
    - [11.1 推荐配置](#111-推荐配置)
    - [11.2 实验工具](#112-实验工具)
  - [第十二章：参考资料](#第十二章参考资料)
    - [12.1 书籍推荐](#121-书籍推荐)
    - [12.2 在线资源](#122-在线资源)
    - [12.3 练习平台](#123-练习平台)
    - [12.4 认证和职业发展](#124-认证和职业发展)
    - [12.5 持续学习建议](#125-持续学习建议)

---

## 第一章：Linux 系统概述

### 1.1 什么是 Linux

#### 1.1.1 Linux 发展历史

Linux 是一个自由和开放源代码的类 UNIX 操作系统内核，由芬兰计算机科学家林纳斯·托瓦兹（Linus Torvalds）于 1991 年首次发布。

**重要时间节点：**

- **1991年**：Linus Torvalds 发布 Linux 0.01 版本
  - 仅有 10,239 行代码
  - 只支持 386 处理器
  - 标志着开源操作系统的诞生

- **1994年**：Linux 1.0 发布，标志着 Linux 的成熟
  - 176,250 行代码
  - 首个稳定的生产版本
  - 开始支持网络功能

- **1996年**：Linux 2.0 发布，支持多处理器
  - 引入对称多处理（SMP）支持
  - 支持多种硬件架构（Alpha、SPARC、MIPS）
  - 内存管理显著改进

- **2003年**：Linux 2.6 发布，改进了性能和可扩展性
  - 引入新的调度器（O(1) 调度器）
  - 支持 NUMA（非统一内存访问）
  - 改进的线程支持（NPTL）
  - 更好的桌面响应性

- **2011年**：Linux 3.0 发布，主要是版本号的变更
  - 为纪念 Linux 20 周年
  - 技术上与 2.6.39 相似
  - 开始采用新的版本编号方案

- **2015年至今**：Linux 4.x/5.x/6.x 持续发展
  - **Linux 4.x（2015-2019）**：
    - 引入 eBPF（扩展的伯克利包过滤器）
    - 容器技术支持增强（Namespaces、Cgroups v2）
    - 改进的文件系统（Btrfs、XFS 增强）
    - 更好的硬件支持和电源管理
  
  - **Linux 5.x（2019-2022）**：
    - 引入 io_uring（高性能异步 I/O）
    - 改进的容器安全性（seccomp、LSM）
    - 支持新的文件系统（exFAT）
    - 增强的实时性能（PREEMPT_RT 集成）
  
  - **Linux 6.x（2022至今）**：
    - 引入 Rust 语言支持（内核模块开发）
    - 改进的调度器（EEVDF 调度器）
    - 增强的安全特性（Landlock LSM）
    - 更好的云原生和容器支持
    - 改进的文件系统性能和可靠性

**云原生时代的重要特性**：

- **容器化支持**：Namespaces、Cgroups、Union File Systems
- **微服务架构支持**：容器隔离、服务网格、高效进程间通信、网络命名空间
- **云计算优化**：虚拟化支持、资源隔离、弹性伸缩
- **安全增强**：SELinux、AppArmor、seccomp、LSM 框架

#### 1.1.2 Linux 发行版介绍

Linux 发行版是基于 Linux 内核的完整操作系统，包含了内核、系统工具、应用程序和包管理器。

**主要发行版分类：**

1. **Debian 系列**
   - **Ubuntu**：最受欢迎的桌面和服务器发行版
     - 特点：用户友好、社区支持强、LTS 版本稳定
     - 适用场景：开发环境、Web 服务器、容器基础镜像
   - **Debian**：稳定性极高的发行版
     - 特点：严格的软件测试、长期支持
     - 适用场景：生产服务器、关键业务系统

2. **Red Hat 系列**
   - **CentOS**：企业级免费发行版（已停止维护）
   - **Rocky Linux/AlmaLinux**：CentOS 的替代品
   - **RHEL**：商业企业级发行版
   - **Fedora**：前沿技术测试平台

3. **容器优化发行版**
   - **Alpine Linux**：极简轻量级发行版
     - 特点：体积小（约5MB）、安全性高、适合容器
     - 使用场景：Docker 容器、微服务、嵌入式系统
   - **CoreOS**：专为容器设计的操作系统

#### Linux 在云原生技术栈中的地位

**云原生技术栈层次：**

```text
┌─────────────────────────────────────┐
│        应用层 (Applications)         │
├─────────────────────────────────────┤
│      编排层 (Kubernetes/Docker)      │
├─────────────────────────────────────┤
│       容器运行时 (Container Runtime)  │
├─────────────────────────────────────┤
│       操作系统 (Linux Kernel)        │
├─────────────────────────────────────┤
│       基础设施 (Infrastructure)       │
└─────────────────────────────────────┘
```

Linux 作为云原生技术栈的基础层，提供了：

- **容器化支持**：Namespaces、Cgroups 等内核特性
- **网络虚拟化**：虚拟网络接口、网络命名空间
- **存储抽象**：统一的文件系统接口
- **进程隔离**：安全的多租户环境

#### 1.1.3 为什么容器技术选择 Linux

1. **内核特性支持**
   - **Namespaces**：提供进程、网络、文件系统隔离
   - **Cgroups**：资源限制和监控
   - **Union File Systems**：分层文件系统支持

2. **开源生态**
   - 完全开源，无许可费用
   - 庞大的开发者社区
   - 丰富的软件包生态系统

3. **性能优势**
   - 轻量级内核设计
   - 高效的系统调用
   - 优秀的网络和 I/O 性能

4. **标准化**
   - POSIX 兼容性
   - 统一的系统接口
   - 跨平台一致性

### 1.2 Linux 系统架构

#### 1.2.1 内核（Kernel）与用户空间

Linux 系统采用分层架构设计，主要分为内核空间和用户空间。这种设计确保了系统的安全性和稳定性。

##### 系统架构图解

```text
用户空间 (User Space) - Ring 3 权限级别
┌─────────────────────────────────────┐
│  应用程序 (Applications)             │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │  Web    │ │ Database│ │  Shell  │ │
│  │ Server  │ │         │ │         │ │
│  └─────────┘ └─────────┘ └─────────┘ │
├─────────────────────────────────────┤
│  系统库 (System Libraries)           │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │  glibc  │ │ libssl  │ │  其他   │ │
│  └─────────┘ └─────────┘ └─────────┘ │
└─────────────────────────────────────┘
              系统调用接口 (System Call Interface)
              ↕ 权限切换 (Context Switch)
┌─────────────────────────────────────┐
│           Linux 内核                 │
│  ┌─────────────────────────────────┐│
│  │      进程管理 | 内存管理          │ │
│  ├─────────────────────────────────┤│
│  │      文件系统 | 网络协议栈         │ │
│  ├─────────────────────────────────┤ │
│  │           设备驱动               │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
内核空间 (Kernel Space) - Ring 0 权限级别
              ↕ 硬件抽象层
┌─────────────────────────────────────┐
│              硬件层                  │
│  CPU | 内存 | 磁盘 | 网卡 | 其他设备   │
└─────────────────────────────────────┘
```

##### 内核空间（Kernel Space）详解

**什么是内核空间？**

内核空间是操作系统内核运行的内存区域，拥有系统的最高权限。可以把它想象成一个"超级管理员"，负责管理整个计算机系统。

**内核空间特点：**

- **最高权限（Ring 0）**：可以执行任何指令，访问任何硬件资源
- **直接硬件访问**：无需通过其他层次，直接控制CPU、内存、磁盘等
- **资源管理者**：决定哪个程序可以使用多少CPU时间、内存空间
- **系统服务提供者**：为用户程序提供文件操作、网络通信等服务
- **安全守护者**：保护系统不被恶意程序破坏

**内核的主要职责：**

1. **进程管理**
   - 创建、调度、终止进程
   - 进程间通信（IPC）
   - 多任务处理

2. **内存管理**
   - 虚拟内存分配
   - 内存保护
   - 内存回收

3. **文件系统管理**
   - 文件读写操作
   - 目录管理
   - 权限控制

4. **设备驱动**
   - 硬件设备控制
   - 设备抽象
   - 中断处理

5. **网络协议栈**
   - TCP/IP协议实现
   - 网络数据包处理
   - 网络安全

##### 用户空间（User Space）详解

**什么是用户空间？**

用户空间是普通应用程序运行的内存区域，权限受限。可以把它想象成"普通用户"，需要通过"申请"的方式获取系统资源。

**用户空间特点：**

- **受限权限（Ring 3）**：不能直接访问硬件，不能执行特权指令
- **安全隔离**：程序之间相互隔离，一个程序崩溃不会影响其他程序
- **通过系统调用访问内核**：需要"请求"内核提供服务
- **相对安全**：即使程序有bug，也不会破坏整个系统

**用户空间的组成：**

1. **应用程序层**
   - 用户直接使用的软件（浏览器、编辑器、游戏等）
   - 系统工具（ls、cp、grep等命令）
   - 服务程序（Web服务器、数据库等）

2. **系统库层**
   - **glibc**：C标准库，提供基本函数
   - **libssl**：加密库
   - **其他专用库**：图形库、数学库等

##### 权限级别详解

现代CPU采用环形保护机制，将权限分为4个级别（Ring 0-3）：

```text
权限级别图：

    Ring 0 (内核态)
   ┌─────────────┐
   │    内核      │ ← 最高权限
   └─────────────┘
        Ring 1
   ┌─────────────┐
   │  设备驱动    │ ← 通常不使用
   └─────────────┘
        Ring 2  
   ┌─────────────┐
   │  系统服务    │ ← 通常不使用
   └─────────────┘
        Ring 3 (用户态)
   ┌─────────────┐
   │  应用程序    │ ← 最低权限
   └─────────────┘
```

**Ring 0（内核态）**：

- 可以执行所有CPU指令
- 可以访问所有内存地址
- 可以直接操作硬件
- 可以修改系统关键数据结构

**Ring 3（用户态）**：

- 只能执行非特权指令
- 只能访问分配给自己的内存
- 不能直接操作硬件
- 需要通过系统调用请求内核服务

##### 实际例子：文件读取过程

让我们通过一个具体例子来理解内核态和用户态的交互：

```text
用户程序读取文件的完整过程：

用户空间 (Ring 3):
1. 应用程序调用 fopen("file.txt", "r")
2. glibc库将其转换为 open() 系统调用
3. 触发软中断，切换到内核态

        ↓ 权限切换 (Context Switch)

内核空间 (Ring 0):
4. 内核接收系统调用请求
5. 检查文件权限
6. 查找文件在磁盘上的位置
7. 调用磁盘驱动程序读取数据
8. 将数据复制到用户空间缓冲区
9. 返回文件描述符

        ↓ 权限切换回用户态

用户空间 (Ring 3):
10. 应用程序获得文件描述符
11. 可以继续使用 fread() 读取文件内容
```

##### 为什么需要这种分离？

**安全性**：

- 防止恶意程序直接操作硬件
- 避免程序错误导致系统崩溃
- 保护重要系统数据不被篡改

**稳定性**：

- 用户程序崩溃不会影响内核
- 内核可以回收崩溃程序的资源
- 系统可以继续正常运行

**可移植性**：

- 应用程序不需要知道具体硬件细节
- 内核提供统一的接口
- 程序可以在不同硬件上运行

**资源管理**：

- 内核统一分配和管理资源
- 防止程序之间的资源冲突
- 实现公平的资源调度

#### 1.2.2 系统调用接口

系统调用是用户空间程序请求内核服务的唯一方式。

**常用系统调用分类：**

1. **文件操作**

   ```c
   open()    // 打开文件
   read()    // 读取文件
   write()   // 写入文件
   close()   // 关闭文件
   ```

2. **进程管理**

   ```c
   fork()    // 创建子进程
   exec()    // 执行程序
   wait()    // 等待子进程
   exit()    // 退出进程
   ```

3. **内存管理**

   ```c
   malloc()  // 分配内存
   free()    // 释放内存
   mmap()    // 内存映射
   ```

4. **网络通信**

   ```c
   socket()  // 创建套接字
   bind()    // 绑定地址
   listen()  // 监听连接
   accept()  // 接受连接
   ```

#### 1.2.3 Shell 的作用

Shell 是用户与 Linux 系统交互的命令行界面，充当用户和内核之间的中介。

**Shell 的主要功能：**

1. **命令解释器**
   - 解析用户输入的命令
   - 调用相应的系统程序
   - 返回执行结果

2. **编程环境**
   - 支持变量和函数
   - 提供控制结构（if、for、while）
   - 支持脚本编程

3. **作业控制**
   - 前台和后台进程管理
   - 进程组管理
   - 信号处理

**常见 Shell 类型：**

- **Bash**：最常用的 Shell，功能丰富
- **Zsh**：功能强大，支持插件
- **Fish**：用户友好，智能补全
- **Dash**：轻量级，POSIX 兼容

#### 1.2.4 进程和线程概念

##### 进程（Process）详解

**基本概念：**

- **定义**：正在执行的程序实例，是系统资源分配的基本单位
- **特点**：拥有独立的内存空间和系统资源
- **标识**：每个进程有唯一的 PID（Process ID）
- **生命周期**：从程序加载到执行结束的完整过程

**进程的组成部分：**

1. **代码段（Text Segment）**：存储程序的可执行代码
2. **数据段（Data Segment）**：存储全局变量和静态变量
3. **堆（Heap）**：动态分配的内存区域
4. **栈（Stack）**：存储局部变量和函数调用信息
5. **进程控制块（PCB）**：存储进程状态信息

**进程内存布局示例：**

```text
高地址  ┌─────────────────┐
       │     内核空间     │ ← 系统调用、中断处理
       ├─────────────────┤
       │       栈        │ ← 局部变量、函数参数
       │       ↓        │   （向下增长）
       │                │
       │    未使用空间    │
       │                │
       │       ↑        │
       │       堆        │ ← 动态分配内存
       ├─────────────────┤   （向上增长）
       │    数据段       │ ← 全局变量、静态变量
       ├─────────────────┤
低地址  │    代码段       │ ← 程序指令
       └─────────────────┘
```

##### 线程（Thread）详解

**基本概念：**

- **定义**：进程内的执行单元，是 CPU 调度的基本单位
- **特点**：共享进程的内存空间和资源
- **优势**：创建和切换开销小，便于并发编程
- **轻量级**：相比进程，线程的创建和销毁更快

**线程共享的资源：**

- 代码段、数据段、堆内存
- 文件描述符、信号处理器
- 进程 ID、工作目录

**线程独有的资源：**

- 线程 ID（TID）
- 程序计数器（PC）
- 寄存器状态
- 栈空间

**多线程内存模型：**

```text
进程内存空间
┌─────────────────────────────────┐
│           代码段（共享）          │
├─────────────────────────────────┤
│           数据段（共享）          │
├─────────────────────────────────┤
│            堆（共享）            │
├─────────────────────────────────┤
│  线程1栈  │  线程2栈  │  线程3栈  │
│  (独立)   │  (独立)   │  (独立)   │
└─────────────────────────────────┘
```

##### 进程状态转换详解

**完整的进程状态图：**

```text
        fork()          exec()
   ┌─────────────┐  ┌─────────────┐
   │    创建     │──→│    就绪     │
   └─────────────┘  └─────────────┘
                           │ ↑
                    调度   │ │ 时间片用完
                           ↓ │ 或被抢占
                    ┌─────────────┐
                    │    运行     │
                    └─────────────┘
                           │ ↑
                    等待   │ │ 事件完成
                    I/O    │ │ 或资源可用
                           ↓ │
                    ┌─────────────┐
                    │    等待     │
                    └─────────────┘
                           │
                    exit() │
                           ↓
                    ┌─────────────┐
                    │    终止     │
                    └─────────────┘
```

**状态详细说明：**

1. **创建（New）**：进程正在被创建，分配资源
2. **就绪（Ready）**：进程已准备好运行，等待 CPU 分配
3. **运行（Running）**：进程正在 CPU 上执行
4. **等待（Waiting/Blocked）**：进程等待某个事件发生（如 I/O 完成）
5. **终止（Terminated）**：进程执行完毕，释放资源

##### 进程间通信（IPC）详解

**1. 管道（Pipe）**：

- **特点**：单向数据流，先进先出（FIFO）
- **类型**：匿名管道（只能在父子进程间使用）
- **示例**：`ls | grep txt`

```bash
# 创建管道示例
mkfifo mypipe
echo "Hello" > mypipe &  # 后台写入
cat < mypipe             # 读取数据
```

**2. 命名管道（FIFO）**：

- **特点**：有文件名的管道，可在无关进程间通信
- **持久性**：在文件系统中存在

**3. 信号（Signal）**：

- **特点**：异步通知机制，用于进程间简单通信
- **常用信号**：SIGTERM（终止）、SIGKILL（强制终止）、SIGUSR1/2（用户定义）

```bash
# 信号示例
kill -TERM 1234    # 发送终止信号给进程 1234
kill -9 1234       # 强制终止进程 1234
```

**4. 共享内存**：

- **特点**：最快的 IPC 方式，多个进程共享同一块内存
- **同步**：需要信号量或互斥锁保证数据一致性

**5. 消息队列**：

- **特点**：结构化消息传递，支持优先级
- **持久性**：消息可以在发送者退出后仍然存在

**6. 套接字（Socket）**：

- **特点**：支持网络通信，最灵活的 IPC 方式
- **类型**：Unix 域套接字（本地）、网络套接字（远程）

##### 在云原生开发中的重要性

**容器化应用：**

- 每个容器通常运行一个主进程
- 理解进程生命周期有助于容器管理
- 信号处理对于优雅关闭容器很重要

**微服务架构：**

- 服务间通信主要使用网络套接字
- 进程隔离保证服务的独立性
- 多线程处理提高服务并发能力

**Kubernetes 环境：**

- Pod 内容器共享网络和存储
- 进程监控和健康检查
- 资源限制和进程调度

##### 实践练习和监控

**基础进程操作：**

```bash
# 查看当前进程
ps aux                    # 显示所有进程详细信息
ps -ef                    # 显示进程层次关系
top                       # 实时显示进程状态
htop                      # 更友好的进程监控工具

# 查看进程树
pstree                    # 显示进程树结构
pstree -p                 # 显示进程树和 PID

# 查看特定进程
ps -p 1234               # 查看 PID 为 1234 的进程
ps -C nginx              # 查看名为 nginx 的进程
```

**进程监控和分析：**

```bash
# 查看进程详细信息
cat /proc/1234/status    # 查看进程状态
cat /proc/1234/cmdline   # 查看进程启动命令
ls -la /proc/1234/fd/    # 查看进程打开的文件描述符

# 监控进程资源使用
iostat                   # I/O 统计
vmstat                   # 虚拟内存统计
sar                      # 系统活动报告

# 跟踪系统调用
strace ls                # 跟踪 ls 命令的系统调用
strace -p 1234           # 跟踪运行中进程的系统调用
```

**线程相关操作：**

```bash
# 查看线程信息
ps -eLf                  # 显示所有线程
top -H                   # 显示线程而不是进程
cat /proc/1234/task/     # 查看进程的所有线程
```

**性能分析工具：**

```bash
# 系统整体性能
uptime                   # 系统负载
free -h                  # 内存使用情况
df -h                    # 磁盘使用情况

# 进程性能分析
perf top                 # 实时性能分析
perf record -p 1234      # 记录进程性能数据
perf report              # 分析性能数据
```

---

## 第二章：Linux 基础操作

### 2.1 终端和 Shell

#### 2.1.1 终端模拟器的使用

终端模拟器是图形界面下访问命令行的工具，它模拟了传统的文本终端。

**常见终端模拟器：**

- **GNOME Terminal**：Ubuntu 默认终端
- **Konsole**：KDE 桌面环境终端
- **iTerm2**：macOS 上功能强大的终端
- **Windows Terminal**：Windows 现代终端
- **Terminator**：支持分屏的终端

**终端基本操作：**

```bash
# 打开新标签页
Ctrl + Shift + T

# 关闭当前标签页
Ctrl + Shift + W

# 切换标签页
Ctrl + PageUp/PageDown

# 复制粘贴
Ctrl + Shift + C  # 复制
Ctrl + Shift + V  # 粘贴

# 清屏
Ctrl + L 或 clear 命令
```

#### 2.1.2 Bash Shell 基础

Bash（Bourne Again Shell）是 Linux 系统中最常用的 Shell。

**Bash 特性：**

1. **命令历史**：记录之前执行的命令
2. **命令补全**：Tab 键自动补全
3. **别名支持**：为长命令创建短别名
4. **作业控制**：管理前台和后台进程
5. **脚本编程**：支持复杂的脚本逻辑

**环境变量：**

```bash
# 查看所有环境变量
env

# 查看特定变量
echo $HOME
echo $PATH
echo $USER

# 设置环境变量
export MY_VAR="Hello World"

# 查看 Shell 类型
echo $SHELL
```

#### 2.1.3 命令行提示符解读

典型的 Bash 提示符格式：

```bash
username@hostname:current_directory$ 
```

**提示符组成部分：**

- **username**：当前用户名
- **hostname**：主机名
- **current_directory**：当前目录
  - `~` 表示用户主目录
  - `/` 表示根目录
- **$**：普通用户提示符
- **#**：root 用户提示符

**示例：**

```bash
# 普通用户
student@ubuntu:~/Documents$ 

# root 用户
root@ubuntu:/etc# 

# 在根目录
student@ubuntu:/$ 
```

**自定义提示符：**

```bash
# 临时修改
PS1="[\u@\h \W]\$ "

# 永久修改（添加到 ~/.bashrc）
echo 'PS1="[\u@\h \W]\$ "' >> ~/.bashrc
source ~/.bashrc
```

#### 2.1.4 快捷键和命令历史

**常用快捷键：**

```bash
# 光标移动
Ctrl + A    # 移动到行首
Ctrl + E    # 移动到行尾
Ctrl + F    # 向前移动一个字符
Ctrl + B    # 向后移动一个字符
Alt + F     # 向前移动一个单词
Alt + B     # 向后移动一个单词

# 文本编辑
Ctrl + U    # 删除光标到行首的内容
Ctrl + K    # 删除光标到行尾的内容
Ctrl + W    # 删除光标前的单词
Ctrl + Y    # 粘贴之前删除的内容

# 进程控制
Ctrl + C    # 终止当前进程
Ctrl + Z    # 暂停当前进程
Ctrl + D    # 发送 EOF 或退出
```

**命令历史管理：**

```bash
# 查看命令历史
history

# 执行历史命令
!!          # 执行上一条命令
!n          # 执行第 n 条历史命令
!string     # 执行最近以 string 开头的命令

# 搜索历史命令
Ctrl + R    # 反向搜索
Ctrl + S    # 正向搜索

# 历史命令配置
echo $HISTSIZE      # 内存中保存的历史命令数
echo $HISTFILESIZE  # 文件中保存的历史命令数

# 清除历史
history -c  # 清除当前会话历史
> ~/.bash_history  # 清除历史文件
```

### 2.2 文件系统导航

#### 2.2.1 Linux 目录结构

Linux 采用树形目录结构，所有文件和目录都从根目录（/）开始。这种统一的文件系统层次结构（FHS - Filesystem Hierarchy Standard）确保了不同Linux发行版之间的一致性。

##### 标准目录结构总览

```text
/
├── bin/          # 基本命令二进制文件（Essential user command binaries）
├── boot/         # 启动文件（Static files of the boot loader）
├── dev/          # 设备文件（Device files）
├── etc/          # 系统配置文件（Host-specific system configuration）
├── home/         # 用户主目录（User home directories）
├── lib/          # 共享库文件（Essential shared libraries and kernel modules）
├── lib64/        # 64位共享库文件
├── media/        # 可移动媒体挂载点（Mount point for removable media）
├── mnt/          # 临时挂载点（Mount point for temporarily mounted filesystems）
├── opt/          # 可选软件包（Add-on application software packages）
├── proc/         # 进程和系统信息（Kernel and process information virtual filesystem）
├── root/         # root 用户主目录（Home directory for the root user）
├── run/          # 运行时数据（Data relevant to running processes）
├── sbin/         # 系统管理命令（Essential system binaries）
├── srv/          # 服务数据（Data for services provided by this system）
├── sys/          # 系统文件系统（Kernel and system information virtual filesystem）
├── tmp/          # 临时文件（Temporary files）
├── usr/          # 用户程序（Secondary hierarchy）
└── var/          # 变量数据（Variable data）
```

##### 重要目录详解

###### 1. **/etc** - 系统配置文件目录

这是系统的"控制中心"，包含所有系统级配置文件。

```bash
# 用户和权限管理
/etc/passwd     # 用户账户信息
/etc/shadow     # 用户密码哈希（需要root权限查看）
/etc/group      # 用户组信息
/etc/sudoers    # sudo权限配置

# 网络配置
/etc/hosts      # 主机名解析
/etc/resolv.conf # DNS配置
/etc/network/   # 网络接口配置（Debian/Ubuntu）
/etc/sysconfig/network-scripts/ # 网络配置（RHEL/CentOS）

# 系统服务
/etc/systemd/   # systemd服务配置
/etc/init.d/    # 传统init脚本
/etc/crontab    # 系统级定时任务

# 文件系统
/etc/fstab      # 文件系统挂载配置
/etc/mtab       # 当前挂载的文件系统

# 应用程序配置
/etc/ssh/       # SSH服务配置
/etc/nginx/     # Nginx配置
/etc/docker/    # Docker配置
```

###### 2. **/var** - 变量数据目录

存储经常变化的数据，如日志、缓存、数据库等。

```bash
# 日志文件
/var/log/       # 系统日志目录
/var/log/syslog # 系统日志（Ubuntu/Debian）
/var/log/messages # 系统消息（RHEL/CentOS）
/var/log/auth.log # 认证日志
/var/log/nginx/ # Nginx日志

# 应用程序数据
/var/lib/       # 应用程序状态数据
/var/lib/docker/ # Docker数据
/var/lib/mysql/ # MySQL数据库文件
/var/lib/postgresql/ # PostgreSQL数据

# Web服务
/var/www/       # Web服务器文档根目录
/var/www/html/  # 默认网站目录

# 缓存和临时数据
/var/cache/     # 应用程序缓存
/var/tmp/       # 临时文件（重启后保留）
/var/spool/     # 队列数据（邮件、打印等）
```

###### 3. **/usr** - 用户程序目录

包含大部分用户程序和数据，是系统的"软件仓库"。

```bash
# 可执行文件
/usr/bin/       # 用户命令（如ls、cp、vim）
/usr/sbin/      # 系统管理命令（如systemctl、iptables）
/usr/local/bin/ # 本地安装的程序

# 库文件
/usr/lib/       # 共享库文件
/usr/lib64/     # 64位库文件
/usr/local/lib/ # 本地安装的库

# 文档和资源
/usr/share/     # 共享数据（文档、图标、字体等）
/usr/share/doc/ # 软件文档
/usr/share/man/ # 手册页

# 源代码和头文件
/usr/src/       # 源代码
/usr/include/   # C/C++头文件

# 本地安装
/usr/local/     # 本地编译安装的软件
```

##### 特殊的虚拟文件系统

这些目录不存储真实文件，而是内核提供的虚拟接口，用于访问系统信息。

###### 4. **/proc** - 进程和内核信息虚拟文件系统

`/proc` 是一个特殊的虚拟文件系统，提供了访问内核数据结构的接口。

**系统信息文件：**

```bash
# CPU和硬件信息
/proc/cpuinfo   # CPU详细信息（型号、频率、核心数等）
/proc/meminfo   # 内存使用详情
/proc/version   # 内核版本信息
/proc/uptime    # 系统运行时间
/proc/loadavg   # 系统负载平均值

# 文件系统信息
/proc/filesystems # 支持的文件系统类型
/proc/mounts    # 当前挂载的文件系统
/proc/partitions # 磁盘分区信息

# 网络信息
/proc/net/      # 网络统计信息目录
/proc/net/dev   # 网络接口统计
/proc/net/tcp   # TCP连接信息
/proc/net/udp   # UDP连接信息

# 系统配置
/proc/sys/      # 内核参数配置目录
/proc/sys/kernel/ # 内核参数
/proc/sys/net/  # 网络参数
/proc/sys/vm/   # 虚拟内存参数
```

**进程信息目录：**

每个运行的进程在 `/proc` 下都有一个以进程ID命名的目录：

```bash
/proc/[pid]/    # 进程ID目录
/proc/[pid]/cmdline  # 进程启动命令行
/proc/[pid]/environ  # 进程环境变量
/proc/[pid]/exe      # 进程可执行文件链接
/proc/[pid]/fd/      # 进程打开的文件描述符
/proc/[pid]/maps     # 进程内存映射
/proc/[pid]/stat     # 进程状态信息
/proc/[pid]/status   # 进程详细状态

# 特殊进程目录
/proc/self/     # 指向当前进程的符号链接
/proc/thread-self/ # 指向当前线程的符号链接
```

**实用示例：**

```bash
# 查看CPU信息
cat /proc/cpuinfo | grep "model name" | head -1

# 查看内存使用情况
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"

# 查看系统负载
cat /proc/loadavg

# 查看特定进程信息
ps aux | grep nginx  # 先找到nginx进程ID
cat /proc/[nginx_pid]/cmdline  # 查看启动命令
ls -l /proc/[nginx_pid]/fd/    # 查看打开的文件

# 修改内核参数（需要root权限）
echo 1 > /proc/sys/net/ipv4/ip_forward  # 启用IP转发
```

###### 5. **/sys** - 系统设备和内核信息文件系统

`/sys` 提供了设备驱动程序和内核子系统的信息接口。

```bash
# 设备信息
/sys/class/     # 设备类别目录
/sys/class/net/ # 网络设备
/sys/class/block/ # 块设备（硬盘等）
/sys/class/input/ # 输入设备

# 总线信息
/sys/bus/       # 系统总线
/sys/bus/pci/   # PCI总线设备
/sys/bus/usb/   # USB总线设备

# 设备树
/sys/devices/   # 设备层次结构

# 内核模块
/sys/module/    # 已加载的内核模块

# 文件系统
/sys/fs/        # 文件系统相关信息
/sys/fs/cgroup/ # cgroup控制组（容器技术基础）
```

**实用示例：**

```bash
# 查看网络接口
ls /sys/class/net/
cat /sys/class/net/eth0/address  # 查看MAC地址
cat /sys/class/net/eth0/speed    # 查看网卡速度

# 查看块设备
ls /sys/class/block/
cat /sys/class/block/sda/size    # 查看磁盘大小

# 查看CPU信息
ls /sys/devices/system/cpu/
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# cgroup信息（容器相关）
ls /sys/fs/cgroup/
cat /sys/fs/cgroup/memory/memory.limit_in_bytes
```

###### 6. **/dev** - 设备文件目录

`/dev` 包含设备文件，这些文件代表系统中的硬件设备。

```bash
# 块设备（存储设备）
/dev/sda        # 第一个SATA硬盘
/dev/sda1       # 第一个SATA硬盘的第一个分区
/dev/nvme0n1    # NVMe SSD
/dev/loop0      # 回环设备

# 字符设备
/dev/tty        # 控制终端
/dev/tty1       # 第一个虚拟终端
/dev/pts/0      # 伪终端
/dev/random     # 随机数生成器
/dev/urandom    # 伪随机数生成器

# 特殊设备
/dev/null       # 空设备（数据黑洞）
/dev/zero       # 零设备（产生无限的零字节）
/dev/full       # 满设备（总是返回磁盘已满错误）

# 网络设备（某些系统）
/dev/net/tun    # TUN/TAP网络设备
```

**实用示例：**

```bash
# 查看块设备
lsblk           # 列出所有块设备
fdisk -l        # 查看磁盘分区

# 使用特殊设备
echo "test" > /dev/null     # 丢弃输出
dd if=/dev/zero of=test.img bs=1M count=10  # 创建10MB的空文件
dd if=/dev/urandom of=random.dat bs=1K count=1  # 生成1KB随机数据

# 查看终端设备
tty             # 显示当前终端设备
who             # 显示登录用户和终端
```

##### 其他重要目录

###### 7. **/run** - 运行时数据

存储系统启动后的运行时信息，重启后会清空。

```bash
/run/           # 运行时数据根目录
/run/lock/      # 锁文件
/run/user/      # 用户运行时目录
/run/systemd/   # systemd运行时数据
/run/docker.sock # Docker守护进程套接字
```

###### 8. **/tmp** - 临时文件

存储临时文件，系统重启时通常会清空。

```bash
# 临时文件示例
/tmp/           # 临时文件目录
/tmp/.X11-unix/ # X11套接字文件
/tmp/systemd-private-* # systemd私有临时目录
```

##### 目录结构的重要性

**对于云原生开发的意义：**

1. **容器镜像构建**：理解目录结构有助于优化Docker镜像
2. **配置管理**：知道配置文件位置便于容器化应用
3. **日志收集**：了解日志位置便于日志聚合
4. **监控指标**：`/proc` 和 `/sys` 是监控系统的重要数据源
5. **安全考虑**：理解敏感目录有助于容器安全配置

**最佳实践：**

```bash
# 容器中常用的目录挂载
docker run -v /var/log:/var/log app:latest        # 日志持久化
docker run -v /etc/config:/etc/app app:latest     # 配置文件挂载
docker run -v /data:/var/lib/app app:latest       # 数据持久化

# 监控容器资源使用
cat /sys/fs/cgroup/memory/docker/[container_id]/memory.usage_in_bytes
cat /sys/fs/cgroup/cpu/docker/[container_id]/cpuacct.usage
```

#### 2.1.2 绝对路径与相对路径

**绝对路径：**

- 从根目录（/）开始的完整路径
- 始终以 `/` 开头
- 不依赖当前位置

```bash
# 绝对路径示例
/home/student/Documents/file.txt
/etc/passwd
/usr/bin/python3
```

**相对路径：**

- 相对于当前目录的路径
- 不以 `/` 开头
- 使用特殊符号：
  - `.` 表示当前目录
  - `..` 表示上级目录
  - `~` 表示用户主目录

```bash
# 相对路径示例
./file.txt          # 当前目录下的文件
../parent_dir/      # 上级目录下的子目录
../../file.txt      # 上两级目录下的文件
~/Documents/        # 用户主目录下的 Documents
```

#### 2.1.3 基础导航命令

**pwd - 显示当前目录**：

```bash
# 显示当前工作目录
pwd
# 输出：/home/student/Documents

# 显示物理路径（解析符号链接）
pwd -P
```

**cd - 切换目录**：

```bash
# 切换到指定目录
cd /etc
cd ~/Documents
cd ../parent_dir

# 特殊用法
cd          # 回到用户主目录
cd ~        # 回到用户主目录
cd -        # 回到上一个目录
cd ..       # 回到上级目录
cd /        # 回到根目录
```

**ls - 列出目录内容**：

```bash
# 基本用法
ls                  # 列出当前目录内容
ls /etc             # 列出指定目录内容

# 常用选项
ls -l               # 详细信息（长格式）
ls -a               # 显示隐藏文件
ls -la              # 详细信息 + 隐藏文件
ls -lh              # 人类可读的文件大小
ls -lt              # 按修改时间排序
ls -lS              # 按文件大小排序
ls -lr              # 递归显示子目录

# 输出格式解读
# drwxr-xr-x 2 user group 4096 Jan 15 10:30 dirname
# ↑         ↑ ↑    ↑     ↑    ↑           ↑
# 权限      链接 用户 组   大小 修改时间    名称
```

#### 2.1.4 文件和目录操作

**mkdir - 创建目录**：

```bash
# 创建单个目录
mkdir new_directory

# 创建多个目录
mkdir dir1 dir2 dir3

# 创建多级目录
mkdir -p parent/child/grandchild

# 设置权限
mkdir -m 755 secure_dir
```

**rmdir - 删除空目录**：

```bash
# 删除空目录
rmdir empty_directory

# 删除多级空目录
rmdir -p parent/child/grandchild
```

**rm - 删除文件和目录**：

```bash
# 删除文件
rm file.txt
rm file1.txt file2.txt

# 删除目录及其内容
rm -r directory/
rm -rf directory/    # 强制删除，不提示

# 交互式删除
rm -i file.txt       # 删除前确认

# 安全删除
rm -v file.txt       # 显示删除过程
```

**cp - 复制文件和目录**：

```bash
# 复制文件
cp source.txt destination.txt
cp source.txt /path/to/destination/

# 复制目录
cp -r source_dir/ destination_dir/

# 保持属性
cp -p file.txt backup.txt    # 保持时间戳和权限
cp -a source/ backup/        # 归档模式（保持所有属性）

# 交互式复制
cp -i source.txt dest.txt    # 覆盖前确认

# 更新复制
cp -u source.txt dest.txt    # 仅当源文件更新时才复制
```

**mv - 移动/重命名文件和目录**：

```bash
# 重命名文件
mv old_name.txt new_name.txt

# 移动文件
mv file.txt /path/to/destination/
mv file1.txt file2.txt /destination/

# 移动目录
mv source_dir/ /path/to/destination/

# 交互式移动
mv -i source.txt destination.txt

# 备份模式
mv -b source.txt destination.txt  # 覆盖时创建备份
```

**实践练习：**

```bash
# 练习 1：目录导航
cd ~
pwd
ls -la
cd /etc
ls -l | head -10
cd -

# 练习 2：创建目录结构
mkdir -p ~/practice/linux/basics
cd ~/practice/linux/basics
pwd

# 练习 3：文件操作
touch file1.txt file2.txt
ls -l
cp file1.txt file1_backup.txt
mv file2.txt renamed_file.txt
ls -l

# 练习 4：清理
cd ~
rm -rf ~/practice
```

### 2.3 文件权限和所有权

#### 2.3.1 用户、组和其他用户权限

Linux 是多用户系统，每个文件和目录都有所有者和权限设置。

**权限类型：**

- **r (read)**：读权限
  - 文件：可以查看文件内容
  - 目录：可以列出目录内容
- **w (write)**：写权限
  - 文件：可以修改文件内容
  - 目录：可以在目录中创建、删除文件
- **x (execute)**：执行权限
  - 文件：可以执行文件（如脚本、程序）
  - 目录：可以进入目录

**权限对象：**

- **u (user)**：文件所有者
- **g (group)**：文件所属组
- **o (others)**：其他用户
- **a (all)**：所有用户

#### 2.3.2 权限表示方法

**符号表示法：**

```bash
# ls -l 输出示例
-rw-r--r-- 1 user group 1024 Jan 15 10:30 file.txt
drwxr-xr-x 2 user group 4096 Jan 15 10:30 directory

# 权限位解读
# 第1位：文件类型
#   - : 普通文件
#   d : 目录
#   l : 符号链接
#   c : 字符设备
#   b : 块设备
#   p : 命名管道
#   s : 套接字

# 第2-4位：所有者权限 (user)
# 第5-7位：组权限 (group)
# 第8-10位：其他用户权限 (others)
```

**数字表示法：**

```bash
# 权限数值对应
r (read)    = 4
w (write)   = 2
x (execute) = 1

# 常见权限组合
0 = --- (无权限)
1 = --x (仅执行)
2 = -w- (仅写入)
3 = -wx (写入+执行)
4 = r-- (仅读取)
5 = r-x (读取+执行)
6 = rw- (读取+写入)
7 = rwx (全部权限)

# 三位数字权限
755 = rwxr-xr-x  # 所有者全权限，组和其他用户读取+执行
644 = rw-r--r--  # 所有者读写，组和其他用户只读
600 = rw-------  # 仅所有者读写
777 = rwxrwxrwx  # 所有人全权限（不安全）
```

#### 2.3.3 chmod 命令

**符号模式：**

```bash
# 基本语法：chmod [who][operator][permissions] file

# 添加权限
chmod u+x file.txt        # 给所有者添加执行权限
chmod g+w file.txt        # 给组添加写权限
chmod o+r file.txt        # 给其他用户添加读权限
chmod a+x file.txt        # 给所有人添加执行权限

# 移除权限
chmod u-w file.txt        # 移除所有者写权限
chmod g-x file.txt        # 移除组执行权限
chmod o-r file.txt        # 移除其他用户读权限

# 设置权限
chmod u=rwx file.txt      # 设置所有者权限为 rwx
chmod g=r file.txt        # 设置组权限为只读
chmod o= file.txt         # 移除其他用户所有权限

# 组合操作
chmod u+x,g-w,o=r file.txt
```

**数字模式：**

```bash
# 设置文件权限
chmod 755 script.sh       # rwxr-xr-x
chmod 644 document.txt    # rw-r--r--
chmod 600 private.txt     # rw-------
chmod 777 shared.txt      # rwxrwxrwx

# 递归设置目录权限
chmod -R 755 /path/to/directory

# 仅设置目录权限
find /path -type d -exec chmod 755 {} \;

# 仅设置文件权限
find /path -type f -exec chmod 644 {} \;
```

#### 2.3.4 chown 和 chgrp 命令

**chown - 更改文件所有者**：

```bash
# 更改所有者
chown newuser file.txt
chown newuser:newgroup file.txt

# 仅更改组
chown :newgroup file.txt

# 递归更改
chown -R user:group /path/to/directory

# 参考文件设置
chown --reference=ref_file target_file
```

**chgrp - 更改文件组**：

```bash
# 更改文件组
chgrp newgroup file.txt

# 递归更改
chgrp -R newgroup /path/to/directory

# 参考文件设置
chgrp --reference=ref_file target_file
```

#### 2.3.5 特殊权限

**Sticky Bit（粘滞位）**：

```bash
# 设置 sticky bit（通常用于 /tmp）
chmod +t /path/to/directory
chmod 1755 /path/to/directory

# 效果：只有文件所有者才能删除自己的文件
# 显示：drwxrwxrwt（末尾的 t）
```

**SUID（Set User ID）**：

```bash
# 设置 SUID
chmod u+s /path/to/executable
chmod 4755 /path/to/executable

# 效果：执行时以文件所有者身份运行
# 显示：-rwsr-xr-x（所有者执行位显示为 s）
# 例子：/usr/bin/passwd
```

**SGID（Set Group ID）**：

```bash
# 对文件设置 SGID
chmod g+s /path/to/executable
chmod 2755 /path/to/executable

# 对目录设置 SGID
chmod g+s /path/to/directory
# 效果：目录中新建文件继承目录的组

# 显示：-rwxr-sr-x（组执行位显示为 s）
```

**实践练习：**

```bash
# 练习 1：基本权限操作
touch test_file.txt
ls -l test_file.txt
chmod 755 test_file.txt
ls -l test_file.txt

# 练习 2：符号模式
chmod u+x,g-w,o=r test_file.txt
ls -l test_file.txt

# 练习 3：查看权限
stat test_file.txt

# 练习 4：目录权限
mkdir test_dir
chmod 755 test_dir
ls -ld test_dir

# 练习 5：特殊权限演示
mkdir sticky_test
chmod +t sticky_test
ls -ld sticky_test

# 清理
rm -rf test_file.txt test_dir sticky_test
```

---

## 第三章：文件操作和文本处理

### 3.1 文件查看和编辑

#### 3.1.1 文件内容查看命令

**cat - 显示文件内容**：

```bash
# 显示文件内容
cat file.txt

# 显示多个文件
cat file1.txt file2.txt

# 显示行号
cat -n file.txt

# 显示非打印字符
cat -A file.txt

# 合并文件
cat file1.txt file2.txt > merged.txt

# 创建文件（输入内容后按 Ctrl+D 结束）
cat > newfile.txt
Hello World
^D
```

**less - 分页查看文件**：

```bash
# 分页查看文件
less file.txt

# less 内部命令
# 空格键或 f    - 向下翻页
# b             - 向上翻页
# /pattern      - 向下搜索
# ?pattern      - 向上搜索
# n             - 下一个搜索结果
# N             - 上一个搜索结果
# g             - 跳到文件开头
# G             - 跳到文件结尾
# q             - 退出

# 显示行号
less -N file.txt

# 忽略大小写搜索
less -i file.txt
```

**more - 简单分页查看**：

```bash
# 分页查看文件
more file.txt

# 空格键 - 下一页
# Enter - 下一行
# q - 退出

# 从指定行开始
more +10 file.txt
```

**head - 查看文件开头**：

```bash
# 显示前10行（默认）
head file.txt

# 显示前20行
head -n 20 file.txt
head -20 file.txt

# 显示前1KB内容
head -c 1024 file.txt

# 查看多个文件
head file1.txt file2.txt

# 实时监控文件开头（较少使用）
head -f file.txt
```

**tail - 查看文件结尾**：

```bash
# 显示后10行（默认）
tail file.txt

# 显示后20行
tail -n 20 file.txt
tail -20 file.txt

# 从第10行开始显示到结尾
tail -n +10 file.txt

# 实时监控文件变化（重要！）
tail -f /var/log/syslog
tail -F file.txt  # 文件被重新创建时继续监控

# 监控多个文件
tail -f file1.txt file2.txt

# 显示最后1KB内容
tail -c 1024 file.txt
```

#### 3.1.2 文本编辑器

**nano - 简单易用的编辑器**：

```bash
# 打开文件编辑
nano file.txt

# 常用快捷键
# Ctrl + O  - 保存文件
# Ctrl + X  - 退出编辑器
# Ctrl + W  - 搜索文本
# Ctrl + K  - 剪切当前行
# Ctrl + U  - 粘贴
# Ctrl + G  - 显示帮助
# Ctrl + C  - 显示光标位置
# Alt + U   - 撤销
# Alt + E   - 重做

# 打开时跳到指定行
nano +25 file.txt

# 显示行号
nano -l file.txt
```

**vim 基础操作**：

```bash
# 打开文件
vim file.txt

# Vim 模式
# 普通模式（Normal Mode）- 默认模式，用于导航和命令
# 插入模式（Insert Mode）- 用于编辑文本
# 命令模式（Command Mode）- 用于执行命令

# 模式切换
# i, a, o  - 进入插入模式
# Esc      - 返回普通模式
# :        - 进入命令模式

# 普通模式下的移动
# h, j, k, l  - 左、下、上、右
# w, b        - 按单词前进、后退
# 0, $        - 行首、行尾
# gg, G       - 文件开头、结尾
# Ctrl+f, Ctrl+b - 向下、向上翻页

# 编辑操作
# x    - 删除字符
# dd   - 删除行
# yy   - 复制行
# p    - 粘贴
# u    - 撤销
# Ctrl+r - 重做

# 命令模式
# :w   - 保存
# :q   - 退出
# :wq  - 保存并退出
# :q!  - 强制退出不保存
# :set number - 显示行号
# :/pattern   - 搜索
# :s/old/new/g - 替换
```

#### 3.1.3 文件搜索

**find - 强大的文件搜索工具**：

```bash
# 基本语法：find [路径] [条件] [动作]

# 按名称搜索
find /home -name "*.txt"          # 查找所有 .txt 文件
find . -name "config*"            # 查找以 config 开头的文件
find /etc -iname "*conf*"         # 忽略大小写搜索

# 按类型搜索
find /var -type f                 # 查找普通文件
find /dev -type d                 # 查找目录
find /tmp -type l                 # 查找符号链接

# 按大小搜索
find /home -size +100M            # 查找大于100MB的文件
find /tmp -size -1k               # 查找小于1KB的文件
find . -size 50c                  # 查找正好50字节的文件

# 按时间搜索
find /var/log -mtime -7           # 7天内修改的文件
find /tmp -atime +30              # 30天前访问的文件
find . -ctime -1                  # 1天内状态改变的文件

# 按权限搜索
find /home -perm 755              # 权限为755的文件
find /tmp -perm -644              # 至少有644权限的文件
find . -perm /u+w                 # 所有者有写权限的文件

# 按用户搜索
find /home -user john             # 属于用户john的文件
find /var -group www-data         # 属于www-data组的文件

# 执行动作
find /tmp -name "*.tmp" -delete   # 删除找到的文件
find . -name "*.log" -exec rm {} \;  # 执行命令删除
find /home -name "*.bak" -exec mv {} {}.old \;  # 重命名

# 组合条件
find /var/log -name "*.log" -and -size +10M     # 与条件
find /tmp -name "*.tmp" -or -name "*.cache"     # 或条件
find /home -not -name ".*"                      # 非条件

# 限制搜索深度
find /usr -maxdepth 2 -name "bin"  # 最多搜索2层目录
find /home -mindepth 2 -name "*"   # 至少从第2层开始搜索
```

**locate - 快速文件定位**：

```bash
# 更新数据库（通常由系统自动执行）
sudo updatedb

# 搜索文件
locate filename
locate "*.conf"

# 忽略大小写
locate -i filename

# 限制结果数量
locate -l 10 "*.log"

# 显示统计信息
locate -S

# 注意：locate 基于数据库，新创建的文件可能搜索不到
```

### 3.2 文本处理工具

#### 3.2.1 grep - 文本搜索工具

**基本用法**：

```bash
# 搜索包含指定文本的行
grep "pattern" file.txt
grep "error" /var/log/syslog

# 常用选项
grep -i "pattern" file.txt        # 忽略大小写
grep -v "pattern" file.txt        # 反向匹配（不包含）
grep -n "pattern" file.txt        # 显示行号
grep -c "pattern" file.txt        # 统计匹配行数
grep -l "pattern" *.txt           # 只显示文件名
grep -h "pattern" *.txt           # 不显示文件名

# 递归搜索
grep -r "pattern" /path/to/dir    # 递归搜索目录
grep -R "pattern" /path/to/dir    # 递归搜索（跟随符号链接）

# 上下文显示
grep -A 3 "pattern" file.txt      # 显示匹配行及后3行
grep -B 3 "pattern" file.txt      # 显示匹配行及前3行
grep -C 3 "pattern" file.txt      # 显示匹配行及前后3行

# 多个模式
grep -E "pattern1|pattern2" file.txt  # 扩展正则表达式
grep -F "literal string" file.txt     # 固定字符串匹配
```

**正则表达式基础**：

```bash
# 基本正则表达式元字符
.        # 匹配任意单个字符
*        # 匹配前面字符0次或多次
^        # 行首
$        # 行尾
[]       # 字符类
\        # 转义字符

# 示例
grep "^error" file.txt           # 以error开头的行
grep "error$" file.txt           # 以error结尾的行
grep "e.ror" file.txt            # e和r之间有任意字符
grep "erro*r" file.txt           # err后面有0个或多个o
grep "[Ee]rror" file.txt         # Error或error
grep "[0-9]" file.txt            # 包含数字的行
grep "[^0-9]" file.txt           # 不包含数字的行

# 扩展正则表达式（grep -E 或 egrep）
+        # 匹配前面字符1次或多次
?        # 匹配前面字符0次或1次
|        # 或操作
()       # 分组
{n,m}    # 匹配n到m次

# 示例
grep -E "erro+r" file.txt        # err后面有1个或多个o
grep -E "errors?" file.txt       # error或errors
grep -E "(error|warning)" file.txt  # error或warning
grep -E "[0-9]{3,5}" file.txt    # 3到5位数字
```

#### 3.2.2 sed - 流编辑器

**基本用法**：

```bash
# 基本语法：sed 's/old/new/flags' file

# 替换操作
sed 's/old/new/' file.txt         # 替换每行第一个匹配
sed 's/old/new/g' file.txt        # 替换所有匹配
sed 's/old/new/2' file.txt        # 替换每行第二个匹配
sed 's/old/new/gi' file.txt       # 全局替换，忽略大小写

# 指定行操作
sed '3s/old/new/' file.txt        # 只替换第3行
sed '1,5s/old/new/g' file.txt     # 替换1-5行
sed '/pattern/s/old/new/g' file.txt  # 在包含pattern的行中替换

# 删除操作
sed '3d' file.txt                 # 删除第3行
sed '1,5d' file.txt               # 删除1-5行
sed '/pattern/d' file.txt         # 删除包含pattern的行
sed '/^$/d' file.txt              # 删除空行

# 插入和追加
sed '3i\New line' file.txt        # 在第3行前插入
sed '3a\New line' file.txt        # 在第3行后追加
sed '/pattern/i\New line' file.txt  # 在匹配行前插入

# 打印操作
sed -n '1,5p' file.txt            # 只打印1-5行
sed -n '/pattern/p' file.txt      # 只打印匹配行

# 修改文件（谨慎使用）
sed -i 's/old/new/g' file.txt     # 直接修改文件
sed -i.bak 's/old/new/g' file.txt # 修改前备份
```

#### 3.2.3 awk - 文本处理语言

**基本概念**：

```bash
# AWK 程序结构：pattern { action }
# 内置变量：
# $0  - 整行
# $1, $2, ... - 第1列、第2列等
# NF  - 字段数量
# NR  - 行号
# FS  - 字段分隔符（默认空格）
# OFS - 输出字段分隔符
```

**基本用法**：

```bash
# 打印特定列
awk '{print $1}' file.txt         # 打印第1列
awk '{print $1, $3}' file.txt     # 打印第1和第3列
awk '{print NR, $0}' file.txt     # 打印行号和整行

# 字段分隔符
awk -F: '{print $1}' /etc/passwd  # 以冒号为分隔符
awk 'BEGIN{FS=":"} {print $1}' /etc/passwd  # 设置分隔符

# 条件处理
awk '$3 > 100' file.txt           # 第3列大于100的行
awk '/pattern/ {print $1}' file.txt  # 匹配pattern的行的第1列
awk 'NR==5' file.txt              # 第5行
awk 'NF==3' file.txt              # 有3个字段的行

# 计算操作
awk '{sum += $1} END {print sum}' file.txt     # 第1列求和
awk '{print $1 * $2}' file.txt                 # 第1列乘以第2列
awk 'BEGIN{count=0} /pattern/ {count++} END{print count}' file.txt  # 计数

# 格式化输出
awk '{printf "%-10s %5d\n", $1, $2}' file.txt  # 格式化打印

# 实用示例
# 统计文件大小
ls -l | awk '{sum += $5} END {print "Total:", sum}'

# 提取IP地址
awk '/192.168/ {print $1}' access.log

# 处理CSV文件
awk -F, '{print $2}' data.csv
```

#### 3.2.4 排序和去重

**sort - 排序工具**：

```bash
# 基本排序
sort file.txt                     # 按字典序排序
sort -n file.txt                  # 按数值排序
sort -r file.txt                  # 逆序排序
sort -u file.txt                  # 排序并去重

# 按列排序
sort -k2 file.txt                 # 按第2列排序
sort -k2,2 file.txt               # 只按第2列排序
sort -k1,1 -k2,2n file.txt        # 先按第1列，再按第2列数值排序

# 指定分隔符
sort -t: -k3n /etc/passwd         # 以冒号分隔，按第3列数值排序

# 其他选项
sort -f file.txt                  # 忽略大小写
sort -b file.txt                  # 忽略前导空格
sort -M file.txt                  # 按月份排序
sort -h file.txt                  # 按人类可读大小排序

# 检查是否已排序
sort -c file.txt                  # 检查是否已排序
```

**uniq - 去重工具**：

```bash
# 基本去重（需要先排序）
sort file.txt | uniq              # 去除重复行

# 统计重复
uniq -c file.txt                  # 显示重复次数
uniq -d file.txt                  # 只显示重复行
uniq -u file.txt                  # 只显示唯一行

# 忽略大小写
uniq -i file.txt

# 跳过字段
uniq -f 1 file.txt                # 跳过第1个字段
uniq -s 5 file.txt                # 跳过前5个字符

# 实用组合
sort file.txt | uniq -c | sort -nr  # 按重复次数排序
```

#### 3.2.5 文本统计

**wc - 统计工具**：

```bash
# 基本统计
wc file.txt                       # 显示行数、单词数、字节数
wc -l file.txt                    # 只显示行数
wc -w file.txt                    # 只显示单词数
wc -c file.txt                    # 只显示字节数
wc -m file.txt                    # 只显示字符数

# 统计多个文件
wc *.txt                          # 统计所有txt文件

# 实用示例
ls | wc -l                        # 统计当前目录文件数
ps aux | wc -l                    # 统计进程数
grep "error" /var/log/syslog | wc -l  # 统计错误日志行数
```

### 3.3 输入输出重定向

#### 3.3.1 标准输入、输出、错误

Linux 系统为每个进程提供三个标准文件描述符：

```bash
# 文件描述符
0 - stdin  (标准输入)   - 默认从键盘读取
1 - stdout (标准输出)   - 默认输出到终端
2 - stderr (标准错误)   - 默认输出到终端
```

#### 3.3.2 重定向操作符

**输出重定向**：

```bash
# 重定向标准输出
command > file.txt                # 覆盖写入文件
command >> file.txt               # 追加到文件

# 示例
ls > filelist.txt                 # 将ls输出保存到文件
date >> log.txt                   # 将日期追加到日志
echo "Hello" > greeting.txt       # 创建文件并写入内容

# 重定向标准错误
command 2> error.log              # 错误输出到文件
command 2>> error.log             # 错误追加到文件

# 同时重定向输出和错误
command > output.txt 2> error.txt # 分别重定向
command > all.log 2>&1            # 错误重定向到输出
command &> all.log                # 简化写法（Bash）
command >> all.log 2>&1           # 追加模式

# 丢弃输出
command > /dev/null               # 丢弃标准输出
command 2> /dev/null              # 丢弃错误输出
command &> /dev/null              # 丢弃所有输出
```

**输入重定向**：

```bash
# 从文件读取输入
command < input.txt

# 示例
mail user@example.com < message.txt  # 发送邮件
sort < unsorted.txt > sorted.txt     # 排序文件
wc -l < file.txt                     # 统计行数

# Here Document（多行输入）
cat << EOF > config.txt
server=localhost
port=8080
database=mydb
EOF

# Here String
grep "pattern" <<< "search in this string"
```

#### 3.3.3 管道操作

**基本管道**：

```bash
# 基本语法：command1 | command2
# command1的输出作为command2的输入

# 简单示例
ls | grep ".txt"                  # 列出txt文件
ps aux | grep "firefox"           # 查找firefox进程
cat file.txt | wc -l              # 统计文件行数
history | tail -10                # 显示最近10条命令
```

**复杂管道组合**：

```bash
# 多级管道
ps aux | grep -v grep | grep "python" | wc -l
# 查找python进程数（排除grep自身）

cat /var/log/access.log | grep "404" | awk '{print $1}' | sort | uniq -c | sort -nr
# 分析404错误的IP地址频率

ls -la | awk '{print $5, $9}' | sort -n | tail -5
# 找出最大的5个文件

netstat -tuln | grep ":80 " | wc -l
# 统计80端口连接数
```

**tee 命令 - T型管道**：

```bash
# tee 同时输出到文件和标准输出
command | tee file.txt            # 保存到文件同时显示
command | tee -a file.txt         # 追加模式
command | tee file1.txt file2.txt # 输出到多个文件

# 示例
ls -la | tee filelist.txt | grep "drw"  # 保存列表同时过滤目录
ping google.com | tee ping.log          # 保存ping结果同时显示
```

#### 3.3.4 组合命令的强大功能

**命令连接符**：

```bash
# 顺序执行
command1 ; command2               # 依次执行，不管成功失败

# 条件执行
command1 && command2              # command1成功才执行command2
command1 || command2              # command1失败才执行command2

# 示例
mkdir test && cd test             # 创建目录成功后进入
ping -c1 google.com && echo "Network OK" || echo "Network Error"

# 后台执行
command &                         # 后台执行
command1 & command2 &             # 同时后台执行多个命令
```

**实用组合示例**：

```bash
# 系统监控
ps aux | sort -k3nr | head -10    # CPU使用率最高的10个进程
df -h | grep -v "tmpfs"           # 磁盘使用情况（排除临时文件系统）
netstat -tuln | grep LISTEN       # 监听端口

# 日志分析
tail -f /var/log/syslog | grep "error"  # 实时监控错误日志
cat access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
# 访问最频繁的IP地址

# 文件处理
find /home -name "*.log" -exec wc -l {} \; | awk '{sum+=$1} END{print sum}'
# 统计所有日志文件总行数

grep -r "TODO" /path/to/project | wc -l
# 统计项目中TODO数量

# 系统清理
find /tmp -type f -mtime +7 -delete  # 删除7天前的临时文件
du -sh /var/log/* | sort -hr | head -5  # 找出最大的5个日志文件
```

**实践练习**：

```bash
# 练习1：文件查看
echo -e "Line 1\nLine 2\nLine 3\nLine 4\nLine 5" > test.txt
cat test.txt
head -3 test.txt
tail -2 test.txt

# 练习2：文本搜索
echo -e "apple\nbanana\nApple\ncherry" > fruits.txt
grep "apple" fruits.txt
grep -i "apple" fruits.txt
grep -v "apple" fruits.txt

# 练习3：管道组合
ls -la | grep "^d"                # 只显示目录
ps aux | grep $USER | wc -l       # 统计当前用户进程数
history | grep "git" | tail -5    # 最近5条git命令

# 练习4：重定向
date > timestamp.txt
echo "Current user: $USER" >> timestamp.txt
cat timestamp.txt

# 清理
rm -f test.txt fruits.txt timestamp.txt
```

---

## 第四章：进程和系统管理

### 4.1 进程管理

#### 4.1.1 进程概念和生命周期

**进程基本概念**：

```bash
# 进程（Process）是正在运行的程序实例
# 每个进程都有唯一的进程ID（PID）
# 进程状态：
# R - Running（运行中）
# S - Sleeping（可中断睡眠）
# D - Uninterruptible sleep（不可中断睡眠）
# T - Stopped（停止）
# Z - Zombie（僵尸进程）
# X - Dead（死亡）

# 进程关系：
# 父进程（Parent Process）- PPID
# 子进程（Child Process）
# 进程组（Process Group）
# 会话（Session）
```

**进程生命周期**：

```bash
# 1. 创建（Fork）- 父进程创建子进程
# 2. 执行（Exec）- 加载新程序
# 3. 运行（Running）- 获得CPU时间片执行
# 4. 等待（Waiting）- 等待资源或事件
# 5. 终止（Termination）- 进程结束
# 6. 清理（Cleanup）- 释放资源

# 查看当前Shell的PID
echo $$

# 查看父进程PID
echo $PPID

# 创建子进程示例
bash &  # 在后台启动新的bash进程
ps -f   # 查看进程树关系
```

#### 4.1.2 进程管理命令

**ps - 进程快照**：

```bash
# 基本用法
ps                    # 显示当前终端的进程
ps -e                 # 显示所有进程
ps -f                 # 显示完整格式
ps -l                 # 显示长格式

# 常用组合
ps aux                # 显示所有进程的详细信息
ps -ef                # 显示所有进程的完整信息
ps -eLf               # 显示线程信息

# 输出字段说明（ps aux）：
# USER   - 进程所有者
# PID    - 进程ID
# %CPU   - CPU使用率
# %MEM   - 内存使用率
# VSZ    - 虚拟内存大小（KB）
# RSS    - 物理内存大小（KB）
# TTY    - 终端类型
# STAT   - 进程状态
# START  - 启动时间
# TIME   - CPU累计时间
# COMMAND- 命令行

# 过滤和排序
ps aux | grep "firefox"           # 查找特定进程
ps aux | sort -k3nr | head -10    # 按CPU使用率排序
ps aux | sort -k4nr | head -10    # 按内存使用率排序

# 进程树显示
ps -ef --forest       # 显示进程树
pstree                # 树形显示进程关系
pstree -p             # 显示PID
pstree username       # 显示特定用户的进程树

# 自定义输出格式
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu
ps -eo pid,user,cmd,etime  # 显示运行时间
```

**top - 动态进程监控**：

```bash
# 启动top
top

# top界面说明：
# 第1行：系统时间、运行时间、用户数、负载平均值
# 第2行：进程总数、运行、睡眠、停止、僵尸进程数
# 第3行：CPU使用率（用户、系统、空闲等）
# 第4行：内存使用情况
# 第5行：交换分区使用情况

# top内部命令：
# h 或 ?  - 显示帮助
# q       - 退出
# k       - 终止进程（输入PID）
# r       - 重新设置进程优先级
# M       - 按内存使用率排序
# P       - 按CPU使用率排序
# T       - 按运行时间排序
# u       - 显示特定用户的进程
# 1       - 显示所有CPU核心
# f       - 选择显示字段
# o       - 改变排序字段
# W       - 保存配置

# top命令选项
top -d 2              # 每2秒更新一次
top -n 5              # 更新5次后退出
top -p 1234           # 只监控特定PID
top -u username       # 只显示特定用户的进程
top -b                # 批处理模式（适合脚本）

# 批处理模式示例
top -b -n 1 | head -20  # 获取一次快照
```

**htop - 增强版top**：

```bash
# 安装htop（如果未安装）
# Ubuntu/Debian: sudo apt install htop
# CentOS/RHEL: sudo yum install htop
# macOS: brew install htop

# 启动htop
htop

# htop特点：
# - 彩色界面
# - 支持鼠标操作
# - 可视化CPU和内存使用
# - 进程树显示
# - 更直观的操作界面

# htop快捷键：
# F1  - 帮助
# F2  - 设置
# F3  - 搜索进程
# F4  - 过滤
# F5  - 树形显示
# F6  - 排序
# F9  - 终止进程
# F10 - 退出
# u   - 选择用户
# t   - 树形切换
# H   - 显示/隐藏线程
# K   - 显示/隐藏内核线程
```

#### 4.1.3 进程控制

**kill - 终止进程**：

```bash
# 基本语法：kill [选项] PID

# 常用信号：
# SIGTERM (15) - 正常终止（默认）
# SIGKILL (9)  - 强制终止
# SIGHUP (1)   - 挂起
# SIGSTOP (19) - 停止进程
# SIGCONT (18) - 继续进程

# 基本用法
kill 1234             # 发送SIGTERM信号给PID 1234
kill -9 1234          # 强制终止进程
kill -15 1234         # 正常终止（同默认）
kill -TERM 1234       # 使用信号名
kill -KILL 1234       # 强制终止

# 查看所有信号
kill -l

# 终止进程组
kill -TERM -1234      # 终止进程组（负号表示进程组）

# 实用示例
# 优雅终止进程
kill -TERM $PID && sleep 5 && kill -KILL $PID

# 终止所有同名进程
pkill firefox         # 按进程名终止
pkill -u username     # 终止特定用户的所有进程
pkill -f "python script.py"  # 按命令行匹配

# killall - 按名称终止进程
killall firefox       # 终止所有firefox进程
killall -9 firefox    # 强制终止
killall -u username firefox  # 终止特定用户的firefox
```

**jobs - 作业控制**：

```bash
# 查看当前Shell的作业
jobs
jobs -l               # 显示PID
jobs -p               # 只显示PID
jobs -r               # 只显示运行中的作业
jobs -s               # 只显示停止的作业

# 作业状态：
# Running   - 运行中
# Stopped   - 已停止
# Done      - 已完成

# 作业控制命令
fg                    # 将后台作业调到前台
fg %1                 # 将作业1调到前台
bg                    # 将停止的作业在后台继续
bg %1                 # 将作业1在后台继续

# 示例
sleep 100 &           # 后台运行
jobs                  # 查看作业
fg %1                 # 调到前台
# 按Ctrl+Z停止
bg %1                 # 后台继续
kill %1               # 终止作业1
```

#### 4.1.4 后台进程

**& - 后台执行**：

```bash
# 在命令后加&使其在后台运行
command &

# 示例
ping google.com &     # 后台ping
cp large_file.iso /backup/ &  # 后台复制大文件

# 查看后台进程
jobs
ps aux | grep "ping"

# 注意：终端关闭时后台进程也会终止
```

**nohup - 忽略挂起信号**：

```bash
# nohup使进程忽略SIGHUP信号，终端关闭后继续运行
nohup command &

# 示例
nohup ping google.com &           # 后台运行，忽略挂起
nohup python script.py &          # 后台运行Python脚本
nohup ./long_running_task.sh &    # 后台运行脚本

# 输出重定向
nohup command > output.log 2>&1 &  # 重定向输出到文件
nohup command > /dev/null 2>&1 &   # 丢弃所有输出

# 默认输出文件：nohup.out
ls -la nohup.out
tail -f nohup.out     # 实时查看输出
```

**screen - 终端复用器**：

```bash
# 安装screen（如果未安装）
# Ubuntu/Debian: sudo apt install screen
# CentOS/RHEL: sudo yum install screen

# 基本用法
screen                # 启动新会话
screen -S session_name  # 创建命名会话

# screen内部命令（Ctrl+A前缀）：
# Ctrl+A, d  - 分离会话（detach）
# Ctrl+A, c  - 创建新窗口
# Ctrl+A, n  - 下一个窗口
# Ctrl+A, p  - 上一个窗口
# Ctrl+A, "  - 列出所有窗口
# Ctrl+A, k  - 终止当前窗口
# Ctrl+A, ?  - 显示帮助

# 会话管理
screen -ls            # 列出所有会话
screen -r             # 重新连接会话
screen -r session_name  # 连接特定会话
screen -d session_name  # 强制分离会话
screen -X -S session_name quit  # 终止会话

# 实用示例
# 1. 启动长时间运行的任务
screen -S backup
rsync -av /home/ /backup/
# Ctrl+A, d 分离

# 2. 稍后重新连接
screen -r backup

# 3. 多窗口工作
screen -S work
# Ctrl+A, c 创建新窗口
# 在不同窗口运行不同任务
```

### 4.2 系统监控

#### 4.2.1 系统资源监控

**free - 内存使用情况**：

```bash
# 基本用法
free                  # 显示内存使用情况
free -h               # 人类可读格式
free -m               # 以MB为单位
free -g               # 以GB为单位
free -s 2             # 每2秒更新一次

# 输出字段说明：
# total     - 总内存
# used      - 已使用内存
# free      - 空闲内存
# shared    - 共享内存
# buff/cache- 缓冲/缓存
# available - 可用内存

# 清理缓存（需要root权限）
sudo sync             # 同步数据到磁盘
sudo echo 3 > /proc/sys/vm/drop_caches  # 清理缓存

# 监控内存使用
watch -n 1 free -h    # 每秒更新内存状态
```

**df - 磁盘空间使用**：

```bash
# 基本用法
df                    # 显示文件系统磁盘使用情况
df -h                 # 人类可读格式
df -T                 # 显示文件系统类型
df -i                 # 显示inode使用情况

# 指定文件系统
df /home              # 显示/home分区信息
df .                  # 显示当前目录所在分区

# 排除特定文件系统
df -h -x tmpfs        # 排除tmpfs
df -h -t ext4         # 只显示ext4文件系统

# 输出字段说明：
# Filesystem - 文件系统
# Size       - 总大小
# Used       - 已使用
# Avail      - 可用空间
# Use%       - 使用百分比
# Mounted on - 挂载点

# 监控磁盘使用
watch -n 5 df -h      # 每5秒更新

# 查找大文件
df -h | grep -E '(8[0-9]|9[0-9])%'  # 查找使用率超过80%的分区
```

**du - 目录空间使用**：

```bash
# 基本用法
du                    # 显示当前目录及子目录大小
du -h                 # 人类可读格式
du -s                 # 只显示总计
du -a                 # 显示所有文件和目录

# 指定目录
du -h /home           # 显示/home目录大小
du -sh /var/log/*     # 显示/var/log下各文件/目录大小

# 排序和限制
du -h | sort -hr      # 按大小排序
du -h --max-depth=1   # 限制显示深度
du -h --max-depth=1 | sort -hr  # 当前目录下各子目录大小排序

# 排除文件
du -h --exclude="*.log" /var  # 排除日志文件
du -h --exclude-from=exclude_list.txt  # 从文件读取排除列表

# 实用示例
# 找出最大的目录
du -h /home | sort -hr | head -10

# 找出大于100MB的目录
du -h /var | awk '$1 ~ /[0-9]+G|[5-9][0-9][0-9]M|[0-9][0-9][0-9][0-9]M/ {print}'

# 监控目录大小变化
watch -n 10 'du -sh /var/log'
```

#### 4.2.2 网络监控

**netstat - 网络连接状态**：

```bash
# 基本用法
netstat               # 显示网络连接
netstat -a            # 显示所有连接和监听端口
netstat -t            # 只显示TCP连接
netstat -u            # 只显示UDP连接
netstat -l            # 只显示监听端口
netstat -n            # 显示数字地址而不解析主机
netstat -p            # 显示进程ID和名称

# 常用组合
netstat -tuln         # 显示所有TCP/UDP监听端口（数字格式）
netstat -tulnp        # 包含进程信息
netstat -an           # 显示所有连接（数字格式）
netstat -rn           # 显示路由表

# 过滤和统计
netstat -an | grep :80        # 查看80端口连接
netstat -an | grep LISTEN     # 查看监听端口
netstat -an | grep ESTABLISHED | wc -l  # 统计已建立连接数

# 按状态统计连接
netstat -an | awk '/^tcp/ {print $6}' | sort | uniq -c

# 连接状态说明：
# LISTEN      - 监听状态
# ESTABLISHED - 已建立连接
# TIME_WAIT   - 等待关闭
# CLOSE_WAIT  - 等待关闭
# SYN_SENT    - 发送连接请求
# SYN_RECV    - 接收连接请求
```

**ss - 现代网络统计工具**：

```bash
# ss是netstat的现代替代品，速度更快

# 基本用法
ss                    # 显示socket连接
ss -a                 # 显示所有socket
ss -l                 # 显示监听socket
ss -t                 # 显示TCP socket
ss -u                 # 显示UDP socket
ss -n                 # 不解析服务名
ss -p                 # 显示进程信息

# 常用组合
ss -tuln              # 显示TCP/UDP监听端口
ss -tulnp             # 包含进程信息
ss -an                # 显示所有连接

# 过滤
ss -t state established  # 显示已建立的TCP连接
ss -t state listening    # 显示监听的TCP端口
ss dst :80            # 显示目标端口80的连接
ss src :22            # 显示源端口22的连接

# 统计信息
ss -s                 # 显示socket统计
ss -i                 # 显示内部TCP信息

# 实用示例
ss -tulnp | grep :22  # 查看SSH服务
ss -t state established | wc -l  # 统计TCP连接数
```

#### 4.2.3 系统信息

**uname - 系统信息**：

```bash
# 基本用法
uname                 # 显示系统名称
uname -a              # 显示所有信息
uname -s              # 系统名称
uname -n              # 网络节点主机名
uname -r              # 内核版本
uname -v              # 内核版本详细信息
uname -m              # 机器硬件架构
uname -p              # 处理器类型
uname -i              # 硬件平台
uname -o              # 操作系统

# 示例输出
uname -a
# Linux hostname 5.4.0-42-generic #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
```

**uptime - 系统运行时间**：

```bash
# 显示系统运行时间和负载
uptime
# 输出示例：
# 14:30:25 up 5 days, 2:15, 3 users, load average: 0.15, 0.25, 0.30

# 字段说明：
# 当前时间：14:30:25
# 运行时间：5天2小时15分钟
# 用户数：3个用户登录
# 负载平均值：1分钟、5分钟、15分钟的平均负载

# 负载平均值说明：
# < 1.0  - 系统负载较轻
# = 1.0  - 系统满负载
# > 1.0  - 系统过载

# 只显示运行时间
uptime -p

# 只显示启动时间
uptime -s
```

**who - 当前登录用户**：

```bash
# 显示当前登录用户
who

# 详细信息
who -a                # 显示所有信息
who -b                # 显示系统启动时间
who -r                # 显示运行级别
who -u                # 显示用户空闲时间

# 相关命令
w                     # 显示用户及其活动
users                 # 显示登录用户名
whoami                # 显示当前用户名
id                    # 显示用户和组ID
last                  # 显示登录历史
lastlog               # 显示最后登录信息
```

### 4.3 定时任务

#### 4.3.1 cron 服务介绍

**cron 系统概述**：

```bash
# cron是Linux系统的定时任务调度器
# 主要组件：
# - crond守护进程：执行定时任务
# - crontab命令：管理用户定时任务
# - cron表达式：定义执行时间

# 检查cron服务状态
sudo systemctl status cron     # Ubuntu/Debian
sudo systemctl status crond    # CentOS/RHEL

# 启动/停止cron服务
sudo systemctl start cron
sudo systemctl stop cron
sudo systemctl restart cron
sudo systemctl enable cron     # 开机自启

# cron相关文件：
# /etc/crontab          - 系统级crontab
# /etc/cron.d/          - 系统级cron任务目录
# /var/spool/cron/      - 用户crontab文件
# /etc/cron.hourly/     - 每小时执行的脚本
# /etc/cron.daily/      - 每天执行的脚本
# /etc/cron.weekly/     - 每周执行的脚本
# /etc/cron.monthly/    - 每月执行的脚本
```

#### 4.3.2 crontab 命令使用

**crontab 基本操作**：

```bash
# 编辑当前用户的crontab
crontab -e

# 查看当前用户的crontab
crontab -l

# 删除当前用户的crontab
crontab -r

# 管理其他用户的crontab（需要root权限）
sudo crontab -u username -e    # 编辑
sudo crontab -u username -l    # 查看
sudo crontab -u username -r    # 删除

# 从文件导入crontab
crontab mycron.txt

# 备份crontab
crontab -l > crontab_backup.txt
```

**cron 表达式格式**：

```bash
# cron表达式格式：
# 分钟(0-59) 小时(0-23) 日期(1-31) 月份(1-12) 星期(0-7) 命令
# *  - 任意值
# ,  - 列举多个值
# -  - 范围
# /  - 步长

# 特殊字符：
# @yearly   = 0 0 1 1 *     # 每年1月1日0点
# @annually = 0 0 1 1 *     # 同@yearly
# @monthly  = 0 0 1 * *     # 每月1日0点
# @weekly   = 0 0 * * 0     # 每周日0点
# @daily    = 0 0 * * *     # 每天0点
# @midnight = 0 0 * * *     # 同@daily
# @hourly   = 0 * * * *     # 每小时
# @reboot                   # 系统启动时
```

#### 4.3.3 定时任务实例

**常用定时任务示例**：

```bash
# 编辑crontab
crontab -e

# 基本示例
# 每分钟执行
* * * * * /path/to/script.sh

# 每小时执行
0 * * * * /path/to/script.sh

# 每天凌晨2点执行
0 2 * * * /path/to/backup.sh

# 每周一上午9点执行
0 9 * * 1 /path/to/weekly_report.sh

# 每月1日凌晨3点执行
0 3 1 * * /path/to/monthly_cleanup.sh

# 工作日每天上午8点执行
0 8 * * 1-5 /path/to/workday_task.sh

# 每10分钟执行
*/10 * * * * /path/to/monitor.sh

# 每2小时执行
0 */2 * * * /path/to/check.sh

# 特定时间执行
30 14 * * * /path/to/afternoon_task.sh  # 每天14:30
0 9,17 * * * /path/to/twice_daily.sh    # 每天9:00和17:00

# 使用特殊字符
@daily /path/to/daily_backup.sh
@weekly /path/to/weekly_cleanup.sh
@reboot /path/to/startup_script.sh
```

**实用定时任务**：

```bash
# 1. 系统备份
0 2 * * * tar -czf /backup/home_$(date +\%Y\%m\%d).tar.gz /home/

# 2. 日志清理
0 3 * * 0 find /var/log -name "*.log" -mtime +30 -delete

# 3. 系统监控
*/5 * * * * df -h | grep -E '(8[0-9]|9[0-9])%' | mail -s "Disk Alert" admin@example.com

# 4. 数据库备份
0 1 * * * mysqldump -u root -p'password' database > /backup/db_$(date +\%Y\%m\%d).sql

# 5. 网站健康检查
*/2 * * * * curl -f http://example.com > /dev/null || echo "Website down" | mail -s "Alert" admin@example.com

# 6. 清理临时文件
0 4 * * * find /tmp -type f -mtime +7 -delete

# 7. 系统更新检查
0 6 * * 1 apt update && apt list --upgradable | mail -s "Updates Available" admin@example.com

# 8. 重启服务
0 5 * * * systemctl restart nginx

# 9. 生成报告
0 23 * * * /home/user/scripts/generate_daily_report.sh

# 10. 同步文件
0 */6 * * * rsync -av /source/ /destination/
```

**cron 任务调试**：

```bash
# 查看cron日志
sudo tail -f /var/log/cron          # CentOS/RHEL
sudo tail -f /var/log/syslog | grep CRON  # Ubuntu/Debian

# 测试cron表达式
# 使用在线工具或命令行工具验证

# 调试技巧
# 1. 使用绝对路径
/usr/bin/python3 /home/user/script.py

# 2. 设置环境变量
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
MAILTO=admin@example.com
0 2 * * * /path/to/script.sh

# 3. 重定向输出
0 2 * * * /path/to/script.sh >> /var/log/myscript.log 2>&1

# 4. 测试脚本
# 先手动运行脚本确保正常工作
/path/to/script.sh

# 5. 使用简单的测试任务
* * * * * echo "Cron is working" >> /tmp/crontest.log

# 常见问题：
# - 环境变量不同：在脚本中设置完整路径
# - 权限问题：确保脚本有执行权限
# - 路径问题：使用绝对路径
# - 输出重定向：避免产生邮件
```

**实践练习**：

```bash
# 练习1：创建简单定时任务
echo '#!/bin/bash' > /tmp/test_cron.sh
echo 'echo "$(date): Cron test" >> /tmp/cron_output.log' >> /tmp/test_cron.sh
chmod +x /tmp/test_cron.sh

# 添加到crontab（每分钟执行）
echo "* * * * * /tmp/test_cron.sh" | crontab -

# 等待几分钟后查看结果
tail /tmp/cron_output.log

# 清理
crontab -r
rm -f /tmp/test_cron.sh /tmp/cron_output.log

# 练习2：系统监控任务
# 创建磁盘监控脚本
# 使用独立的磁盘监控脚本
# 脚本文件：demos/disk_monitor.sh
cp demos/disk_monitor.sh /tmp/disk_monitor.sh
chmod +x /tmp/disk_monitor.sh

# 测试脚本
/tmp/disk_monitor.sh

# 查看系统日志
sudo tail /var/log/syslog | grep disk_monitor

# 清理
rm -f /tmp/disk_monitor.sh
```

---

## 第五章：网络和安全基础

### 5.1 网络基础概念

#### 5.1.1 网络基础知识

**IP 地址和子网掩码**：

IP 地址是网络中设备的唯一标识符，分为 IPv4 和 IPv6 两种格式。

```bash
# IPv4 地址格式：x.x.x.x（每个x为0-255）
# 示例：192.168.1.100

# 地址分类：
# A类：1.0.0.0 - 126.255.255.255    （/8，大型网络）
# B类：128.0.0.0 - 191.255.255.255  （/16，中型网络）
# C类：192.0.0.0 - 223.255.255.255  （/24，小型网络）

# 私有地址范围：
# 10.0.0.0/8        (10.0.0.0 - 10.255.255.255)
# 172.16.0.0/12     (172.16.0.0 - 172.31.255.255)
# 192.168.0.0/16    (192.168.0.0 - 192.168.255.255)

# 特殊地址：
# 127.0.0.1         本地回环地址
# 0.0.0.0           所有地址
# 255.255.255.255   广播地址

# 子网掩码示例：
# /24 = 255.255.255.0    （254个主机地址）
# /16 = 255.255.0.0      （65534个主机地址）
# /8  = 255.0.0.0        （16777214个主机地址）

# CIDR 表示法：
# 192.168.1.0/24 表示网络地址为192.168.1.0，子网掩码为255.255.255.0
# 可用主机地址：192.168.1.1 - 192.168.1.254
```

**网关和路由**：

```bash
# 网关（Gateway）：
# - 连接不同网络的设备
# - 通常是路由器的内网IP地址
# - 默认网关：当目标地址不在本地网络时，数据包发送的目标

# 路由表：决定数据包的转发路径
# 查看路由表
ip route show
route -n
netstat -rn

# 路由表字段说明：
# Destination  目标网络
# Gateway      网关地址（0.0.0.0表示直连）
# Genmask      子网掩码
# Flags        路由标志（U=up, G=gateway, H=host）
# Metric       路由优先级（数值越小优先级越高）
# Iface        网络接口

# 添加路由
sudo ip route add 192.168.2.0/24 via 192.168.1.1
sudo route add -net 192.168.2.0/24 gw 192.168.1.1

# 删除路由
sudo ip route del 192.168.2.0/24
sudo route del -net 192.168.2.0/24

# 添加默认路由
sudo ip route add default via 192.168.1.1
sudo route add default gw 192.168.1.1
```

**DNS（域名系统）**：

```bash
# DNS 的作用：将域名解析为IP地址
# 例：google.com -> 172.217.164.110

# DNS 查询过程：
# 1. 检查本地hosts文件 (/etc/hosts)
# 2. 查询本地DNS缓存
# 3. 向配置的DNS服务器查询
# 4. DNS服务器递归查询权威服务器

# DNS 配置文件
cat /etc/resolv.conf
# nameserver 8.8.8.8      # Google DNS
# nameserver 8.8.4.4      # Google DNS备用
# nameserver 114.114.114.114  # 114 DNS
# search example.com       # 搜索域
# domain example.com       # 本地域名

# 本地hosts文件
cat /etc/hosts
# 127.0.0.1   localhost
# 127.0.1.1   hostname
# 192.168.1.100  server.local

# 常用公共DNS服务器：
# Google DNS:    8.8.8.8, 8.8.4.4
# Cloudflare:    1.1.1.1, 1.0.0.1
# OpenDNS:       208.67.222.222, 208.67.220.220
# 114 DNS:       114.114.114.114, 114.114.115.115
```

**端口和协议**：

```bash
# 端口（Port）：标识应用程序的数字
# 范围：0-65535
# 分类：
# 0-1023:     系统端口（需要root权限）
# 1024-49151: 注册端口
# 49152-65535: 动态端口

# 常用端口：
# 20/21   FTP数据/控制
# 22      SSH
# 23      Telnet
# 25      SMTP
# 53      DNS
# 80      HTTP
# 110     POP3
# 143     IMAP
# 443     HTTPS
# 993     IMAPS
# 995     POP3S
# 3306    MySQL
# 5432    PostgreSQL
# 6379    Redis
# 27017   MongoDB

# 协议类型：
# TCP: 面向连接，可靠传输（HTTP、SSH、FTP）
# UDP: 无连接，快速传输（DNS、DHCP、视频流）
# ICMP: 控制消息协议（ping、traceroute）

# 查看端口使用情况
netstat -tulnp        # 显示所有监听端口
ss -tulnp             # 现代替代命令
lsof -i :80           # 查看80端口使用情况
lsof -i :22           # 查看SSH端口

# 输出字段说明：
# Proto  协议类型
# Local Address   本地地址:端口
# Foreign Address 远程地址:端口
# State  连接状态
# PID/Program name 进程ID/程序名
```

### 5.2 网络配置和诊断

#### 5.2.1 网络接口管理

**ip 命令 - 现代网络配置工具**：

```bash
# ip命令是iproute2包的一部分，是现代Linux的标准网络工具

# 查看网络接口
ip addr show              # 显示所有网络接口
ip a                      # 简写形式
ip addr show eth0         # 显示特定接口
ip a s eth0               # 简写形式

# 查看路由表
ip route show             # 显示路由表
ip r                      # 简写形式
ip route show default     # 显示默认路由

# 查看邻居表（ARP表）
ip neighbor show          # 显示ARP表
ip n                      # 简写形式

# 网络接口管理
sudo ip link set eth0 up        # 启用接口
sudo ip link set eth0 down      # 禁用接口
sudo ip link set eth0 mtu 1500  # 设置MTU

# IP地址管理
sudo ip addr add 192.168.1.100/24 dev eth0    # 添加IP地址
sudo ip addr del 192.168.1.100/24 dev eth0    # 删除IP地址

# 路由管理
sudo ip route add 192.168.2.0/24 via 192.168.1.1    # 添加路由
sudo ip route del 192.168.2.0/24                     # 删除路由
sudo ip route add default via 192.168.1.1            # 添加默认路由

# 查看网络统计
ip -s link show           # 显示接口统计信息
ip -s -s link show        # 显示详细统计信息
```

**ifconfig 命令 - 传统网络配置工具**：

```bash
# ifconfig是net-tools包的一部分，在一些系统中可能需要安装
# Ubuntu/Debian: sudo apt install net-tools
# CentOS/RHEL: sudo yum install net-tools

# 查看网络接口
ifconfig                  # 显示所有活动接口
ifconfig -a               # 显示所有接口（包括未激活的）
ifconfig eth0             # 显示特定接口

# 接口管理
sudo ifconfig eth0 up     # 启用接口
sudo ifconfig eth0 down   # 禁用接口

# IP地址配置
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0    # 设置IP和子网掩码
sudo ifconfig eth0 192.168.1.100/24                        # CIDR格式

# 其他配置
sudo ifconfig eth0 mtu 1500           # 设置MTU
sudo ifconfig eth0 hw ether 00:11:22:33:44:55  # 设置MAC地址

# 输出字段说明：
# inet     - IPv4地址
# inet6    - IPv6地址
# netmask  - 子网掩码
# broadcast- 广播地址
# ether    - MAC地址
# MTU      - 最大传输单元
# RX/TX    - 接收/发送统计
```

**网络接口类型和命名**：

```bash
# 现代Linux网络接口命名规则：
# eth0, eth1  - 以太网接口（传统命名）
# ens33, ens34- 以太网接口（新命名规则）
# wlan0, wlan1- 无线网络接口
# lo          - 回环接口
# docker0     - Docker网桥
# br-xxx      - 网桥接口
# veth-xxx    - 虚拟以太网接口

# 查看接口类型
ls /sys/class/net/        # 列出所有网络接口
cat /sys/class/net/eth0/type  # 查看接口类型

# 查看接口驱动
ethtool -i eth0           # 显示驱动信息（需要安装ethtool）
lspci | grep -i network   # 查看网络硬件
lsusb | grep -i network   # 查看USB网络设备
```

#### 5.2.2 网络连通性测试

**ping - 网络连通性测试**：

```bash
# 基本用法
ping google.com           # 持续ping
ping -c 4 google.com      # ping 4次后停止
ping -c 10 -i 2 google.com # 每2秒ping一次，共10次

# 高级选项
ping -s 1000 google.com   # 设置数据包大小
ping -f google.com        # 洪水ping（需要root权限）
ping -q -c 4 google.com   # 安静模式，只显示统计
ping -w 10 google.com     # 10秒后超时
ping -W 2 google.com      # 等待回复超时2秒

# IPv6 ping
ping6 google.com
ping -6 google.com

# 指定源地址
ping -I eth0 google.com   # 指定接口
ping -S 192.168.1.100 google.com  # 指定源IP

# 输出字段说明：
# 64 bytes from... - 数据包大小和来源
# icmp_seq=1      - ICMP序列号
# ttl=64          - 生存时间
# time=1.23 ms    - 往返时间

# 统计信息：
# packets transmitted - 发送的数据包数
# received           - 接收的数据包数
# packet loss        - 丢包率
# min/avg/max/mdev   - 最小/平均/最大/标准差时间
```

**traceroute - 路由跟踪**：

```bash
# 安装traceroute（如果未安装）
# Ubuntu/Debian: sudo apt install traceroute
# CentOS/RHEL: sudo yum install traceroute

# 基本用法
traceroute google.com     # 跟踪到目标的路由
traceroute -n google.com  # 不解析主机名，只显示IP
traceroute -m 15 google.com  # 最大跳数15
traceroute -w 3 google.com   # 等待回复超时3秒

# 使用不同协议
traceroute -I google.com  # 使用ICMP（需要root权限）
traceroute -T google.com  # 使用TCP
traceroute -U google.com  # 使用UDP（默认）

# 指定端口
traceroute -p 80 google.com  # 指定目标端口

# IPv6跟踪
traceroute6 google.com

# 输出说明：
# 1  192.168.1.1 (192.168.1.1)  1.234 ms  1.123 ms  1.456 ms
# 跳数  IP地址(主机名)  三次测试的往返时间
# *     表示该跳没有响应

# 替代工具
mtr google.com            # 结合ping和traceroute的工具
mtr -n google.com         # 不解析主机名
mtr -c 10 google.com      # 运行10次后停止
```

**DNS查询工具**：

```bash
# nslookup - 交互式DNS查询
nslookup google.com       # 查询A记录
nslookup google.com 8.8.8.8  # 使用指定DNS服务器

# 交互模式
nslookup
> set type=MX             # 设置查询类型
> google.com              # 查询MX记录
> set type=NS
> google.com              # 查询NS记录
> exit

# dig - 更强大的DNS查询工具
dig google.com            # 查询A记录
dig @8.8.8.8 google.com  # 使用指定DNS服务器
dig google.com MX         # 查询MX记录
dig google.com NS         # 查询NS记录
dig google.com AAAA       # 查询IPv6记录
dig google.com ANY        # 查询所有记录类型

# dig高级选项
dig +short google.com     # 简短输出
dig +trace google.com     # 跟踪DNS解析过程
dig +noall +answer google.com  # 只显示答案部分
dig -x 8.8.8.8           # 反向DNS查询

# 批量查询
dig google.com baidu.com  # 查询多个域名

# 常见记录类型：
# A     - IPv4地址
# AAAA  - IPv6地址
# CNAME - 别名记录
# MX    - 邮件交换记录
# NS    - 名称服务器记录
# PTR   - 反向DNS记录
# SOA   - 授权开始记录
# TXT   - 文本记录
```

### 5.3 SSH 远程连接

#### 5.3.1 SSH 基础概念

**SSH 协议原理**：

SSH（Secure Shell）是一种网络协议，用于在不安全的网络上安全地访问远程计算机。

```bash
# SSH 的特点：
# 1. 加密传输：所有数据都经过加密
# 2. 身份验证：支持密码和密钥认证
# 3. 完整性检查：防止数据被篡改
# 4. 端口转发：支持隧道功能

# SSH 连接过程：
# 1. 客户端连接服务器
# 2. 服务器发送公钥
# 3. 协商加密算法
# 4. 建立加密通道
# 5. 用户身份验证
# 6. 建立会话

# SSH 版本：
# SSH-1: 已废弃，存在安全漏洞
# SSH-2: 当前标准版本，安全可靠

# 默认端口：22
# 配置文件：
# 客户端：~/.ssh/config, /etc/ssh/ssh_config
# 服务端：/etc/ssh/sshd_config
```

#### 5.3.2 SSH 客户端使用

**基本SSH连接**：

```bash
# 基本连接语法
ssh username@hostname     # 连接到远程主机
ssh username@192.168.1.100  # 使用IP地址连接
ssh -p 2222 username@hostname  # 指定端口

# 常用选项
ssh -v username@hostname  # 详细输出（调试）
ssh -vv username@hostname # 更详细输出
ssh -vvv username@hostname # 最详细输出

# 连接选项
ssh -o ConnectTimeout=10 username@hostname  # 连接超时
ssh -o StrictHostKeyChecking=no username@hostname  # 跳过主机密钥检查
ssh -o UserKnownHostsFile=/dev/null username@hostname  # 不保存主机密钥

# 执行远程命令
ssh username@hostname 'ls -la'              # 执行单个命令
ssh username@hostname 'cd /var/log && tail -f syslog'  # 执行多个命令
ssh username@hostname < local_script.sh     # 执行本地脚本

# 交互式会话
ssh -t username@hostname 'top'              # 强制分配伪终端
ssh -t username@hostname 'sudo vim /etc/hosts'  # 需要交互的命令

# 压缩传输
ssh -C username@hostname  # 启用压缩

# 保持连接
ssh -o ServerAliveInterval=60 username@hostname  # 每60秒发送保活包
ssh -o ServerAliveCountMax=3 username@hostname   # 最多3次保活失败
```

**SSH配置文件**：

```bash
# 用户配置文件：~/.ssh/config
# 系统配置文件：/etc/ssh/ssh_config

# 创建SSH配置文件
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config

# 配置文件示例
# 使用独立的SSH配置文件：demos/ssh_config
cp demos/ssh_config ~/.ssh/config

# 使用配置文件连接
ssh prod-server           # 使用别名连接
ssh dev-server            # 自动应用配置

# 常用配置选项：
# Host                  - 主机别名
# HostName              - 实际主机名或IP
# User                  - 用户名
# Port                  - 端口号
# IdentityFile          - 私钥文件
# ForwardAgent          - 转发SSH代理
# LocalForward          - 本地端口转发
# RemoteForward         - 远程端口转发
# ProxyJump             - 跳板机
# StrictHostKeyChecking - 主机密钥检查
# UserKnownHostsFile    - 已知主机文件
# ServerAliveInterval   - 保活间隔
# ServerAliveCountMax   - 保活最大次数
# ConnectTimeout        - 连接超时
# Compression           - 启用压缩
```

#### 5.3.3 SSH 密钥认证

**生成SSH密钥对**：

```bash
# 生成RSA密钥对（推荐2048位或更高）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 生成ED25519密钥对（推荐，更安全更快）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 生成ECDSA密钥对
ssh-keygen -t ecdsa -b 521 -C "your_email@example.com"

# 指定密钥文件名
ssh-keygen -t ed25519 -f ~/.ssh/my_key -C "my_key@example.com"

# 生成过程中的选项：
# Enter file in which to save the key: 密钥保存位置（默认~/.ssh/id_rsa）
# Enter passphrase: 密钥密码（可选，但推荐）
# Enter same passphrase again: 确认密码

# 查看生成的密钥
ls -la ~/.ssh/
# id_rsa      - 私钥（保密）
# id_rsa.pub  - 公钥（可以分享）

# 查看公钥内容
cat ~/.ssh/id_rsa.pub

# 查看密钥指纹
ssh-keygen -lf ~/.ssh/id_rsa.pub
ssh-keygen -lf ~/.ssh/id_rsa.pub -E md5  # MD5格式指纹
```

**部署公钥到远程服务器**：

```bash
# 方法1：使用ssh-copy-id（推荐）
ssh-copy-id username@hostname
ssh-copy-id -i ~/.ssh/my_key.pub username@hostname  # 指定公钥文件
ssh-copy-id -p 2222 username@hostname               # 指定端口

# 方法2：手动复制
cat ~/.ssh/id_rsa.pub | ssh username@hostname 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'

# 方法3：使用scp复制后手动配置
scp ~/.ssh/id_rsa.pub username@hostname:~/
ssh username@hostname
mkdir -p ~/.ssh
cat ~/id_rsa.pub >> ~/.ssh/authorized_keys
rm ~/id_rsa.pub
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
exit

# 验证密钥认证
ssh username@hostname  # 应该不需要密码（如果私钥没有密码）

# 如果私钥有密码，使用ssh-agent管理
eval $(ssh-agent -s)   # 启动ssh-agent
ssh-add ~/.ssh/id_rsa  # 添加私钥到agent
ssh-add -l             # 列出已加载的密钥
ssh-add -d ~/.ssh/id_rsa  # 从agent中删除密钥
ssh-add -D             # 删除所有密钥
```

### 5.4 防火墙基础

#### 5.4.1 iptables 防火墙

**iptables 基本概念**：

```bash
# iptables是Linux内核netfilter框架的用户空间工具
# 用于配置内核防火墙规则

# 基本概念：
# 表（Table）：规则的集合
#   - filter: 过滤表（默认），用于包过滤
#   - nat:    网络地址转换表
#   - mangle: 包修改表
#   - raw:    原始表，用于配置连接跟踪

# 链（Chain）：规则的序列
#   - INPUT:   处理入站数据包
#   - OUTPUT:  处理出站数据包
#   - FORWARD: 处理转发数据包
#   - PREROUTING:  路由前处理
#   - POSTROUTING: 路由后处理

# 目标（Target）：规则匹配后的动作
#   - ACCEPT:  接受数据包
#   - DROP:    丢弃数据包（静默）
#   - REJECT:  拒绝数据包（发送错误消息）
#   - LOG:     记录日志
#   - RETURN:  返回调用链
```

**iptables 基本操作**：

```bash
# 查看当前规则
sudo iptables -L          # 列出所有规则
sudo iptables -L -n       # 不解析主机名和端口名
sudo iptables -L -v       # 显示详细信息（包计数）
sudo iptables -L INPUT    # 只显示INPUT链
sudo iptables -L -t nat   # 显示nat表规则

# 基本规则操作
# 允许SSH连接
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 允许HTTP和HTTPS
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 允许ping
sudo iptables -A INPUT -p icmp -j ACCEPT

# 允许回环接口
sudo iptables -A INPUT -i lo -j ACCEPT

# 允许已建立的连接
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 拒绝其他所有连接
sudo iptables -A INPUT -j DROP

# 删除规则
sudo iptables -D INPUT 1  # 删除INPUT链第1条规则
sudo iptables -D INPUT -p tcp --dport 80 -j ACCEPT  # 删除特定规则

# 插入规则（在指定位置）
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT  # 在第1位插入

# 清空规则
sudo iptables -F          # 清空所有链
sudo iptables -F INPUT    # 清空INPUT链
sudo iptables -X          # 删除用户定义的链
sudo iptables -Z          # 清零计数器

# 设置默认策略
sudo iptables -P INPUT DROP     # 默认拒绝输入
sudo iptables -P FORWARD DROP   # 默认拒绝转发
sudo iptables -P OUTPUT ACCEPT  # 默认允许输出
```

**iptables 高级规则**：

```bash
# 按源IP允许/拒绝
sudo iptables -A INPUT -s 192.168.1.0/24 -j ACCEPT
sudo iptables -A INPUT -s 10.0.0.100 -j DROP

# 按目标IP
sudo iptables -A OUTPUT -d 192.168.1.100 -j ACCEPT

# 端口范围
sudo iptables -A INPUT -p tcp --dport 8000:8999 -j ACCEPT
sudo iptables -A INPUT -p tcp -m multiport --dports 80,443,8080 -j ACCEPT

# 限制连接频率
sudo iptables -A INPUT -p tcp --dport 22 -m limit --limit 3/min -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j DROP

# 时间限制
sudo iptables -A INPUT -p tcp --dport 80 -m time --timestart 09:00 --timestop 17:00 -j ACCEPT

# 连接状态
sudo iptables -A INPUT -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT

# 日志记录
sudo iptables -A INPUT -j LOG --log-prefix "INPUT DROP: " --log-level 4
sudo iptables -A INPUT -j DROP

# NAT规则（需要开启IP转发）
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

# 保存和恢复规则
# Ubuntu/Debian:
sudo iptables-save > /etc/iptables/rules.v4
sudo iptables-restore < /etc/iptables/rules.v4

# CentOS/RHEL:
sudo service iptables save
sudo service iptables restore

# 或使用iptables-persistent包
sudo apt install iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload
```

#### 5.4.1 ufw 简化防火墙

**ufw 基本操作**：

```bash
# ufw (Uncomplicated Firewall) 是iptables的简化前端
# 主要用于Ubuntu，其他发行版可能需要安装

# 基本操作
sudo ufw status           # 查看状态
sudo ufw enable           # 启用防火墙
sudo ufw disable          # 禁用防火墙
sudo ufw reset            # 重置所有规则

# 默认策略
sudo ufw default deny incoming   # 默认拒绝入站
sudo ufw default allow outgoing  # 默认允许出站
sudo ufw default deny forward    # 默认拒绝转发

# 允许服务
sudo ufw allow ssh        # 允许SSH (端口22)
sudo ufw allow http       # 允许HTTP (端口80)
sudo ufw allow https      # 允许HTTPS (端口443)
sudo ufw allow ftp        # 允许FTP (端口21)

# 允许端口
sudo ufw allow 8080       # 允许端口8080
sudo ufw allow 3000:3010  # 允许端口范围
sudo ufw allow 53/udp     # 允许UDP端口53
sudo ufw allow 22/tcp     # 允许TCP端口22

# 按IP地址允许
sudo ufw allow from 192.168.1.100        # 允许特定IP
sudo ufw allow from 192.168.1.0/24       # 允许网段
sudo ufw allow from 192.168.1.100 to any port 22  # 特定IP访问特定端口

# 拒绝规则
sudo ufw deny 23          # 拒绝端口23
sudo ufw deny from 10.0.0.100  # 拒绝特定IP
sudo ufw deny out 25      # 拒绝出站端口25

# 删除规则
sudo ufw delete allow ssh # 删除SSH允许规则
sudo ufw delete 1         # 删除第1条规则
sudo ufw delete allow from 192.168.1.100  # 删除特定规则

# 查看详细状态
sudo ufw status verbose   # 详细状态
sudo ufw status numbered  # 显示规则编号

# 日志记录
sudo ufw logging on       # 启用日志
sudo ufw logging off      # 禁用日志
sudo ufw logging low      # 设置日志级别（off/low/medium/high/full）

# 查看日志
sudo tail -f /var/log/ufw.log
```

**ufw 高级功能**：

```bash
# 应用配置文件
sudo ufw app list         # 列出可用应用配置
sudo ufw app info 'Apache Full'  # 查看应用配置信息
sudo ufw allow 'Apache Full'     # 允许应用
sudo ufw allow 'OpenSSH'

# 自定义应用配置
sudo vim /etc/ufw/applications.d/myapp
# [MyApp]
# title=My Application
# description=My custom application
# ports=8080,8443/tcp

sudo ufw app update MyApp
sudo ufw allow MyApp

# 高级规则
sudo ufw limit ssh        # 限制SSH连接频率（6次/30秒）
sudo ufw allow in on eth0 to any port 80  # 指定接口
sudo ufw allow out on eth1 to any port 53 # 指定出站接口

# 端口转发（需要编辑配置文件）
sudo vim /etc/ufw/before.rules
# 在*filter前添加：
# *nat
# :PREROUTING ACCEPT [0:0]
# -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
# COMMIT

# IPv6支持
sudo ufw --force enable
sudo ufw allow from 2001:db8::/32

# 配置文件位置：
# /etc/ufw/ufw.conf        - 主配置文件
# /etc/ufw/before.rules    - 预处理规则
# /etc/ufw/after.rules     - 后处理规则
# /etc/ufw/user.rules      - 用户规则
# /etc/ufw/applications.d/ - 应用配置目录
```

### 5.5 网络文件传输

#### 5.5.1 scp 安全复制

**scp 基本用法**：

```bash
# 语法：scp [选项] 源文件 目标文件

# 从本地复制到远程
scp file.txt username@remote-host:/path/to/destination/
scp file.txt username@remote-host:~/                    # 复制到用户主目录
scp file.txt username@remote-host:/tmp/newname.txt      # 复制并重命名

# 从远程复制到本地
scp username@remote-host:/path/to/file.txt ./
scp username@remote-host:/path/to/file.txt /local/path/
scp username@remote-host:~/file.txt ./newname.txt       # 复制并重命名

# 在两个远程主机间复制
scp user1@host1:/path/file.txt user2@host2:/path/

# 常用选项
scp -r directory/ username@remote-host:/path/           # 递归复制目录
scp -p file.txt username@remote-host:/path/             # 保持文件属性
scp -v file.txt username@remote-host:/path/             # 详细输出
scp -C file.txt username@remote-host:/path/             # 启用压缩
scp -P 2222 file.txt username@remote-host:/path/        # 指定端口
scp -i ~/.ssh/my_key file.txt username@remote-host:/path/  # 指定私钥

# 复制多个文件
scp file1.txt file2.txt username@remote-host:/path/
scp *.txt username@remote-host:/path/
scp {file1,file2,file3}.txt username@remote-host:/path/

# 限制带宽（KB/s）
scp -l 1000 largefile.iso username@remote-host:/path/   # 限制为1MB/s
```

#### 5.5.2 rsync 同步工具

**rsync 基本用法**：

```bash
# rsync是强大的文件同步工具，支持增量传输

# 基本语法：rsync [选项] 源 目标

# 本地同步
rsync -av source/ destination/                         # 同步目录
rsync -av source destination                           # 在destination下创建source目录
rsync -av file.txt /path/to/destination/               # 同步文件

# 远程同步
rsync -av source/ username@remote-host:/path/destination/
rsync -av username@remote-host:/path/source/ ./destination/

# 常用选项组合
rsync -avz source/ username@remote-host:/path/         # 压缩传输
rsync -avzP source/ username@remote-host:/path/        # 显示进度
rsync -avz --delete source/ username@remote-host:/path/  # 删除目标中多余文件

# 选项说明：
# -a: 归档模式（等于-rlptgoD）
# -r: 递归
# -l: 复制符号链接
# -p: 保持权限
# -t: 保持时间戳
# -g: 保持组
# -o: 保持所有者
# -D: 保持设备文件
# -v: 详细输出
# -z: 压缩传输
# -P: 等于--partial --progress
# --delete: 删除目标中源没有的文件
# --dry-run: 模拟运行，不实际传输
```

**实践练习：**

```bash
# 1. 网络配置练习
# 查看网络接口信息
ip addr show
ifconfig -a

# 查看路由表
ip route show
route -n

# 测试网络连通性
ping -c 4 8.8.8.8
traceroute google.com

# DNS查询练习
nslookup google.com
dig google.com
dig @8.8.8.8 google.com MX

# 2. SSH连接练习
# 生成SSH密钥对
ssh-keygen -t ed25519 -C "test@example.com"

# 查看公钥
cat ~/.ssh/id_ed25519.pub

# 配置SSH客户端
vim ~/.ssh/config

# 3. 防火墙练习
# 查看当前防火墙状态
sudo ufw status
sudo iptables -L

# 配置基本防火墙规则
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw status numbered

# 4. 文件传输练习
# 创建测试文件
echo "Hello World" > test.txt

# 使用scp传输（需要有远程主机）
# scp test.txt user@remote-host:~/

# 使用rsync同步
# rsync -av test.txt user@remote-host:~/
```

---

## 第六章：软件包管理

### 6.1 包管理器概述

#### 6.1.1 软件包管理基础概念

**什么是软件包管理器**：

软件包管理器是用于自动化安装、配置、升级和删除软件包的工具集合。

```bash
# 软件包管理器的主要功能：
# 1. 软件包安装和删除
# 2. 依赖关系解析
# 3. 版本管理
# 4. 系统更新
# 5. 软件仓库管理
# 6. 安全性验证

# 软件包的组成：
# - 可执行文件
# - 配置文件
# - 文档和手册页
# - 依赖信息
# - 安装/卸载脚本
# - 元数据（版本、描述、维护者等）

# 包格式：
# .deb  - Debian/Ubuntu 包格式
# .rpm  - Red Hat/CentOS/SUSE 包格式
# .pkg  - Arch Linux 包格式
# .tar.xz - 源码包格式
```

**不同发行版的包管理器**：

```bash
# Debian/Ubuntu 系列：
# - apt (Advanced Package Tool) - 现代高级接口
# - apt-get - 传统命令行工具
# - apt-cache - 包缓存查询工具
# - dpkg - 底层包管理工具
# - aptitude - 交互式包管理器

# Red Hat/CentOS/Fedora 系列：
# - dnf (Dandified YUM) - Fedora 22+ 默认
# - yum (Yellowdog Updater Modified) - 传统工具
# - rpm - 底层包管理工具
# - zypper - openSUSE 包管理器

# Arch Linux：
# - pacman - 官方包管理器
# - yay/paru - AUR 助手

# 其他：
# - snap - 通用包管理器
# - flatpak - 沙盒应用包管理器
# - AppImage - 便携应用格式
```

**软件仓库概念**：

```bash
# 软件仓库（Repository）是存储软件包的服务器

# 仓库类型：
# 官方仓库：
#   - main/universe (Ubuntu)
#   - base/extra (Arch)
#   - BaseOS/AppStream (RHEL 8+)

# 第三方仓库：
#   - PPA (Personal Package Archive) - Ubuntu
#   - EPEL (Extra Packages for Enterprise Linux) - RHEL/CentOS
#   - RPM Fusion - Fedora

# 仓库组件：
# - 包索引文件
# - 软件包文件
# - 数字签名
# - 元数据

# 仓库镜像：
# 为了提高下载速度，通常使用地理位置较近的镜像服务器
# 常用镜像站：
# - 清华大学 TUNA
# - 中科大 USTC
# - 阿里云
# - 华为云
```

**依赖关系管理**：

```bash
# 依赖关系类型：
# 1. 依赖 (Depends)：必须安装的包
# 2. 推荐 (Recommends)：建议安装的包
# 3. 建议 (Suggests)：可选安装的包
# 4. 冲突 (Conflicts)：不能同时安装的包
# 5. 替换 (Replaces)：替代其他包
# 6. 提供 (Provides)：提供虚拟包

# 依赖解析过程：
# 1. 分析目标包的依赖
# 2. 递归查找所有依赖包
# 3. 检查版本兼容性
# 4. 解决冲突
# 5. 确定安装顺序
# 6. 下载并安装

# 常见依赖问题：
# - 循环依赖
# - 版本冲突
# - 缺失依赖
# - 破损包
```

### 6.2 APT 包管理（Debian/Ubuntu）

#### 6.2.1 APT 基础操作

**apt 命令 - 现代包管理接口**：

```bash
# apt 是 APT 包管理系统的现代命令行接口
# 结合了 apt-get 和 apt-cache 的功能，提供更友好的用户体验

# 更新包索引
sudo apt update              # 更新包列表
sudo apt list --upgradable   # 查看可升级的包

# 升级系统
sudo apt upgrade             # 升级已安装的包
sudo apt full-upgrade        # 完整升级（可能删除包）
sudo apt dist-upgrade        # 发行版升级（不推荐直接使用）

# 安装软件包
sudo apt install package_name              # 安装单个包
sudo apt install package1 package2         # 安装多个包
sudo apt install package=version           # 安装特定版本
sudo apt install ./package.deb             # 安装本地deb包
sudo apt install -y package_name           # 自动确认安装
sudo apt install --no-install-recommends package_name  # 不安装推荐包

# 删除软件包
sudo apt remove package_name               # 删除包（保留配置文件）
sudo apt purge package_name                # 完全删除包和配置文件
sudo apt autoremove                        # 删除不再需要的依赖包
sudo apt autoremove --purge                # 删除依赖包和配置文件

# 搜索和查看包信息
apt search keyword                         # 搜索包
apt show package_name                      # 显示包详细信息
apt list                                   # 列出所有可用包
apt list --installed                       # 列出已安装的包
apt list --upgradable                      # 列出可升级的包

# 清理缓存
sudo apt clean                             # 清理所有缓存
sudo apt autoclean                         # 清理过期缓存
```

**apt-get 和 apt-cache - 传统工具**：

```bash
# apt-get - 包安装和系统更新
sudo apt-get update                        # 更新包索引
sudo apt-get upgrade                       # 升级包
sudo apt-get dist-upgrade                  # 发行版升级
sudo apt-get install package_name         # 安装包
sudo apt-get remove package_name          # 删除包
sudo apt-get purge package_name           # 完全删除包
sudo apt-get autoremove                    # 删除孤立依赖
sudo apt-get clean                         # 清理缓存
sudo apt-get autoclean                     # 清理过期缓存

# 高级选项
sudo apt-get install -f                    # 修复破损依赖
sudo apt-get install --reinstall package_name  # 重新安装包
sudo apt-get source package_name           # 下载源码包
sudo apt-get build-dep package_name        # 安装构建依赖

# apt-cache - 包信息查询
apt-cache search keyword                   # 搜索包
apt-cache show package_name               # 显示包信息
apt-cache depends package_name            # 显示依赖关系
apt-cache rdepends package_name           # 显示反向依赖
apt-cache policy package_name             # 显示包策略
apt-cache stats                            # 显示缓存统计
```

**dpkg - 底层包管理**：

```bash
# dpkg 是 Debian 包管理的底层工具

# 安装和删除
sudo dpkg -i package.deb                  # 安装deb包
sudo dpkg -r package_name                 # 删除包
sudo dpkg -P package_name                 # 完全删除包

# 查询包信息
dpkg -l                                    # 列出所有已安装包
dpkg -l | grep package_name               # 查找特定包
dpkg -s package_name                      # 显示包状态
dpkg -L package_name                      # 列出包文件
dpkg -S /path/to/file                     # 查找文件属于哪个包

# 包状态
dpkg --get-selections                      # 显示包选择状态
dpkg --set-selections < selections.txt    # 设置包选择状态

# 修复破损包
sudo dpkg --configure -a                  # 配置所有未配置的包
sudo dpkg --configure package_name        # 配置特定包
```

### 6.3 YUM/DNF 包管理（CentOS/RHEL/Fedora）

#### 6.3.1 DNF 包管理器（现代工具）

**DNF 基本操作**：

```bash
# DNF (Dandified YUM) 是 YUM 的下一代版本
# Fedora 22+ 和 RHEL 8+ 的默认包管理器

# 更新系统
sudo dnf check-update                      # 检查可用更新
sudo dnf update                            # 更新所有包
sudo dnf update package_name               # 更新特定包
sudo dnf upgrade                           # 升级系统（同update）

# 安装软件包
sudo dnf install package_name             # 安装包
sudo dnf install package1 package2        # 安装多个包
sudo dnf install ./package.rpm            # 安装本地rpm包
sudo dnf install -y package_name          # 自动确认安装
sudo dnf reinstall package_name           # 重新安装包

# 删除软件包
sudo dnf remove package_name               # 删除包
sudo dnf autoremove                        # 删除孤立依赖
sudo dnf autoremove package_name           # 删除包及其孤立依赖

# 搜索和查看包信息
dnf search keyword                         # 搜索包
dnf info package_name                      # 显示包信息
dnf list                                   # 列出所有包
dnf list installed                         # 列出已安装包
dnf list available                         # 列出可用包
dnf list updates                           # 列出可更新包

# 依赖关系
dnf deplist package_name                  # 显示依赖列表
dnf repoquery --requires package_name     # 查询依赖
dnf repoquery --whatrequires package_name # 查询反向依赖
```

**YUM 包管理器（传统工具）**：

```bash
# YUM (Yellowdog Updater Modified) 是传统的 RPM 包管理器
# 在 CentOS 7 及更早版本中使用

# 基本操作（语法与 DNF 类似）
sudo yum check-update
sudo yum update
sudo yum install package_name
sudo yum remove package_name
sudo yum search keyword
sudo yum info package_name
sudo yum list installed

# YUM 特有功能
yum history                                # 查看操作历史
yum history info ID                        # 查看特定操作详情
sudo yum history undo ID                   # 撤销操作

# 包组管理
yum grouplist                              # 列出包组
yum groupinfo "Group Name"                 # 查看包组信息
sudo yum groupinstall "Development Tools"  # 安装包组
sudo yum groupremove "Group Name"          # 删除包组
```

### 6.4 源码编译安装

#### 6.4.1 源码编译基础

**编译环境准备**：

```bash
# Ubuntu/Debian 安装编译工具
sudo apt update
sudo apt install build-essential           # 基本编译工具
sudo apt install gcc g++ make             # 编译器和构建工具
sudo apt install autoconf automake        # 自动配置工具
sudo apt install libtool pkg-config       # 库工具
sudo apt install git wget curl            # 下载工具

# CentOS/RHEL 安装编译工具
sudo dnf groupinstall "Development Tools"  # 开发工具组
sudo dnf install gcc gcc-c++ make         # 编译器
sudo dnf install autoconf automake        # 自动配置工具
sudo dnf install libtool pkgconfig        # 库工具
sudo dnf install git wget curl            # 下载工具

# 查看编译工具版本
gcc --version
make --version
autoconf --version
```

**典型编译安装过程**：

```bash
# 1. 下载源码
wget https://example.com/software-1.0.tar.gz
# 或使用 git
git clone https://github.com/user/software.git

# 2. 解压源码
tar -xzf software-1.0.tar.gz
cd software-1.0

# 3. 查看安装说明
ls                                         # 查看文件列表
cat README                                 # 阅读说明文件
cat INSTALL                                # 阅读安装指南

# 4. 配置编译选项
./configure                                # 基本配置
./configure --help                         # 查看配置选项
./configure --prefix=/usr/local           # 指定安装路径
./configure --prefix=/opt/software        # 安装到 /opt 目录

# 常用配置选项：
# --prefix=PATH          安装路径
# --enable-feature       启用特性
# --disable-feature      禁用特性
# --with-library         使用特定库
# --without-library      不使用特定库

# 5. 编译
make                                       # 编译源码
make -j$(nproc)                           # 并行编译（使用所有CPU核心）
make -j4                                   # 使用4个并行任务

# 6. 测试（可选）
make test                                  # 运行测试
make check                                 # 检查编译结果

# 7. 安装
sudo make install                          # 安装到系统

# 8. 配置环境变量（如果需要）
echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 或创建符号链接
sudo ln -s /usr/local/bin/software /usr/bin/software
```

**实践练习：**

```bash
# 1. APT 包管理练习（Ubuntu/Debian）
# 更新系统
sudo apt update
sudo apt list --upgradable

# 安装软件
sudo apt install tree htop curl

# 搜索和查看包信息
apt search text-editor
apt show vim

# 查看已安装包
apt list --installed | grep vim

# 2. DNF/YUM 包管理练习（CentOS/RHEL/Fedora）
# 更新系统
sudo dnf check-update

# 安装软件
sudo dnf install tree htop curl

# 搜索和查看包信息
dnf search text-editor
dnf info vim

# 查看已安装包
dnf list installed | grep vim

# 3. 源码编译练习
# 编译安装 hello world 程序
# 使用独立的C语言示例文件：demos/hello.c
cp demos/hello.c .

# 编译
gcc -o hello hello.c

# 运行
./hello
```

---

## 第七章：Shell 脚本编程

### 7.1 Shell 脚本基础

#### 7.1.1 脚本文件创建和执行

**什么是 Shell 脚本**：

Shell 脚本是包含一系列命令的文本文件，可以自动化执行重复性任务。

```bash
# Shell 脚本的优势：
# 1. 自动化重复任务
# 2. 批量处理文件
# 3. 系统管理和监控
# 4. 简化复杂操作
# 5. 提高工作效率

# 常用的 Shell 类型：
# - bash (Bourne Again Shell) - 最常用
# - sh (Bourne Shell) - 传统 Shell
# - zsh (Z Shell) - 功能丰富
# - fish (Friendly Interactive Shell) - 用户友好
# - dash (Debian Almquist Shell) - 轻量级
```

**创建第一个脚本**：

请参考 `demos/shell_scripting.sh` 脚本中的基础脚本创建部分。

**Shebang（#!）的作用**：

请参考 `demos/shell_scripting.sh` 脚本中的 Shebang 说明和示例。

#### 7.1.2 变量定义和使用

**变量基础**：

请参考 `demos/shell_scripting.sh` 脚本中的变量定义和使用部分。

**变量类型和作用域**：

请参考 `demos/shell_scripting.sh` 脚本中的变量类型和作用域部分。

**字符串操作**：

请参考 `demos/shell_scripting.sh` 脚本中的字符串操作部分。

#### 7.1.3 命令行参数处理

**基本参数处理**：

请参考 `demos/shell_scripting.sh` 脚本中的命令行参数处理部分。

**高级参数处理**：

请参考 `demos/shell_scripting.sh` 脚本中的高级参数处理部分。

### 7.2 控制结构

#### 7.2.1 条件判断：if-then-else

**基本条件判断**：

```bash
#!/usr/bin/env bash

# 基本 if 语句
age=18

if [ $age -ge 18 ]; then
    echo "你已经成年了"
fi

# if-else 语句
score=85

if [ $score -ge 90 ]; then
    echo "优秀"
else
    echo "良好"
fi

# if-elif-else 语句
if [ $score -ge 90 ]; then
    echo "优秀（90-100）"
elif [ $score -ge 80 ]; then
    echo "良好（80-89）"
elif [ $score -ge 70 ]; then
    echo "中等（70-79）"
elif [ $score -ge 60 ]; then
    echo "及格（60-69）"
else
    echo "不及格（<60）"
fi
```

**测试条件详解**：

```bash
#!/usr/bin/env bash

# 数值比较
num1=10
num2=20

if [ $num1 -eq $num2 ]; then echo "相等"; fi          # 等于
if [ $num1 -ne $num2 ]; then echo "不等于"; fi        # 不等于
if [ $num1 -lt $num2 ]; then echo "小于"; fi          # 小于
if [ $num1 -le $num2 ]; then echo "小于等于"; fi      # 小于等于
if [ $num1 -gt $num2 ]; then echo "大于"; fi          # 大于
if [ $num1 -ge $num2 ]; then echo "大于等于"; fi      # 大于等于

# 字符串比较
str1="hello"
str2="world"

if [ "$str1" = "$str2" ]; then echo "字符串相等"; fi
if [ "$str1" != "$str2" ]; then echo "字符串不等"; fi
if [ "$str1" \< "$str2" ]; then echo "字符串1小于字符串2"; fi
if [ -z "$str1" ]; then echo "字符串为空"; fi
if [ -n "$str1" ]; then echo "字符串非空"; fi

# 文件测试
file="/etc/passwd"

if [ -e "$file" ]; then echo "文件存在"; fi
if [ -f "$file" ]; then echo "是普通文件"; fi
if [ -d "$file" ]; then echo "是目录"; fi
if [ -r "$file" ]; then echo "文件可读"; fi
if [ -w "$file" ]; then echo "文件可写"; fi
if [ -x "$file" ]; then echo "文件可执行"; fi
if [ -s "$file" ]; then echo "文件非空"; fi

# 逻辑运算
if [ $num1 -lt $num2 ] && [ $num1 -gt 0 ]; then
    echo "num1 在 0 和 num2 之间"
fi

if [ $num1 -eq 0 ] || [ $num2 -eq 0 ]; then
    echo "至少有一个数为0"
fi

if ! [ $num1 -eq $num2 ]; then
    echo "两个数不相等"
fi
```

**现代测试语法**：

请参考 `demos/shell_scripting.sh` 脚本中的现代测试语法部分。

#### 循环结构：for、while

**for 循环**：

请参考 `demos/shell_scripting.sh` 脚本中的 for 循环部分。

**while 循环**：

请参考 `demos/shell_scripting.sh` 脚本中的 while 循环部分。

**循环控制**：

请参考 `demos/shell_scripting.sh` 脚本中的循环控制部分。

#### 7.2.2 函数定义和调用

**基本函数**：

请参考 `demos/shell_scripting.sh` 脚本中的函数定义和调用部分。

**高级函数特性**：

请参考 `demos/shell_scripting.sh` 脚本中的高级函数特性部分。

#### 7.2.3 错误处理和退出状态

**退出状态码**：

请参考 `demos/shell_scripting.sh` 脚本中的错误处理和退出状态部分。

**错误处理最佳实践**：

请参考 `demos/shell_scripting.sh` 脚本中的错误处理最佳实践部分。

### 7.3 实用脚本示例

#### 7.3.1 系统监控脚本

请参考 `demos/system_monitor.sh` 脚本，该脚本提供了完整的系统资源监控功能。

#### 7.3.2 日志分析脚本

请参考 `demos/log_analyzer.sh` 脚本，该脚本提供了完整的 Web 服务器日志分析功能。

#### 7.3.3 自动化部署脚本

请参考 `demos/auto_deploy.sh` 脚本，该脚本提供了完整的自动化部署功能，包括 Git 拉取、构建、部署和回滚。

---

## 第八章：为容器技术做准备

### 8.1 Linux 容器相关概念

#### 8.1.1 命名空间（Namespaces）

**什么是命名空间**：

命名空间是 Linux 内核提供的一种资源隔离机制，它可以让进程拥有独立的系统资源视图。

```bash
# 命名空间的类型：
# 1. PID Namespace - 进程ID隔离
# 2. Network Namespace - 网络隔离
# 3. Mount Namespace - 文件系统挂载点隔离
# 4. UTS Namespace - 主机名和域名隔离
# 5. IPC Namespace - 进程间通信隔离
# 6. User Namespace - 用户和用户组隔离
# 7. Cgroup Namespace - Cgroup 根目录隔离

# 查看当前进程的命名空间
ls -la /proc/self/ns/
# 输出示例：
# lrwxrwxrwx 1 root root 0 Jan 1 12:00 cgroup -> 'cgroup:[4026531835]'
# lrwxrwxrwx 1 root root 0 Jan 1 12:00 ipc -> 'ipc:[4026531839]'
# lrwxrwxrwx 1 root root 0 Jan 1 12:00 mnt -> 'mnt:[4026531840]'
# lrwxrwxrwx 1 root root 0 Jan 1 12:00 net -> 'net:[4026531992]'
# lrwxrwxrwx 1 root root 0 Jan 1 12:00 pid -> 'pid:[4026531836]'
# lrwxrwxrwx 1 root root 0 Jan 1 12:00 user -> 'user:[4026531837]'
# lrwxrwxrwx 1 root root 0 Jan 1 12:00 uts -> 'uts:[4026531838]'
```

**PID 命名空间实验**：

```bash
# 创建新的 PID 命名空间
# 注意：需要 root 权限
sudo unshare --pid --fork --mount-proc bash

# 在新命名空间中查看进程
ps aux
# 你会发现进程 ID 从 1 开始，这就是 PID 隔离的效果

# 查看命名空间 ID
readlink /proc/self/ns/pid

# 退出命名空间
exit
```

**网络命名空间实验**：

```bash
# 创建网络命名空间
sudo ip netns add test-ns

# 列出所有网络命名空间
sudo ip netns list

# 在命名空间中执行命令
sudo ip netns exec test-ns ip addr show
# 你会发现只有 loopback 接口

# 创建虚拟网络接口对
sudo ip link add veth0 type veth peer name veth1

# 将一端移动到命名空间
sudo ip link set veth1 netns test-ns

# 配置接口
sudo ip addr add 192.168.1.1/24 dev veth0
sudo ip link set veth0 up

sudo ip netns exec test-ns ip addr add 192.168.1.2/24 dev veth1
sudo ip netns exec test-ns ip link set veth1 up
sudo ip netns exec test-ns ip link set lo up

# 测试连通性
ping -c 3 192.168.1.2

# 清理
sudo ip netns delete test-ns
sudo ip link delete veth0
```

#### 8.1.2 控制组（Cgroups）

**什么是 Cgroups**：

Cgroups（Control Groups）是 Linux 内核提供的一种机制，用于限制、记录和隔离进程组的资源使用。

```bash
# Cgroups 可以控制的资源：
# 1. CPU 使用率和时间
# 2. 内存使用量
# 3. 磁盘 I/O
# 4. 网络带宽
# 5. 设备访问权限

# 查看 Cgroups 挂载点
mount | grep cgroup
# 或者
findmnt -t cgroup,cgroup2

# 查看当前进程的 Cgroup 信息
cat /proc/self/cgroup

# 查看 Cgroups 层次结构
ls /sys/fs/cgroup/
```

**Cgroups v1 实验**：

```bash
# 创建一个新的 CPU cgroup
sudo mkdir /sys/fs/cgroup/cpu/test-group

# 设置 CPU 限制（50% CPU）
echo 50000 | sudo tee /sys/fs/cgroup/cpu/test-group/cpu.cfs_quota_us
echo 100000 | sudo tee /sys/fs/cgroup/cpu/test-group/cpu.cfs_period_us

# 启动一个 CPU 密集型进程
yes > /dev/null &
CPU_PID=$!

# 将进程添加到 cgroup
echo $CPU_PID | sudo tee /sys/fs/cgroup/cpu/test-group/cgroup.procs

# 观察 CPU 使用率
top -p $CPU_PID
# 你会发现 CPU 使用率被限制在 50% 左右

# 清理
kill $CPU_PID
sudo rmdir /sys/fs/cgroup/cpu/test-group
```

**内存限制实验**：

```bash
# 创建内存 cgroup
sudo mkdir /sys/fs/cgroup/memory/test-memory

# 设置内存限制（100MB）
echo 104857600 | sudo tee /sys/fs/cgroup/memory/test-memory/memory.limit_in_bytes

# 启动一个内存消耗进程
# 创建一个简单的内存消耗脚本
# 使用独立的内存消耗脚本：demos/memory_eater.py
cp demos/memory_eater.py .

# 在 cgroup 中运行脚本
sudo cgexec -g memory:test-memory python3 memory_eater.py
# 进程会在达到内存限制时被终止

# 清理
sudo rmdir /sys/fs/cgroup/memory/test-memory
rm memory_eater.py
```

#### 8.1.3 联合文件系统（Union FS）

**什么是联合文件系统**：

联合文件系统是一种分层的文件系统，可以将多个目录合并成一个虚拟的文件系统视图。

```bash
# 常见的联合文件系统：
# 1. OverlayFS - Linux 内核主线支持
# 2. AUFS - Docker 早期使用
# 3. DeviceMapper - Red Hat 系统常用
# 4. Btrfs - 支持快照和子卷
# 5. ZFS - 高级文件系统特性

# 检查内核是否支持 OverlayFS
grep overlay /proc/filesystems

# 或者检查模块
lsmod | grep overlay
```

**OverlayFS 实验**：

```bash
# 创建实验目录
mkdir -p overlay-demo/{lower,upper,work,merged}

# 在 lower 层创建一些文件
echo "This is from lower layer" > overlay-demo/lower/file1.txt
echo "Lower layer file" > overlay-demo/lower/file2.txt
mkdir overlay-demo/lower/subdir
echo "Subdirectory file" > overlay-demo/lower/subdir/file3.txt

# 在 upper 层创建一些文件
echo "This is from upper layer" > overlay-demo/upper/file1.txt
echo "Upper layer only" > overlay-demo/upper/file4.txt

# 挂载 OverlayFS
sudo mount -t overlay overlay \
  -o lowerdir=overlay-demo/lower,upperdir=overlay-demo/upper,workdir=overlay-demo/work \
  overlay-demo/merged

# 查看合并后的文件系统
ls -la overlay-demo/merged/
cat overlay-demo/merged/file1.txt  # 显示 upper 层的内容
cat overlay-demo/merged/file2.txt  # 显示 lower 层的内容
cat overlay-demo/merged/file4.txt  # 显示 upper 层独有的内容

# 在合并层创建新文件
echo "New file in merged" > overlay-demo/merged/file5.txt

# 检查文件实际存储位置
ls overlay-demo/upper/  # file5.txt 会出现在这里
ls overlay-demo/lower/  # 保持不变

# 删除 lower 层的文件
rm overlay-demo/merged/file2.txt

# 检查删除操作的实现
ls -la overlay-demo/upper/  # 会有一个 whiteout 文件

# 卸载文件系统
sudo umount overlay-demo/merged

# 清理
rm -rf overlay-demo
```

#### 8.1.4 容器与虚拟机的区别

**架构对比**：

```bash
# 虚拟机架构：
# 物理硬件 -> 宿主操作系统 -> Hypervisor -> 客户操作系统 -> 应用程序

# 容器架构：
# 物理硬件 -> 宿主操作系统 -> 容器运行时 -> 应用程序

# 查看系统虚拟化支持
# 检查 CPU 虚拟化支持
grep -E '(vmx|svm)' /proc/cpuinfo

# 检查是否在虚拟机中运行
sudo dmidecode -s system-manufacturer
sudo dmidecode -s system-product-name

# 或者使用 systemd-detect-virt
systemd-detect-virt
```

**性能对比实验**：

```bash
# 创建性能测试脚本
# 使用独立的性能测试脚本：demos/performance_test.sh
cp demos/performance_test.sh .
chmod +x performance_test.sh

# 在宿主机运行测试
echo "=== 宿主机性能 ==="
./performance_test.sh

# 如果有 Docker，可以在容器中运行相同测试
if command -v docker &> /dev/null; then
    echo "\n=== 容器性能 ==="
    docker run --rm -v $(pwd)/performance_test.sh:/test.sh ubuntu:20.04 bash /test.sh
fi

# 清理
rm performance_test.sh
```

**资源使用对比**：

```bash
# 创建资源监控脚本
# 使用独立的资源监控脚本：demos/resource_monitor.sh
cp demos/resource_monitor.sh .
chmod +x resource_monitor.sh

# 如果有 Docker 则运行监控
if command -v docker &> /dev/null; then
    ./resource_monitor.sh
else
    echo "Docker 未安装，跳过容器测试"
fi

# 清理
rm resource_monitor.sh
```

### 8.2 Docker 预备知识

#### 8.2.1 Linux 内核特性

**容器相关的内核特性**：

```bash
# 检查内核版本（Docker 要求 3.10+）
uname -r

# 检查关键内核特性
echo "=== 检查容器相关内核特性 ==="

# 1. Namespaces 支持
echo "Namespace 支持："
ls /proc/self/ns/ 2>/dev/null && echo "✓ 支持" || echo "✗ 不支持"

# 2. Cgroups 支持
echo "Cgroups 支持："
[ -d /sys/fs/cgroup ] && echo "✓ 支持" || echo "✗ 不支持"

# 3. OverlayFS 支持
echo "OverlayFS 支持："
grep overlay /proc/filesystems >/dev/null && echo "✓ 支持" || echo "✗ 不支持"

# 4. Netfilter 支持（用于网络）
echo "Netfilter 支持："
lsmod | grep -E '(iptable|netfilter)' >/dev/null && echo "✓ 支持" || echo "✗ 不支持"

# 5. Bridge 网络支持
echo "Bridge 网络支持："
lsmod | grep bridge >/dev/null && echo "✓ 支持" || echo "✗ 不支持"
```

**内核参数优化**：

```bash
# 查看当前内核参数
echo "=== 容器相关内核参数 ==="

# 网络相关参数
echo "IP 转发：$(cat /proc/sys/net/ipv4/ip_forward)"
echo "桥接网络过滤：$(cat /proc/sys/net/bridge/bridge-nf-call-iptables 2>/dev/null || echo '未设置')"

# 内存相关参数
echo "内存过量分配：$(cat /proc/sys/vm/overcommit_memory)"
echo "交换分区使用倾向：$(cat /proc/sys/vm/swappiness)"

# 文件系统相关参数
echo "最大文件描述符：$(cat /proc/sys/fs/file-max)"
echo "inotify 实例限制：$(cat /proc/sys/fs/inotify/max_user_instances)"

# 进程相关参数
echo "最大进程数：$(cat /proc/sys/kernel/pid_max)"
echo "最大线程数：$(cat /proc/sys/kernel/threads-max)"
```

**创建内核参数优化脚本**：

```bash
# 使用独立的容器优化脚本：demos/optimize_for_containers.sh
cp demos/optimize_for_containers.sh .
chmod +x optimize_for_containers.sh
echo "内核优化脚本已创建：optimize_for_containers.sh"
```

#### 8.2.2 文件系统层次

**理解分层文件系统**：

```bash
# 创建分层文件系统演示
mkdir -p layered-fs-demo/{base,layer1,layer2,final}

# 基础层
echo "Base system files" > layered-fs-demo/base/system.conf
echo "#!/bin/bash\necho 'Base application'" > layered-fs-demo/base/app.sh
chmod +x layered-fs-demo/base/app.sh

# 第一层：添加配置
echo "Updated configuration" > layered-fs-demo/layer1/system.conf
echo "Additional config" > layered-fs-demo/layer1/extra.conf

# 第二层：添加应用更新
echo "#!/bin/bash\necho 'Updated application v2.0'" > layered-fs-demo/layer2/app.sh
chmod +x layered-fs-demo/layer2/app.sh
echo "New feature config" > layered-fs-demo/layer2/feature.conf

# 模拟容器镜像层合并
echo "=== 模拟容器镜像层合并 ==="
echo "基础层内容："
ls -la layered-fs-demo/base/

echo "\n第一层内容："
ls -la layered-fs-demo/layer1/

echo "\n第二层内容："
ls -la layered-fs-demo/layer2/

# 使用 OverlayFS 合并所有层
sudo mount -t overlay overlay \
  -o lowerdir=layered-fs-demo/layer2:layered-fs-demo/layer1:layered-fs-demo/base,upperdir=layered-fs-demo/final,workdir=/tmp/work-layered \
  /tmp/merged-layers 2>/dev/null || echo "需要 root 权限进行 OverlayFS 演示"

# 手动合并演示（不需要 root 权限）
cp -r layered-fs-demo/base/* layered-fs-demo/final/ 2>/dev/null || true
cp -r layered-fs-demo/layer1/* layered-fs-demo/final/ 2>/dev/null || true
cp -r layered-fs-demo/layer2/* layered-fs-demo/final/ 2>/dev/null || true

echo "\n合并后的最终层："
ls -la layered-fs-demo/final/
echo "\n最终应用版本："
layered-fs-demo/final/app.sh
echo "\n最终配置："
cat layered-fs-demo/final/system.conf

# 清理
rm -rf layered-fs-demo
```

**镜像层管理实验**：

```bash
# 创建镜像层管理演示
# 使用独立的镜像层演示脚本：demos/image_layers_demo.sh
cp demos/image_layers_demo.sh .
chmod +x image_layers_demo.sh
./image_layers_demo.sh
rm image_layers_demo.sh
```

#### 8.2.3 网络命名空间

**容器网络基础**：

```bash
# 创建容器网络演示
echo "=== 容器网络命名空间演示 ==="

# 创建两个网络命名空间（模拟两个容器）
sudo ip netns add container1 2>/dev/null || echo "需要 root 权限创建网络命名空间"
sudo ip netns add container2 2>/dev/null || echo "需要 root 权限创建网络命名空间"

# 如果有权限，继续演示
if sudo ip netns list | grep -q container1; then
    echo "\n创建的网络命名空间："
    sudo ip netns list
    
    # 创建虚拟网桥（模拟 Docker bridge）
    sudo ip link add docker0 type bridge
    sudo ip addr add 172.17.0.1/16 dev docker0
    sudo ip link set docker0 up
    
    # 为每个容器创建 veth 对
    sudo ip link add veth1 type veth peer name veth1-peer
    sudo ip link add veth2 type veth peer name veth2-peer
    
    # 将一端连接到网桥
    sudo ip link set veth1 master docker0
    sudo ip link set veth2 master docker0
    sudo ip link set veth1 up
    sudo ip link set veth2 up
    
    # 将另一端移动到容器命名空间
    sudo ip link set veth1-peer netns container1
    sudo ip link set veth2-peer netns container2
    
    # 配置容器网络
    sudo ip netns exec container1 ip addr add 172.17.0.2/16 dev veth1-peer
    sudo ip netns exec container1 ip link set veth1-peer up
    sudo ip netns exec container1 ip link set lo up
    sudo ip netns exec container1 ip route add default via 172.17.0.1
    
    sudo ip netns exec container2 ip addr add 172.17.0.3/16 dev veth2-peer
    sudo ip netns exec container2 ip link set veth2-peer up
    sudo ip netns exec container2 ip link set lo up
    sudo ip netns exec container2 ip route add default via 172.17.0.1
    
    echo "\n容器网络配置："
    echo "Container1 IP: 172.17.0.2"
    echo "Container2 IP: 172.17.0.3"
    echo "Bridge IP: 172.17.0.1"
    
    # 测试容器间通信
    echo "\n测试容器间通信："
    sudo ip netns exec container1 ping -c 2 172.17.0.3
    
    # 清理
    echo "\n清理网络配置..."
    sudo ip netns delete container1
    sudo ip netns delete container2
    sudo ip link delete docker0
else
    echo "演示容器网络概念（无需 root 权限）："
    echo "\n容器网络模式："
    echo "1. Bridge 模式：容器连接到虚拟网桥"
    echo "2. Host 模式：容器使用宿主机网络"
    echo "3. None 模式：容器没有网络接口"
    echo "4. Container 模式：容器共享其他容器的网络"
    
    echo "\n网络组件："
    echo "- veth pair：虚拟以太网接口对"
    echo "- bridge：虚拟网桥"
    echo "- iptables：网络地址转换和防火墙"
    echo "- netfilter：内核网络过滤框架"
fi
```

#### 8.2.4 进程隔离机制

**进程隔离演示**：

```bash
# 创建进程隔离演示
# 使用独立的进程隔离演示脚本：demos/process_isolation_demo.sh
cp demos/process_isolation_demo.sh .
chmod +x process_isolation_demo.sh
./process_isolation_demo.sh
rm process_isolation_demo.sh
```

### 8.3 Kubernetes 预备知识

#### 8.3.1 集群概念

**Kubernetes 集群架构**：

```bash
# 创建 Kubernetes 概念演示
# 使用独立的Kubernetes概念演示脚本：demos/k8s_concepts_demo.sh
cp demos/k8s_concepts_demo.sh .
chmod +x k8s_concepts_demo.sh
./k8s_concepts_demo.sh
rm k8s_concepts_demo.sh
```

**集群网络模型**：

```bash
# 创建网络模型演示
echo "=== Kubernetes 网络模型 ==="

echo "网络要求："
echo "1. 每个 Pod 都有唯一的 IP 地址"
echo "2. Pod 之间可以直接通信（无需 NAT）"
echo "3. 节点和 Pod 之间可以直接通信"
echo "4. Pod 看到的自己的 IP 就是其他 Pod 看到的 IP"

echo "\n网络组件："
echo "├── CNI (Container Network Interface)"
echo "│   ├── Flannel    # 简单的覆盖网络"
echo "│   ├── Calico     # 基于 BGP 的网络方案"
echo "│   ├── Weave      # 网格网络"
echo "│   └── Cilium     # 基于 eBPF 的网络"
echo "├── kube-proxy     # 服务代理和负载均衡"
echo "└── CoreDNS        # 集群 DNS 服务"

echo "\n=== 网络通信示例 ==="

# 模拟 Pod 网络
echo "Pod 网络示例："
echo "Node1: 10.244.1.0/24"
echo "├── Pod1: 10.244.1.10"
echo "├── Pod2: 10.244.1.11"
echo "└── Pod3: 10.244.1.12"
echo ""
echo "Node2: 10.244.2.0/24"
echo "├── Pod4: 10.244.2.10"
echo "├── Pod5: 10.244.2.11"
echo "└── Pod6: 10.244.2.12"

echo "\nService 网络示例："
echo "ClusterIP 范围: 10.96.0.0/12"
echo "├── kubernetes: 10.96.0.1:443"
echo "├── web-service: 10.96.1.100:80"
echo "└── db-service: 10.96.1.101:3306"
```

#### 8.2.5 网络通信基础

**容器间通信**：

```bash
# 创建容器通信演示
# 使用独立的容器通信演示脚本：demos/container_communication.sh
cp demos/container_communication.sh .
chmod +x container_communication.sh
./container_communication.sh
rm container_communication.sh
```

#### 8.2.6 存储挂载

**Kubernetes 存储概念**：

**Kubernetes 存储概念演示**：

> 详细的存储概念演示脚本请参考：`demos/k8s_storage_demo.sh`
>
> 运行方式：
>
> ```bash
> chmod +x demos/k8s_storage_demo.sh
> ./demos/k8s_storage_demo.sh
> ```
>
> 该脚本演示了 Kubernetes 中的存储类型、生命周期、访问模式和实际应用示例。

#### 8.2.7 服务发现机制

**服务发现演示**：

```bash
# 创建服务发现演示
# 使用独立的服务发现演示脚本：demos/service_discovery_demo.sh
cp demos/service_discovery_demo.sh .
chmod +x service_discovery_demo.sh
./service_discovery_demo.sh
rm service_discovery_demo.sh
```

**实践练习：**

```bash
# 1. 检查系统容器支持
# 使用独立的容器支持检查脚本：demos/check_container_support.sh
cp demos/check_container_support.sh .
chmod +x check_container_support.sh
./check_container_support.sh

# 2. 创建学习路径指南
# 使用独立的学习路径指南：demos/container_learning_path.md
cp demos/container_learning_path.md .
echo "\n学习路径指南已创建：container_learning_path.md"

# 清理
rm check_container_support.sh
```

---

## 第九章：实践项目

### 9.1 Web 服务器搭建

- Nginx 安装和配置
- 静态网站部署
- 日志分析
- 性能监控

### 9.2 数据库服务

- MySQL/PostgreSQL 安装
- 数据库用户管理
- 备份和恢复
- 安全配置

### 9.3 综合项目

- LAMP/LEMP 环境搭建
- 应用部署和配置
- 监控和日志管理
- 自动化脚本编写

## 第十章：最佳实践和进阶

### 10.1 系统安全

- 用户权限最小化原则
- 定期安全更新
- 日志审计
- 入侵检测基础

### 10.2 性能优化

- 系统性能分析
- 资源使用优化
- 内核参数调优
- 存储性能优化

### 10.3 故障排查

- 常见问题诊断
- 日志分析技巧
- 系统恢复方法
- 预防性维护

---

## 第十一章：实验环境

### 11.1 推荐配置

- Ubuntu 20.04 LTS 或更新版本
- 虚拟机或云服务器
- 至少 2GB 内存，20GB 存储
- 网络连接

### 11.2 实验工具

- VirtualBox 或 VMware
- SSH 客户端
- 文本编辑器
- 浏览器（用于文档查阅）

## 第十二章：参考资料

### 12.1 书籍推荐

**中文书籍：**

- 《鸟哥的 Linux 私房菜》- 适合初学者的经典教材
- 《Linux 命令行与 shell 脚本编程大全》- 深入学习命令行和脚本
- 《深入理解 Linux 内核》- 内核原理深度解析
- 《Linux 系统编程》- 系统调用和编程实践

**英文书籍：**

- "The Linux Command Line" by William Shotts - [在线免费版本](http://linuxcommand.org/tlcl.php)
- "UNIX and Linux System Administration Handbook" - 系统管理权威指南
- "Advanced Programming in the UNIX Environment" - UNIX 编程经典
- "Linux Kernel Development" by Robert Love - 内核开发指南

### 12.2 在线资源

**官方文档：**

- [Linux 内核官方文档](https://www.kernel.org/doc/)
- [Ubuntu 官方指南](https://ubuntu.com/tutorials)
- [Red Hat Enterprise Linux 文档](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/)
- [Arch Linux Wiki](https://wiki.archlinux.org/) - 最全面的 Linux 知识库

**学习网站：**

- [Linux Journey](https://linuxjourney.com/) - 交互式 Linux 学习
- [OverTheWire](https://overthewire.org/wargames/) - Linux 安全挑战
- [Explain Shell](https://explainshell.com/) - 命令解释工具
- [Linux Command Library](https://linuxcommandlibrary.com/) - 命令参考大全
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/index.html) - 高级 Bash 脚本编写指南

**社区资源：**

- [Stack Overflow](https://stackoverflow.com/questions/tagged/linux) - 问题解答社区
- [Reddit r/linux](https://www.reddit.com/r/linux/) - Linux 讨论社区
- [Linux.org](https://www.linux.org/) - Linux 资讯和教程
- [GitHub 开源项目](https://github.com/topics/linux) - 开源 Linux 项目

**云原生相关：**

- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Docker 官方文档](https://docs.docker.com/)
- [CNCF 项目](https://www.cncf.io/projects/) - 云原生计算基金会项目
- [12-Factor App](https://12factor.net/) - 云原生应用设计原则

### 12.3 练习平台

**在线实验环境：**

- [Play with Docker](https://labs.play-with-docker.com/) - 免费 Docker 在线实验
- [Katacoda](https://www.katacoda.com/) - 交互式学习场景
- [Linux Academy](https://linuxacademy.com/) - 专业 Linux 培训平台
- [Killercoda](https://killercoda.com/) - 免费的交互式学习平台

**云平台免费层：**

- [AWS Free Tier](https://aws.amazon.com/free/) - 12 个月免费 EC2 实例
- [Google Cloud Free Tier](https://cloud.google.com/free) - 永久免费和试用额度
- [Azure Free Account](https://azure.microsoft.com/free/) - 12 个月免费服务
- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/) - 永久免费的 ARM 实例

**本地环境：**

- [VirtualBox](https://www.virtualbox.org/) - 免费虚拟化软件
- [VMware Workstation Player](https://www.vmware.com/products/workstation-player.html) - 个人免费版
- [Vagrant](https://www.vagrantup.com/) - 开发环境管理工具
- [Docker Desktop](https://www.docker.com/products/docker-desktop) - 容器开发环境

**Linux 发行版下载：**

- [Ubuntu](https://ubuntu.com/download) - 最受欢迎的桌面发行版
- [CentOS Stream](https://www.centos.org/centos-stream/) - 企业级发行版
- [Fedora](https://getfedora.org/) - 最新技术的发行版
- [Debian](https://www.debian.org/) - 稳定可靠的发行版

### 12.4 认证和职业发展

**Linux 认证：**

- [Linux Professional Institute (LPI)](https://www.lpi.org/) - 厂商中立认证
- [Red Hat Certified System Administrator (RHCSA)](https://www.redhat.com/en/services/certification/rhcsa)
- [CompTIA Linux+](https://www.comptia.org/certifications/linux) - 入门级认证
- [Linux Foundation Certified System Administrator (LFCS)](https://training.linuxfoundation.org/certification/linux-foundation-certified-sysadmin-lfcs/)

**云原生认证：**

- [Certified Kubernetes Administrator (CKA)](https://www.cncf.io/certification/cka/)
- [Certified Kubernetes Application Developer (CKAD)](https://www.cncf.io/certification/ckad/)
- [AWS Certified Solutions Architect](https://aws.amazon.com/certification/certified-solutions-architect-associate/)
- [Google Cloud Professional Cloud Architect](https://cloud.google.com/certification/cloud-architect)

### 12.5 持续学习建议

**学习路径：**

1. **基础阶段**：掌握基本命令和文件系统操作
2. **进阶阶段**：学习系统管理、网络配置、安全设置
3. **专业阶段**：深入内核、性能调优、自动化运维
4. **云原生阶段**：容器化、微服务、Kubernetes 编排
5. **DevOps 工具和实践**：持续集成/持续部署 (CI/CD)、监控工具、配置管理

---
