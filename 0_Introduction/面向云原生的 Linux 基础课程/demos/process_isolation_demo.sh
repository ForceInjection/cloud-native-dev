#!/bin/bash

echo "=== 进程隔离机制演示 ==="

# 显示当前进程树
echo "宿主机进程树（部分）："
if command -v pstree >/dev/null; then
    pstree -p $$ | head -10
else
    echo "pstree 命令不可用，显示进程列表："
    ps -ef | head -10
fi

echo "\n当前进程的命名空间："
ls -la /proc/self/ns/ 2>/dev/null || echo "无法访问 /proc/self/ns/，可能需要 Linux 系统"

# 创建隔离的进程环境
echo "\n=== 创建隔离环境 ==="

# 方法1：使用 unshare 创建新的命名空间
if command -v unshare >/dev/null; then
    echo "✅ unshare 命令可用，可以创建命名空间隔离："
    echo "  sudo unshare --pid --fork --mount-proc bash"
    echo "  # 在新命名空间中，进程 ID 将从 1 开始"
    echo "  # ps aux 将只显示命名空间内的进程"
    
    echo "\n演示命名空间类型："
    echo "  --pid     : 进程 ID 命名空间"
    echo "  --net     : 网络命名空间"
    echo "  --mount   : 挂载命名空间"
    echo "  --uts     : 主机名命名空间"
    echo "  --ipc     : 进程间通信命名空间"
    echo "  --user    : 用户命名空间"
else
    echo "❌ unshare 命令不可用（需要 Linux 系统）"
fi

# 方法2：演示进程可见性
echo "\n=== 进程可见性测试 ==="

# 启动一个后台进程
echo "启动测试进程..."
sleep 300 &
SLEEP_PID=$!
echo "启动后台进程 sleep，PID: $SLEEP_PID"

# 在宿主机查看进程
echo "\n宿主机可以看到的进程："
ps aux | grep sleep | grep -v grep || echo "未找到 sleep 进程"

# 模拟容器内的进程视图
echo "\n📦 容器内的进程视图（模拟）："
echo "在容器的 PID 命名空间中，只能看到："
echo "  PID 1: /bin/bash     (容器主进程)"
echo "  PID 2: sleep 300     (应用进程)"
echo "  PID 3: ps aux        (临时进程)"
echo "\n🔒 隔离效果："
echo "  - 容器内看不到宿主机的其他进程"
echo "  - 容器内的 PID 1 是容器的主进程"
echo "  - 进程树完全隔离"

# 清理测试进程
kill $SLEEP_PID 2>/dev/null
echo "\n清理测试进程完成"

echo "\n=== 资源限制演示 ==="

# CPU 限制演示
echo "💻 CPU 限制（通过 cgroups）："
echo "  - 限制 CPU 使用率：50%"
echo "  - 限制 CPU 核心：0-1"
echo "  - 设置 CPU 权重：512"
echo "  - CPU 配额：50000/100000 (50%)"

# 内存限制演示
echo "\n🧠 内存限制（通过 cgroups）："
echo "  - 限制内存使用：512MB"
echo "  - 限制交换空间：1GB"
echo "  - OOM 杀死策略：优先级设置"
echo "  - 内存软限制：256MB"

# I/O 限制演示
echo "\n💾 I/O 限制（通过 cgroups）："
echo "  - 限制读取速度：100MB/s"
echo "  - 限制写入速度：50MB/s"
echo "  - 限制 IOPS：1000"
echo "  - 磁盘配额：10GB"

echo "\n=== 安全隔离 ==="
echo "👤 用户命名空间："
echo "  - 容器内 root 用户映射到宿主机普通用户"
echo "  - 限制特权操作"
echo "  - 防止权限提升攻击"
echo "  - UID/GID 映射：0->1000"

echo "\n🔐 能力（Capabilities）限制："
echo "  - 移除不必要的内核能力"
echo "  - 限制系统调用"
echo "  - 使用 seccomp 过滤器"
echo "  - AppArmor/SELinux 强制访问控制"

echo "\n🛡️ 默认移除的危险能力："
echo "  - CAP_SYS_ADMIN    (系统管理)"
echo "  - CAP_NET_ADMIN    (网络管理)"
echo "  - CAP_SYS_MODULE   (内核模块)"
echo "  - CAP_SYS_TIME     (系统时间)"

echo "\n=== 命名空间详解 ==="
echo "📋 Linux 命名空间类型："
echo "\n1. PID 命名空间："
echo "   - 隔离进程 ID 空间"
echo "   - 容器内 PID 从 1 开始"
echo "   - 进程树完全隔离"

echo "\n2. Network 命名空间："
echo "   - 隔离网络接口、路由表、防火墙规则"
echo "   - 每个容器有独立的网络栈"
echo "   - 通过 veth pair 连接"

echo "\n3. Mount 命名空间："
echo "   - 隔离文件系统挂载点"
echo "   - 容器有独立的文件系统视图"
echo "   - 支持 bind mount 和 volume"

echo "\n4. UTS 命名空间："
echo "   - 隔离主机名和域名"
echo "   - 每个容器可以有独立的主机名"

echo "\n5. IPC 命名空间："
echo "   - 隔离进程间通信资源"
echo "   - 信号量、消息队列、共享内存"

echo "\n6. User 命名空间："
echo "   - 隔离用户和组 ID"
echo "   - 支持 UID/GID 映射"
echo "   - 增强安全性"

echo "\n=== 实际容器对比 ==="
if command -v docker >/dev/null 2>&1; then
    echo "🐳 Docker 容器进程隔离验证："
    echo "\n宿主机进程数：$(ps aux | wc -l)"
    
    echo "\n启动测试容器..."
    container_id=$(docker run -d ubuntu:20.04 sleep 60 2>/dev/null)
    if [ $? -eq 0 ]; then
        sleep 2
        echo "容器内进程数："
        docker exec $container_id ps aux | wc -l
        
        echo "\n容器内进程列表："
        docker exec $container_id ps aux
        
        echo "\n清理测试容器..."
        docker rm -f $container_id >/dev/null 2>&1
    else
        echo "无法启动测试容器"
    fi
else
    echo "🐳 Docker 未安装，无法进行实际容器测试"
fi

echo "\n=== 总结 ==="
echo "🎯 进程隔离的关键技术："
echo "  1. Linux Namespaces - 提供隔离环境"
echo "  2. Cgroups - 限制资源使用"
echo "  3. Capabilities - 限制特权操作"
echo "  4. Seccomp - 过滤系统调用"
echo "  5. AppArmor/SELinux - 强制访问控制"

echo "\n💡 容器 vs 虚拟机："
echo "  容器：共享内核，轻量级隔离"
echo "  虚拟机：完全隔离，包含完整操作系统"
echo "  容器启动更快，资源占用更少"

echo "\n✅ 进程隔离演示完成！"