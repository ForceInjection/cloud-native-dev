#!/bin/bash
# 容器技术演示脚本
# 用于第八章：为容器技术做准备

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 演示 Linux 命名空间
demo_namespaces() {
    echo -e "${BLUE}=== Linux 命名空间演示 ===${NC}"
    echo
    
    echo "1. PID 命名空间演示"
    echo "当前进程的 PID 命名空间:"
    ls -la /proc/self/ns/pid 2>/dev/null || echo "无法访问 PID 命名空间信息"
    echo
    
    echo "2. 网络命名空间演示"
    echo "当前网络命名空间:"
    ls -la /proc/self/ns/net 2>/dev/null || echo "无法访问网络命名空间信息"
    echo
    
    echo "3. 挂载命名空间演示"
    echo "当前挂载命名空间:"
    ls -la /proc/self/ns/mnt 2>/dev/null || echo "无法访问挂载命名空间信息"
    echo
    
    echo "4. UTS 命名空间演示 (主机名隔离)"
    echo "当前主机名: $(hostname)"
    echo "UTS 命名空间:"
    ls -la /proc/self/ns/uts 2>/dev/null || echo "无法访问 UTS 命名空间信息"
    echo
    
    echo "5. 用户命名空间演示"
    echo "当前用户 ID: $(id -u)"
    echo "用户命名空间:"
    ls -la /proc/self/ns/user 2>/dev/null || echo "无法访问用户命名空间信息"
    echo
    
    echo "6. IPC 命名空间演示"
    echo "IPC 命名空间:"
    ls -la /proc/self/ns/ipc 2>/dev/null || echo "无法访问 IPC 命名空间信息"
    echo
}

# 演示控制组 (cgroups)
demo_cgroups() {
    echo -e "${BLUE}=== 控制组 (cgroups) 演示 ===${NC}"
    echo
    
    echo "1. cgroups 版本检查"
    if [ -d "/sys/fs/cgroup/unified" ] || [ -f "/sys/fs/cgroup/cgroup.controllers" ]; then
        echo "系统使用 cgroups v2"
    elif [ -d "/sys/fs/cgroup/memory" ]; then
        echo "系统使用 cgroups v1"
    else
        echo "无法确定 cgroups 版本"
    fi
    echo
    
    echo "2. 可用的 cgroup 控制器"
    if [ -f "/sys/fs/cgroup/cgroup.controllers" ]; then
        echo "cgroups v2 控制器:"
        cat /sys/fs/cgroup/cgroup.controllers 2>/dev/null || echo "无法读取控制器信息"
    elif [ -d "/sys/fs/cgroup" ]; then
        echo "cgroups v1 子系统:"
        ls /sys/fs/cgroup/ 2>/dev/null | grep -v systemd || echo "无法列出子系统"
    fi
    echo
    
    echo "3. 当前进程的 cgroup 信息"
    echo "进程 cgroup 路径:"
    cat /proc/self/cgroup 2>/dev/null | head -5 || echo "无法读取 cgroup 信息"
    echo
    
    echo "4. 内存限制演示 (概念)"
    echo "容器可以通过 cgroups 限制:"
    echo "  - 内存使用量"
    echo "  - CPU 使用率"
    echo "  - 磁盘 I/O"
    echo "  - 网络带宽"
    echo
}

# 演示联合文件系统
demo_union_filesystem() {
    echo -e "${BLUE}=== 联合文件系统演示 ===${NC}"
    echo
    
    echo "1. 创建联合文件系统演示目录"
    DEMO_DIR="/tmp/union_fs_demo"
    mkdir -p "$DEMO_DIR"/{lower,upper,work,merged}
    
    echo "目录结构:"
    echo "  lower/  - 只读层"
    echo "  upper/  - 读写层"
    echo "  work/   - 工作目录"
    echo "  merged/ - 合并视图"
    echo
    
    echo "2. 创建底层文件"
    echo "Base file content" > "$DEMO_DIR/lower/base.txt"
    echo "Shared file content" > "$DEMO_DIR/lower/shared.txt"
    echo
    
    echo "3. 创建上层文件"
    echo "Upper layer file" > "$DEMO_DIR/upper/upper.txt"
    echo "Modified shared content" > "$DEMO_DIR/upper/shared.txt"
    echo
    
    echo "4. 模拟联合文件系统效果"
    echo "底层文件 (lower/):"
    ls -la "$DEMO_DIR/lower/"
    echo
    
    echo "上层文件 (upper/):"
    ls -la "$DEMO_DIR/upper/"
    echo
    
    echo "5. 联合文件系统的特点:"
    echo "  - 多层叠加：上层覆盖下层同名文件"
    echo "  - 写时复制：修改文件时复制到上层"
    echo "  - 空间效率：共享相同的底层文件"
    echo "  - 快速启动：无需复制整个文件系统"
    echo
    
    # 清理演示目录
    rm -rf "$DEMO_DIR"
    echo "演示目录已清理"
    echo
}

