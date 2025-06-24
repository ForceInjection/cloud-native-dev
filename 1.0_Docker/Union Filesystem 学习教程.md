# Union Filesystem 学习教程

## 目录

- [Union Filesystem 学习教程](#union-filesystem-学习教程)
  - [目录](#目录)
  - [学习目标](#学习目标)
  - [第一部分：Union Filesystem 详解](#第一部分union-filesystem-详解)
    - [1.1 什么是 Union Filesystem？](#11-什么是-union-filesystem)
    - [1.2 Union Filesystem 的类型](#12-union-filesystem-的类型)
      - [1.2.1 AUFS (Advanced Multi-Layered Unification Filesystem)](#121-aufs-advanced-multi-layered-unification-filesystem)
      - [1.2.2 OverlayFS](#122-overlayfs)
      - [1.2.3 Device Mapper](#123-device-mapper)
      - [1.2.4 Btrfs](#124-btrfs)
      - [1.2.5 ZFS](#125-zfs)
    - [1.3 分层文件系统架构](#13-分层文件系统架构)
  - [第二部分：实践练习 - 使用 OverlayFS](#第二部分实践练习---使用-overlayfs)
    - [2.1 准备工作](#21-准备工作)
    - [2.2 创建基础目录结构](#22-创建基础目录结构)
    - [2.3 挂载 OverlayFS](#23-挂载-overlayfs)
    - [2.4 验证分层效果](#24-验证分层效果)
  - [第三部分：Docker 中的存储驱动](#第三部分docker-中的存储驱动)
    - [3.1 Docker 存储架构](#31-docker-存储架构)
    - [3.2 镜像层管理](#32-镜像层管理)
      - [3.2.1 只读层](#321-只读层)
      - [3.2.2 可写层](#322-可写层)
      - [3.2.3 写时复制 (Copy-on-Write)](#323-写时复制-copy-on-write)
      - [3.2.4 层共享机制](#324-层共享机制)
    - [3.3 存储驱动比较](#33-存储驱动比较)
  - [第四部分：实践练习 - Docker 镜像分层](#第四部分实践练习---docker-镜像分层)
    - [4.1 查看镜像层信息](#41-查看镜像层信息)
    - [4.2 构建多层镜像](#42-构建多层镜像)
    - [4.3 分析层结构](#43-分析层结构)
    - [4.4 优化镜像层](#44-优化镜像层)
  - [第五部分：高级特性](#第五部分高级特性)
    - [5.1 写时复制机制详解](#51-写时复制机制详解)
    - [5.2 层缓存策略](#52-层缓存策略)
    - [5.3 存储空间优化](#53-存储空间优化)
  - [第六部分：性能优化](#第六部分性能优化)
    - [6.1 存储驱动选择](#61-存储驱动选择)
    - [6.2 镜像构建优化](#62-镜像构建优化)
    - [6.3 运行时性能调优](#63-运行时性能调优)
  - [第七部分：故障排除](#第七部分故障排除)
    - [7.1 常见问题](#71-常见问题)
    - [7.2 调试工具](#72-调试工具)
  - [第八部分：实验练习](#第八部分实验练习)
    - [练习 1：手动创建分层文件系统](#练习-1手动创建分层文件系统)
    - [练习 2：分析 Docker 镜像结构](#练习-2分析-docker-镜像结构)
    - [练习 3：优化镜像构建](#练习-3优化镜像构建)
  - [总结](#总结)
    - [关键要点](#关键要点)
    - [进一步学习](#进一步学习)
    - [参考资源](#参考资源)

## 学习目标

通过本教程，您将能够：

- 理解 Union Filesystem 的基本概念和工作原理
- 掌握不同类型的联合文件系统及其特点
- 学会使用 OverlayFS 创建分层文件系统
- 理解 Docker 中的存储驱动机制
- 实践 Docker 镜像分层和优化技术
- 了解写时复制和层缓存等高级特性

## 第一部分：Union Filesystem 详解

### 1.1 什么是 Union Filesystem？

Union Filesystem（联合文件系统）是一种分层的文件系统，它可以将多个目录（分支）联合挂载到同一个挂载点上，形成一个统一的文件系统视图。

**历史背景：**

- 1993年：第一个联合文件系统 Unionfs 在贝尔实验室诞生
- 2006年：AUFS 项目启动，成为早期 Docker 的默认存储驱动
- 2014年：OverlayFS 合并到 Linux 内核主线
- 现在：成为容器技术的核心存储技术

**核心特性：**

- **分层存储**：将文件系统分为多个层，每层都是只读或可写的
- **统一视图**：多个层合并后呈现为单一的文件系统
- **写时复制**：修改文件时才进行实际的复制操作
- **空间效率**：多个容器可以共享相同的基础层

**工作原理：**

```text
用户视图 (统一文件系统)
    ↑
┌─────────────────────────┐
│     联合挂载点          │
└─────────────────────────┘
    ↑
┌─────────┬─────────┬─────────┐
│  层 3   │  层 2   │  层 1   │
│ (可写)  │ (只读)  │ (只读)  │
└─────────┴─────────┴─────────┘
```

### 1.2 Union Filesystem 的类型

Linux 生态系统中存在多种联合文件系统实现，每种都有其独特的特点和适用场景：

#### 1.2.1 AUFS (Advanced Multi-Layered Unification Filesystem)

- **特点**：最早被 Docker 采用的存储驱动
- **优势**：
  - 成熟稳定，经过长期验证
  - 支持多层合并
  - 良好的性能表现
- **劣势**：
  - 不在 Linux 内核主线中
  - 需要额外的内核补丁
- **适用场景**：Ubuntu 等支持 AUFS 的发行版

#### 1.2.2 OverlayFS

- **特点**：Linux 内核原生支持的联合文件系统
- **优势**：
  - 内核原生支持，无需额外补丁
  - 简单的两层架构（lower + upper）
  - 优秀的性能表现
  - 广泛的发行版支持
- **劣势**：
  - 相对较新，某些边缘情况可能存在问题
- **适用场景**：现代 Linux 发行版的首选

#### 1.2.3 Device Mapper

- **特点**：基于块设备的存储驱动
- **优势**：
  - 块级别的操作，性能稳定
  - 支持快照和精简配置
  - 适合企业级应用
- **劣势**：
  - 配置复杂
  - 存储空间利用率相对较低
- **适用场景**：RHEL/CentOS 等企业级发行版

#### 1.2.4 Btrfs

- **特点**：现代化的写时复制文件系统
- **优势**：
  - 原生支持快照和子卷
  - 优秀的空间效率
  - 内置压缩和去重功能
- **劣势**：
  - 相对较新，稳定性有待验证
  - 复杂的管理工具
- **适用场景**：需要高级存储特性的场景

#### 1.2.5 ZFS

- **特点**：企业级的高级文件系统
- **优势**：
  - 极高的数据完整性保证
  - 强大的快照和克隆功能
  - 内置压缩和去重
- **劣势**：
  - 内存消耗较大
  - 许可证问题（CDDL vs GPL）
- **适用场景**：对数据完整性要求极高的企业环境

### 1.3 分层文件系统架构

联合文件系统的核心是分层架构，以 OverlayFS 为例：

```text
┌─────────────────────────────────────┐
│           合并视图 (merged)          │  ← 用户看到的统一文件系统
└─────────────────────────────────────┘
                    ↑
┌─────────────────────────────────────┐
│           上层 (upperdir)           │  ← 可写层，存储所有修改
└─────────────────────────────────────┘
                    +
┌─────────────────────────────────────┐
│           下层 (lowerdir)           │  ← 只读层，通常是基础镜像
└─────────────────────────────────────┘
                    +
┌─────────────────────────────────────┐
│           工作目录 (workdir)         │  ← 临时工作空间
└─────────────────────────────────────┘
```

**层的类型：**

1. **基础层 (Base Layer)**：
   - 包含操作系统的基础文件
   - 完全只读
   - 可以被多个容器共享

2. **中间层 (Intermediate Layers)**：
   - 包含应用程序和依赖
   - 只读层
   - 按照 Dockerfile 指令逐层构建

3. **容器层 (Container Layer)**：
   - 容器运行时的可写层
   - 存储所有运行时修改
   - 容器删除时一并删除

## 第二部分：实践练习 - 使用 OverlayFS

### 2.1 准备工作

首先检查系统是否支持 OverlayFS：

```bash
# 检查内核模块
lsmod | grep overlay

# 如果没有加载，手动加载
sudo modprobe overlay

# 检查内核支持
grep -i overlay /proc/filesystems
```

### 2.2 创建基础目录结构

创建实验所需的目录：

```bash
# 创建实验目录
mkdir -p ~/overlay-demo/{lower,upper,work,merged}

# 在下层目录创建一些文件
echo "Base file content" > ~/overlay-demo/lower/base.txt
echo "Lower layer file" > ~/overlay-demo/lower/lower.txt
mkdir ~/overlay-demo/lower/subdir
echo "Subdirectory file" > ~/overlay-demo/lower/subdir/sub.txt

# 查看下层内容
ls -la ~/overlay-demo/lower/
tree ~/overlay-demo/lower/
```

### 2.3 挂载 OverlayFS

**挂载命令：**

```bash
sudo mount -t overlay overlay \
  -o lowerdir=~/overlay-demo/lower,upperdir=~/overlay-demo/upper,workdir=~/overlay-demo/work \
  ~/overlay-demo/merged
```

**参数说明：**

- `lowerdir`：只读的下层目录
- `upperdir`：可写的上层目录
- `workdir`：工作目录，用于原子操作
- `merged`：合并后的挂载点

### 2.4 验证分层效果

**查看合并后的内容：**

```bash
# 查看合并视图
ls -la ~/overlay-demo/merged/
cat ~/overlay-demo/merged/base.txt
```

**测试写操作：**

```bash
# 在合并视图中创建新文件
echo "New file in upper layer" > ~/overlay-demo/merged/new.txt

# 修改现有文件
echo "Modified content" >> ~/overlay-demo/merged/base.txt

# 查看各层的变化
echo "=== Lower layer ==="
ls -la ~/overlay-demo/lower/

echo "=== Upper layer ==="
ls -la ~/overlay-demo/upper/

echo "=== Merged view ==="
ls -la ~/overlay-demo/merged/
```

**观察结果：**

- 新文件只出现在上层目录
- 修改的文件在上层创建了副本
- 下层文件保持不变
- 合并视图显示所有文件

**清理实验环境：**

```bash
# 卸载 overlay
sudo umount ~/overlay-demo/merged

# 清理目录
rm -rf ~/overlay-demo
```

## 第三部分：Docker 中的存储驱动

### 3.1 Docker 存储架构

Docker 使用联合文件系统来实现高效的镜像存储和容器运行：

```text
Docker 镜像结构

┌─────────────────────────────────────┐
│        容器层 (Container Layer)      │  ← 可写，容器运行时修改
├─────────────────────────────────────┤
│        应用层 (Application Layer)    │  ← 只读，应用程序文件
├─────────────────────────────────────┤
│        依赖层 (Dependencies Layer)   │  ← 只读，运行时依赖
├─────────────────────────────────────┤
│        基础层 (Base Layer)          │  ← 只读，操作系统基础
└─────────────────────────────────────┘
```

**查看 Docker 存储驱动：**

```bash
# 查看当前存储驱动
docker info | grep "Storage Driver"

# 查看详细存储信息
docker system df

# 查看存储驱动详细信息
docker info | grep -A 10 "Storage Driver"
```

### 3.2 镜像层管理

#### 3.2.1 只读层

只读层包含镜像的所有文件，这些层在多个容器之间共享：

```bash
# 查看镜像层信息
docker image inspect ubuntu:20.04 | jq '.[0].RootFS.Layers'

# 查看镜像历史
docker history ubuntu:20.04
```

#### 3.2.2 可写层

每个容器都有自己的可写层，用于存储运行时的所有修改：

```bash
# 启动容器并进行修改
docker run -it --name test-container ubuntu:20.04 bash

# 在容器中执行（在容器内部）
echo "Container modification" > /tmp/container-file.txt
apt update && apt install -y vim
exit

# 查看容器层的变化
docker diff test-container
```

#### 3.2.3 写时复制 (Copy-on-Write)

当容器需要修改只读层中的文件时，Docker 会将文件复制到可写层：

```bash
# 演示写时复制
docker run -it --name cow-demo ubuntu:20.04 bash

# 在容器中修改系统文件
echo "# Modified by container" >> /etc/hosts
cat /etc/hosts
exit

# 查看修改
docker diff cow-demo
```

#### 3.2.4 层共享机制

多个镜像可以共享相同的基础层：

```bash
# 拉取相关镜像
docker pull ubuntu:20.04
docker pull ubuntu:18.04
docker pull nginx:alpine

# 查看层共享情况
docker system df -v
```

### 3.3 存储驱动比较

| 存储驱动 | 性能 | 稳定性 | 功能 | 适用场景 |
|---------|------|--------|------|----------|
| overlay2 | 优秀 | 很好 | 基础 | 通用推荐 |
| aufs | 良好 | 优秀 | 丰富 | Ubuntu 系统 |
| devicemapper | 良好 | 优秀 | 企业级 | RHEL/CentOS |
| btrfs | 良好 | 一般 | 高级 | 特殊需求 |
| zfs | 优秀 | 优秀 | 最丰富 | 企业级 |

## 第四部分：实践练习 - Docker 镜像分层

### 4.1 查看镜像层信息

**检查镜像结构：**

```bash
# 拉取测试镜像
docker pull nginx:alpine

# 查看镜像详细信息
docker image inspect nginx:alpine

# 查看镜像层
docker image inspect nginx:alpine | jq '.[0].RootFS'

# 查看镜像构建历史
docker history nginx:alpine
```

### 4.2 构建多层镜像

创建一个 Dockerfile 来演示分层：

```dockerfile
# 创建 Dockerfile
cat > Dockerfile << 'EOF'
# 第一层：基础镜像
FROM ubuntu:20.04

# 第二层：更新包管理器
RUN apt-get update

# 第三层：安装基础工具
RUN apt-get install -y curl wget

# 第四层：安装应用
RUN apt-get install -y nginx

# 第五层：配置文件
COPY nginx.conf /etc/nginx/nginx.conf

# 第六层：创建工作目录
WORKDIR /var/www/html

# 第七层：添加内容
RUN echo "<h1>Hello from Docker</h1>" > index.html

# 暴露端口
EXPOSE 80

# 启动命令
CMD ["nginx", "-g", "daemon off;"]
EOF
```

**创建配置文件：**

```bash
# 创建简单的 nginx 配置
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        location / {
            root /var/www/html;
            index index.html;
        }
    }
}
EOF
```

**构建镜像：**

```bash
# 构建镜像
docker build -t layered-nginx .

# 查看构建过程中的层
docker history layered-nginx
```

### 4.3 分析层结构

**查看层大小和内容：**

```bash
# 查看镜像大小
docker images layered-nginx

# 查看详细的层信息
docker image inspect layered-nginx | jq '.[0].RootFS.Layers'

# 分析每层的大小
docker history layered-nginx --format "table {{.CreatedBy}}\t{{.Size}}"
```

**比较优化前后的差异：**

```dockerfile
# 创建优化版本的 Dockerfile
cat > Dockerfile.optimized << 'EOF'
FROM ubuntu:20.04

# 合并多个 RUN 指令
RUN apt-get update && \
    apt-get install -y curl wget nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 配置和内容
COPY nginx.conf /etc/nginx/nginx.conf
WORKDIR /var/www/html
RUN echo "<h1>Hello from Optimized Docker</h1>" > index.html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
```

```bash
# 构建优化版本
docker build -f Dockerfile.optimized -t layered-nginx:optimized .

# 比较大小
docker images | grep layered-nginx

# 比较层数
echo "=== 原版本 ==="
docker history layered-nginx --format "table {{.CreatedBy}}\t{{.Size}}" | wc -l

echo "=== 优化版本 ==="
docker history layered-nginx:optimized --format "table {{.CreatedBy}}\t{{.Size}}" | wc -l
```

### 4.4 优化镜像层

**最佳实践：**

1. **合并 RUN 指令**：

```dockerfile
# 不好的做法
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2

# 好的做法
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

2. **使用 .dockerignore**：

```bash
# 创建 .dockerignore
cat > .dockerignore << 'EOF'
.git
*.md
*.log
node_modules
.DS_Store
EOF
```

3. **多阶段构建**：

```dockerfile
# 多阶段构建示例
cat > Dockerfile.multistage << 'EOF'
# 构建阶段
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 运行阶段
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
```

## 第五部分：高级特性

### 5.1 写时复制机制详解

写时复制（Copy-on-Write, COW）是联合文件系统的核心机制：

**工作流程：**

1. **读操作**：直接从相应层读取文件
2. **写操作**：
   - 如果文件在上层存在，直接修改
   - 如果文件在下层存在，复制到上层后修改
   - 如果文件不存在，在上层创建新文件

**演示 COW 机制：**

```bash
# 创建演示环境
mkdir -p ~/cow-demo/{base,container1,container2}

# 在基础层创建文件
echo "Original content" > ~/cow-demo/base/shared.txt
echo "Base file" > ~/cow-demo/base/base-only.txt

# 模拟容器1的修改
cp ~/cow-demo/base/shared.txt ~/cow-demo/container1/
echo "Modified by container1" >> ~/cow-demo/container1/shared.txt
echo "Container1 specific" > ~/cow-demo/container1/container1.txt

# 模拟容器2的修改
cp ~/cow-demo/base/shared.txt ~/cow-demo/container2/
echo "Modified by container2" >> ~/cow-demo/container2/shared.txt
echo "Container2 specific" > ~/cow-demo/container2/container2.txt

# 查看结果
echo "=== Base layer ==="
cat ~/cow-demo/base/shared.txt

echo "=== Container1 view ==="
cat ~/cow-demo/container1/shared.txt

echo "=== Container2 view ==="
cat ~/cow-demo/container2/shared.txt
```

### 5.2 层缓存策略

Docker 使用层缓存来加速镜像构建：

**缓存机制：**

```bash
# 第一次构建
time docker build -t cache-demo .

# 第二次构建（应该很快）
time docker build -t cache-demo .

# 修改 Dockerfile 后构建
echo "RUN echo 'cache test'" >> Dockerfile
time docker build -t cache-demo .
```

**缓存失效条件：**

1. Dockerfile 指令发生变化
2. 复制的文件内容发生变化
3. 使用 `--no-cache` 参数
4. 基础镜像更新

**优化缓存利用：**

```dockerfile
# 优化前：依赖变化会导致重新安装
COPY . /app
RUN npm install

# 优化后：只有 package.json 变化才重新安装
COPY package*.json /app/
RUN npm install
COPY . /app
```

### 5.3 存储空间优化

**查看存储使用情况：**

```bash
# 查看 Docker 存储使用
docker system df

# 查看详细信息
docker system df -v

# 查看镜像大小
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

**清理无用数据：**

```bash
# 清理悬空镜像
docker image prune

# 清理未使用的镜像
docker image prune -a

# 清理所有未使用的资源
docker system prune -a

# 清理特定时间前的资源
docker system prune -a --filter "until=24h"
```

## 第六部分：性能优化

### 6.1 存储驱动选择

**性能测试脚本：**

```bash
#!/bin/bash
# storage-benchmark.sh

echo "=== Storage Driver Performance Test ==="

# 测试写性能
echo "Testing write performance..."
time docker run --rm -v /tmp/test-data:/data alpine sh -c '
  for i in $(seq 1 1000); do
    echo "Test data $i" > /data/file_$i.txt
  done
'

# 测试读性能
echo "Testing read performance..."
time docker run --rm -v /tmp/test-data:/data alpine sh -c '
  for i in $(seq 1 1000); do
    cat /data/file_$i.txt > /dev/null
  done
'

# 清理
rm -rf /tmp/test-data
```

**存储驱动配置：**

```json
# /etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
```

### 6.2 镜像构建优化

**构建优化技巧：**

1. **使用适当的基础镜像**：

```dockerfile
# 选择最小的基础镜像
FROM alpine:3.14  # 而不是 ubuntu:20.04

# 或使用 distroless 镜像
FROM gcr.io/distroless/java:11
```

2. **优化层顺序**：

```dockerfile
# 将变化频率低的指令放在前面
FROM node:16-alpine

# 先复制依赖文件
COPY package*.json ./
RUN npm ci --only=production

# 再复制源代码
COPY . .
```

3. **使用构建缓存**：

```bash
# 启用 BuildKit
export DOCKER_BUILDKIT=1

# 使用缓存挂载
docker build --build-arg BUILDKIT_INLINE_CACHE=1 .
```

### 6.3 运行时性能调优

**容器存储优化：**

```bash
# 使用 tmpfs 挂载临时数据
docker run -d --tmpfs /tmp:rw,noexec,nosuid,size=100m nginx

# 使用内存文件系统
docker run -d --shm-size=1g my-app

# 限制日志大小
docker run -d --log-opt max-size=10m --log-opt max-file=3 nginx
```

**监控存储性能：**

```bash
# 监控容器 I/O
docker stats --format "table {{.Container}}\t{{.BlockIO}}"

# 查看存储驱动统计
cat /proc/mounts | grep overlay

# 监控文件系统使用
df -h | grep overlay
```

## 第七部分：故障排除

### 7.1 常见问题

**问题 1：存储空间不足：**

```bash
# 错误信息
no space left on device

# 解决方案
# 1. 清理 Docker 资源
docker system prune -a

# 2. 查看磁盘使用
df -h
du -sh /var/lib/docker/*

# 3. 移动 Docker 根目录
sudo systemctl stop docker
sudo mv /var/lib/docker /new/location/docker
sudo ln -s /new/location/docker /var/lib/docker
sudo systemctl start docker
```

**问题 2：层数过多：**

```bash
# 错误信息
too many layers

# 解决方案：合并层
docker build --squash -t optimized-image .

# 或使用多阶段构建
```

**问题 3：权限问题：**

```bash
# 错误信息
permission denied

# 解决方案
# 1. 检查文件权限
ls -la /var/lib/docker

# 2. 修复权限
sudo chown -R root:docker /var/lib/docker
sudo chmod -R 755 /var/lib/docker

# 3. 重启 Docker
sudo systemctl restart docker
```

### 7.2 调试工具

**存储驱动调试：**

```bash
# 查看存储驱动详细信息
docker info | grep -A 20 "Storage Driver"

# 查看层信息
docker image inspect <image> | jq '.[]|{Id,RepoTags,RootFS}'

# 查看容器层变化
docker diff <container>

# 查看挂载信息
findmnt -D
```

**性能分析工具：**

```bash
# 使用 iotop 监控 I/O
sudo iotop -o

# 使用 iostat 查看统计
iostat -x 1

# 查看进程文件打开情况
lsof | grep docker

# 监控文件系统事件
sudo inotifywatch -r /var/lib/docker
```

## 第八部分：实验练习

### 练习 1：手动创建分层文件系统

**目标：**使用 OverlayFS 手动创建一个类似 Docker 的分层文件系统

**步骤：**

1. 创建多层目录结构
2. 在不同层中添加文件
3. 使用 OverlayFS 合并层
4. 测试文件修改和删除

**实现：**

```bash
#!/bin/bash
# 练习1：手动分层文件系统

# 创建目录结构
mkdir -p ~/exercise1/{layer1,layer2,layer3,upper,work,merged}

# 第一层：基础系统文件
echo "#!/bin/bash" > ~/exercise1/layer1/startup.sh
echo "echo 'System starting...'" >> ~/exercise1/layer1/startup.sh
chmod +x ~/exercise1/layer1/startup.sh

# 第二层：应用程序
echo "Application v1.0" > ~/exercise1/layer2/app.txt
mkdir ~/exercise1/layer2/config
echo "debug=false" > ~/exercise1/layer2/config/app.conf

# 第三层：更新
echo "Application v1.1" > ~/exercise1/layer3/app.txt
echo "feature=enabled" >> ~/exercise1/layer3/config/app.conf

# 挂载分层文件系统
sudo mount -t overlay overlay \
  -o lowerdir=~/exercise1/layer3:~/exercise1/layer2:~/exercise1/layer1,upperdir=~/exercise1/upper,workdir=~/exercise1/work \
  ~/exercise1/merged

# 测试和验证
echo "=== 合并后的文件系统 ==="
ls -la ~/exercise1/merged/
cat ~/exercise1/merged/app.txt
cat ~/exercise1/merged/config/app.conf

# 进行修改
echo "runtime=production" >> ~/exercise1/merged/config/app.conf
echo "New runtime file" > ~/exercise1/merged/runtime.log

# 查看各层变化
echo "=== 上层变化 ==="
find ~/exercise1/upper -type f -exec echo "{}:" \; -exec cat {} \;

# 清理
sudo umount ~/exercise1/merged
rm -rf ~/exercise1
```

### 练习 2：分析 Docker 镜像结构

**目标：**深入分析一个复杂 Docker 镜像的层结构

**步骤：**

1. 选择一个多层镜像进行分析
2. 查看每层的内容和大小
3. 分析层之间的关系
4. 识别优化机会

**实现：**

```bash
#!/bin/bash
# 练习2：镜像结构分析

# 拉取复杂镜像
docker pull wordpress:latest

# 分析镜像信息
echo "=== 镜像基本信息 ==="
docker images wordpress:latest

echo "=== 镜像层历史 ==="
docker history wordpress:latest --format "table {{.CreatedBy}}\t{{.Size}}\t{{.CreatedSince}}"

echo "=== 镜像层详细信息 ==="
docker image inspect wordpress:latest | jq '.[0].RootFS.Layers[]'

# 创建容器并分析
docker run -d --name wp-analysis wordpress:latest

# 查看容器文件系统
echo "=== 容器挂载信息 ==="
docker inspect wp-analysis | jq '.[0].GraphDriver'

# 进入容器进行修改
docker exec wp-analysis sh -c 'echo "Analysis test" > /tmp/test.txt'
docker exec wp-analysis sh -c 'apt-get update > /dev/null 2>&1'

# 查看容器层变化
echo "=== 容器层变化 ==="
docker diff wp-analysis | head -20

# 清理
docker rm -f wp-analysis
```

### 练习 3：优化镜像构建

**目标：**通过多种技术优化 Docker 镜像的大小和构建速度

**步骤：**

1. 创建一个未优化的 Dockerfile
2. 应用各种优化技术
3. 比较优化前后的效果
4. 测试构建缓存效果

**实现：**

```dockerfile
# 未优化版本
cat > Dockerfile.unoptimized << 'EOF'
FROM ubuntu:20.04

RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git

COPY . /app
WORKDIR /app

RUN pip3 install flask
RUN pip3 install requests
RUN pip3 install numpy

RUN echo "#!/bin/bash" > /start.sh
RUN echo "python3 app.py" >> /start.sh
RUN chmod +x /start.sh

EXPOSE 5000
CMD ["/start.sh"]
EOF

# 优化版本
cat > Dockerfile.optimized << 'EOF'
FROM python:3.9-alpine

# 合并包安装
RUN apk add --no-cache curl wget git

# 先复制依赖文件
COPY requirements.txt /app/
WORKDIR /app

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# 再复制源代码
COPY . /app

# 使用非 root 用户
RUN adduser -D appuser
USER appuser

EXPOSE 5000
CMD ["python", "app.py"]
EOF

# 多阶段构建版本
cat > Dockerfile.multistage << 'EOF'
# 构建阶段
FROM python:3.9 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# 运行阶段
FROM python:3.9-alpine
WORKDIR /app

# 从构建阶段复制依赖
COPY --from=builder /root/.local /root/.local
COPY . .

# 确保脚本在 PATH 中
ENV PATH=/root/.local/bin:$PATH

RUN adduser -D appuser
USER appuser

EXPOSE 5000
CMD ["python", "app.py"]
EOF
```

```bash
#!/bin/bash
# 优化测试脚本

# 创建测试应用
cat > app.py << 'EOF'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from optimized container!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

cat > requirements.txt << 'EOF'
flask==2.0.1
requests==2.25.1
numpy==1.21.0
EOF

# 构建并比较
echo "=== 构建未优化版本 ==="
time docker build -f Dockerfile.unoptimized -t app:unoptimized .

echo "=== 构建优化版本 ==="
time docker build -f Dockerfile.optimized -t app:optimized .

echo "=== 构建多阶段版本 ==="
time docker build -f Dockerfile.multistage -t app:multistage .

# 比较镜像大小
echo "=== 镜像大小比较 ==="
docker images | grep "app"

# 测试缓存效果
echo "=== 测试构建缓存 ==="
time docker build -f Dockerfile.optimized -t app:optimized .

# 清理
docker rmi app:unoptimized app:optimized app:multistage
rm -f app.py requirements.txt Dockerfile.*
```

## 总结

### 关键要点

1. **Union Filesystem 是容器技术的基础**：
   - 提供高效的分层存储机制
   - 实现写时复制和层共享
   - 支持快速的容器启动和镜像分发

2. **不同存储驱动各有特点**：
   - OverlayFS：现代 Linux 的首选，性能优秀
   - AUFS：成熟稳定，但需要内核补丁
   - Device Mapper：企业级特性，配置复杂
   - Btrfs/ZFS：高级功能丰富，但资源消耗大

3. **优化策略多样化**：
   - 镜像构建优化：合并层、使用缓存、多阶段构建
   - 运行时优化：选择合适的存储驱动、监控性能
   - 存储管理：定期清理、空间监控、权限管理

### 进一步学习

- 深入研究特定存储驱动的实现细节
- 学习容器运行时的存储接口（CRI）
- 探索新兴的存储技术（如 containerd snapshotter）
- 研究大规模容器环境的存储优化策略

### 参考资源

- [Docker Storage Driver Documentation](https://docs.docker.com/storage/storagedriver/)
- [OverlayFS Documentation](https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt)
- [Container Storage Interface (CSI)](https://github.com/container-storage-interface/spec)
- [Linux Filesystem Documentation](https://www.kernel.org/doc/Documentation/filesystems/)

---

**注意：**本教程中的所有命令都应在安全的测试环境中执行，某些操作需要管理员权限，请谨慎操作。