# 演示容器与虚拟机的区别
demo_container_vs_vm() {
    echo -e "${BLUE}=== 容器 vs 虚拟机对比 ===${NC}"
    echo
    
    echo "1. 架构对比"
    echo "虚拟机架构:"
    echo "  应用 → 客户操作系统 → Hypervisor → 宿主操作系统 → 硬件"
    echo
    echo "容器架构:"
    echo "  应用 → 容器运行时 → 宿主操作系统 → 硬件"
    echo
    
    echo "2. 资源使用对比"
    echo "虚拟机:"
    echo "  - 需要完整的操作系统"
    echo "  - 内存开销大 (GB级别)"
    echo "  - 启动时间长 (分钟级别)"
    echo "  - 磁盘占用大"
    echo
    echo "容器:"
    echo "  - 共享宿主操作系统内核"
    echo "  - 内存开销小 (MB级别)"
    echo "  - 启动时间快 (秒级别)"
    echo "  - 磁盘占用小"
    echo
    
    echo "3. 隔离性对比"
    echo "虚拟机:"
    echo "  - 硬件级别隔离"
    echo "  - 安全性更高"
    echo "  - 完全独立的操作系统"
    echo
    echo "容器:"
    echo "  - 进程级别隔离"
    echo "  - 共享内核"
    echo "  - 轻量级隔离"
    echo
    
    echo "4. 使用场景"
    echo "虚拟机适用于:"
    echo "  - 需要不同操作系统"
    echo "  - 高安全性要求"
    echo "  - 传统应用迁移"
    echo
    echo "容器适用于:"
    echo "  - 微服务架构"
    echo "  - 快速部署"
    echo "  - 开发测试环境"
    echo "  - CI/CD 流水线"
    echo
}

# 演示 Docker 基础概念
demo_docker_concepts() {
    echo -e "${BLUE}=== Docker 基础概念演示 ===${NC}"
    echo
    
    echo "1. Docker 架构组件"
    echo "Docker Client (docker 命令):"
    echo "  - 用户与 Docker 交互的接口"
    echo "  - 发送命令到 Docker Daemon"
    echo
    
    echo "Docker Daemon (dockerd):"
    echo "  - Docker 的核心服务"
    echo "  - 管理镜像、容器、网络、存储"
    echo
    
    echo "Docker Registry:"
    echo "  - 存储和分发 Docker 镜像"
    echo "  - 默认使用 Docker Hub"
    echo
    
    echo "2. Docker 核心概念"
    echo "镜像 (Image):"
    echo "  - 只读的模板"
    echo "  - 包含应用和依赖"
    echo "  - 分层存储"
    echo
    
    echo "容器 (Container):"
    echo "  - 镜像的运行实例"
    echo "  - 可读写层"
    echo "  - 进程隔离"
    echo
    
    echo "仓库 (Repository):"
    echo "  - 存储镜像的地方"
    echo "  - 支持版本标签"
    echo "  - 公有/私有仓库"
    echo
    
    echo "3. Docker 命令示例 (概念演示)"
    echo "常用命令:"
    echo "  docker pull <image>     # 拉取镜像"
    echo "  docker run <image>      # 运行容器"
    echo "  docker ps               # 查看运行中的容器"
    echo "  docker images           # 查看本地镜像"
    echo "  docker build .          # 构建镜像"
    echo "  docker stop <container> # 停止容器"
    echo "  docker rm <container>   # 删除容器"
    echo "  docker rmi <image>      # 删除镜像"
    echo
}

# 演示 Dockerfile 概念
demo_dockerfile() {
    echo -e "${BLUE}=== Dockerfile 演示 ===${NC}"
    echo
    
    echo "1. 创建示例 Dockerfile"
    DOCKERFILE_DIR="/tmp/dockerfile_demo"
    mkdir -p "$DOCKERFILE_DIR"
    
    cat > "$DOCKERFILE_DIR/Dockerfile" << 'EOF'
# 使用官方 Python 基础镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONPATH=/app
ENV FLASK_APP=app.py

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建非 root 用户
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# 暴露端口
EXPOSE 5000

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# 启动命令
CMD ["python", "app.py"]
EOF
    
    cat > "$DOCKERFILE_DIR/requirements.txt" << 'EOF'
flask==2.3.3
requests==2.31.0
EOF
    
    cat > "$DOCKERFILE_DIR/app.py" << 'EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Docker!',
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF
    
    echo "Dockerfile 已创建: $DOCKERFILE_DIR/Dockerfile"
    echo
    
    echo "2. Dockerfile 指令说明"
    echo "FROM     - 指定基础镜像"
    echo "WORKDIR  - 设置工作目录"
    echo "ENV      - 设置环境变量"
    echo "RUN      - 执行命令并创建新层"
    echo "COPY     - 复制文件到镜像"
    echo "ADD      - 复制文件（支持 URL 和解压）"
    echo "EXPOSE   - 声明端口"
    echo "USER     - 设置运行用户"
    echo "CMD      - 容器启动时的默认命令"
    echo "ENTRYPOINT - 容器启动时的入口点"
    echo "HEALTHCHECK - 健康检查"
    echo "VOLUME   - 声明挂载点"
    echo "ARG      - 构建时参数"
    echo "LABEL    - 添加元数据"
    echo
    
    echo "3. 多阶段构建示例"
    cat > "$DOCKERFILE_DIR/Dockerfile.multistage" << 'EOF'
# 构建阶段
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# 运行阶段
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
EOF
    
    echo "多阶段构建 Dockerfile 已创建: $DOCKERFILE_DIR/Dockerfile.multistage"
    echo
    
    echo "4. 构建命令示例"
    echo "docker build -t myapp:1.0.0 ."
    echo "docker build -f Dockerfile.multistage -t myapp:latest ."
    echo "docker build --build-arg VERSION=1.0.0 -t myapp:1.0.0 ."
    echo
    
    echo "演示文件位置: $DOCKERFILE_DIR"
    echo
}

# 演示容器网络基础
demo_container_networking() {
    echo -e "${BLUE}=== 容器网络基础演示 ===${NC}"
    echo
    
    echo "1. 网络命名空间隔离"
    echo "每个容器都有独立的网络栈:"
    echo "  - 独立的网络接口"
    echo "  - 独立的路由表"
    echo "  - 独立的 iptables 规则"
    echo "  - 独立的端口空间"
    echo
    
    echo "2. Docker 网络类型"
    echo "bridge (默认):"
    echo "  - 容器连接到 docker0 网桥"
    echo "  - 容器间可以通信"
    echo "  - 需要端口映射访问外部"
    echo
    
    echo "host:"
    echo "  - 容器使用宿主机网络"
    echo "  - 性能最好"
    echo "  - 无网络隔离"
    echo
    
    echo "none:"
    echo "  - 容器无网络连接"
    echo "  - 完全隔离"
    echo "  - 需要手动配置"
    echo
    
    echo "overlay:"
    echo "  - 跨主机容器通信"
    echo "  - 用于 Docker Swarm"
    echo "  - 支持加密"
    echo
    
    echo "3. 端口映射概念"
    echo "容器端口映射到宿主机:"
    echo "  docker run -p 8080:80 nginx"
    echo "  宿主机 8080 端口 → 容器 80 端口"
    echo
    
    echo "4. 容器间通信"
    echo "同一网络内的容器可以通过:"
    echo "  - 容器名称"
    echo "  - 容器 IP 地址"
    echo "  - 服务发现机制"
    echo
}

# 演示容器存储基础
demo_container_storage() {
    echo -e "${BLUE}=== 容器存储基础演示 ===${NC}"
    echo
    
    echo "1. 容器文件系统层次"
    echo "容器文件系统由多层组成:"
    echo "  - 基础镜像层 (只读)"
    echo "  - 应用镜像层 (只读)"
    echo "  - 容器层 (读写)"
    echo
    
    echo "2. 存储驱动"
    echo "常见的存储驱动:"
    echo "  - overlay2 (推荐)"
    echo "  - aufs"
    echo "  - devicemapper"
    echo "  - btrfs"
    echo "  - zfs"
    echo
    
    echo "3. 数据持久化方式"
    echo "Volumes (卷):"
    echo "  - Docker 管理的存储"
    echo "  - 独立于容器生命周期"
    echo "  - 可以在容器间共享"
    echo
    
    echo "Bind Mounts (绑定挂载):"
    echo "  - 挂载宿主机目录"
    echo "  - 直接访问宿主机文件"
    echo "  - 性能最好"
    echo
    
    echo "tmpfs Mounts:"
    echo "  - 内存中的临时文件系统"
    echo "  - 高性能"
    echo "  - 容器停止时数据丢失"
    echo
    
    echo "4. 存储命令示例"
    echo "创建卷: docker volume create myvolume"
    echo "使用卷: docker run -v myvolume:/data nginx"
    echo "绑定挂载: docker run -v /host/path:/container/path nginx"
    echo "tmpfs 挂载: docker run --tmpfs /tmp nginx"
    echo
}

# 演示 Kubernetes 预备知识
demo_kubernetes_basics() {
    echo -e "${BLUE}=== Kubernetes 预备知识演示 ===${NC}"
    echo
    
    echo "1. 集群概念"
    echo "Kubernetes 集群组件:"
    echo "  Master 节点:"
    echo "    - API Server: 集群的入口"
    echo "    - etcd: 分布式键值存储"
    echo "    - Scheduler: 调度器"
    echo "    - Controller Manager: 控制器管理器"
    echo
    echo "  Worker 节点:"
    echo "    - kubelet: 节点代理"
    echo "    - kube-proxy: 网络代理"
    echo "    - Container Runtime: 容器运行时"
    echo
    
    echo "2. 核心对象"
    echo "Pod:"
    echo "  - 最小部署单元"
    echo "  - 包含一个或多个容器"
    echo "  - 共享网络和存储"
    echo
    
    echo "Service:"
    echo "  - 服务发现和负载均衡"
    echo "  - 稳定的网络端点"
    echo "  - 支持多种类型"
    echo
    
    echo "Deployment:"
    echo "  - 管理 Pod 的副本"
    echo "  - 滚动更新"
    echo "  - 回滚功能"
    echo
    
    echo "ConfigMap/Secret:"
    echo "  - 配置管理"
    echo "  - 敏感信息存储"
    echo "  - 与 Pod 解耦"
    echo
    
    echo "3. 网络模型"
    echo "Kubernetes 网络要求:"
    echo "  - 每个 Pod 有唯一 IP"
    echo "  - Pod 间可以直接通信"
    echo "  - 节点可以与所有 Pod 通信"
    echo "  - 无需 NAT"
    echo
    
    echo "4. 存储抽象"
    echo "PersistentVolume (PV):"
    echo "  - 集群级别的存储资源"
    echo "  - 独立于 Pod 生命周期"
    echo
    
    echo "PersistentVolumeClaim (PVC):"
    echo "  - 用户对存储的请求"
    echo "  - 绑定到 PV"
    echo
    
    echo "StorageClass:"
    echo "  - 动态存储供应"
    echo "  - 存储类型定义"
    echo
}

# 显示帮助
show_help() {
    echo "容器技术演示脚本"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  namespaces    演示 Linux 命名空间"
    echo "  cgroups       演示控制组 (cgroups)"
    echo "  unionfs       演示联合文件系统"
    echo "  comparison    演示容器与虚拟机对比"
    echo "  docker        演示 Docker 基础概念"
    echo "  dockerfile    演示 Dockerfile"
    echo "  networking    演示容器网络基础"
    echo "  storage       演示容器存储基础"
    echo "  kubernetes    演示 Kubernetes 预备知识"
    echo "  all           运行所有演示 (默认)"
    echo "  help          显示帮助信息"
    echo
}

# 主函数
main() {
    echo -e "${YELLOW}=== 容器技术基础演示 ===${NC}"
    echo "演示时间: $(date)"
    echo
    
    case "${1:-all}" in
        "namespaces")
            demo_namespaces
            ;;
        "cgroups")
            demo_cgroups
            ;;
        "unionfs")
            demo_union_filesystem
            ;;
        "comparison")
            demo_container_vs_vm
            ;;
        "docker")
            demo_docker_concepts
            ;;
        "dockerfile")
            demo_dockerfile
            ;;
        "networking")
            demo_container_networking
            ;;
        "storage")
            demo_container_storage
            ;;
        "kubernetes")
            demo_kubernetes_basics
            ;;
        "all")
            demo_namespaces
            demo_cgroups
            demo_union_filesystem
            demo_container_vs_vm
            demo_docker_concepts
            demo_dockerfile
            demo_container_networking
            demo_container_storage
            demo_kubernetes_basics
            ;;
        "help")
            show_help
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}演示完成！${NC}"
    echo
    echo "注意: 这些演示主要展示概念，实际的容器操作需要安装 Docker 等容器运行时。"
}

# 运行脚本
main "$@"