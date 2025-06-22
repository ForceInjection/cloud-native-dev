#!/bin/bash

echo "=== 检查容器技术支持 ==="

# 检查内核版本
kernel_version=$(uname -r)
echo "🐧 内核版本：$kernel_version"

# 检查内核版本是否满足 Docker 要求
kernel_major=$(echo $kernel_version | cut -d. -f1)
kernel_minor=$(echo $kernel_version | cut -d. -f2)
if [ "$kernel_major" -gt 3 ] || ([ "$kernel_major" -eq 3 ] && [ "$kernel_minor" -ge 10 ]); then
    echo "✅ 内核版本满足 Docker 要求（需要 3.10+）"
else
    echo "❌ 内核版本过低，Docker 需要 3.10 或更高版本"
fi

# 检查系统架构
arch=$(uname -m)
echo "🏗️ 系统架构：$arch"
case $arch in
    x86_64|amd64)
        echo "✅ 支持主流容器镜像"
        ;;
    aarch64|arm64)
        echo "✅ 支持 ARM64 容器镜像"
        ;;
    armv7l|armhf)
        echo "⚠️ 支持有限的 ARM32 容器镜像"
        ;;
    *)
        echo "⚠️ 非主流架构，容器镜像支持可能有限"
        ;;
esac

# 检查必要的内核特性
echo "\n🔧 内核特性检查："
features=("namespaces" "cgroups" "overlay" "bridge" "netfilter" "iptables")

for feature in "${features[@]}"; do
    case $feature in
        "namespaces")
            if [ -d /proc/self/ns ]; then
                echo "✅ Namespaces 支持"
                echo "   可用命名空间：$(ls /proc/self/ns/ | tr '\n' ' ')"
            else
                echo "❌ Namespaces 不支持"
            fi
            ;;
        "cgroups")
            if [ -d /sys/fs/cgroup ]; then
                echo "✅ Cgroups 支持"
                # 检查 cgroups 版本
                if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
                    echo "   版本：cgroups v2"
                else
                    echo "   版本：cgroups v1"
                fi
            else
                echo "❌ Cgroups 不支持"
            fi
            ;;
        "overlay")
            if grep -q overlay /proc/filesystems 2>/dev/null; then
                echo "✅ OverlayFS 支持"
            elif modprobe overlay 2>/dev/null && grep -q overlay /proc/filesystems; then
                echo "✅ OverlayFS 支持（已加载模块）"
            else
                echo "❌ OverlayFS 不支持"
            fi
            ;;
        "bridge")
            if lsmod 2>/dev/null | grep -q bridge; then
                echo "✅ Bridge 网络支持"
            elif modprobe bridge 2>/dev/null && lsmod | grep -q bridge; then
                echo "✅ Bridge 网络支持（已加载模块）"
            else
                echo "⚠️ Bridge 网络模块未加载"
            fi
            ;;
        "netfilter")
            if lsmod 2>/dev/null | grep -q netfilter; then
                echo "✅ Netfilter 支持"
            elif [ -d /proc/sys/net/netfilter ]; then
                echo "✅ Netfilter 支持（内核内置）"
            else
                echo "⚠️ Netfilter 模块未加载"
            fi
            ;;
        "iptables")
            if command -v iptables >/dev/null 2>&1; then
                echo "✅ iptables 可用：$(iptables --version 2>/dev/null | head -1)"
            else
                echo "❌ iptables 未安装"
            fi
            ;;
    esac
done

# 检查容器运行时
echo "\n🐳 容器运行时检查："
if command -v docker &> /dev/null; then
    docker_version=$(docker --version 2>/dev/null)
    echo "✅ Docker 已安装：$docker_version"
    
    # 检查 Docker 服务状态
    if docker info >/dev/null 2>&1; then
        echo "   🟢 Docker 服务运行正常"
        echo "   存储驱动：$(docker info 2>/dev/null | grep 'Storage Driver' | cut -d: -f2 | xargs)"
    else
        echo "   🔴 Docker 服务未运行或权限不足"
        echo "   提示：尝试 'sudo systemctl start docker' 或将用户添加到 docker 组"
    fi
else
    echo "❌ Docker 未安装"
fi

if command -v podman &> /dev/null; then
    podman_version=$(podman --version 2>/dev/null)
    echo "✅ Podman 已安装：$podman_version"
    
    # 检查 Podman 功能
    if podman info >/dev/null 2>&1; then
        echo "   🟢 Podman 运行正常"
    else
        echo "   🔴 Podman 配置可能有问题"
    fi
else
    echo "❌ Podman 未安装"
fi

if command -v containerd &> /dev/null; then
    echo "✅ containerd 已安装"
else
    echo "❌ containerd 未安装"
fi

if command -v cri-o &> /dev/null; then
    echo "✅ CRI-O 已安装"
else
    echo "❌ CRI-O 未安装"
fi

# 检查 Kubernetes 工具
echo "\n☸️ Kubernetes 工具检查："
if command -v kubectl &> /dev/null; then
    kubectl_version=$(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1)
    echo "✅ kubectl 已安装：$kubectl_version"
    
    # 检查集群连接
    if kubectl cluster-info >/dev/null 2>&1; then
        echo "   🟢 已连接到 Kubernetes 集群"
        cluster_version=$(kubectl version --short 2>/dev/null | grep 'Server Version' || echo "无法获取服务器版本")
        echo "   $cluster_version"
    else
        echo "   🔴 未连接到 Kubernetes 集群"
    fi
else
    echo "❌ kubectl 未安装"
fi

if command -v minikube &> /dev/null; then
    minikube_version=$(minikube version --short 2>/dev/null || minikube version 2>/dev/null | head -1)
    echo "✅ minikube 已安装：$minikube_version"
    
    # 检查 minikube 状态
    minikube_status=$(minikube status 2>/dev/null | grep 'host:' | awk '{print $2}' || echo "Stopped")
    if [ "$minikube_status" = "Running" ]; then
        echo "   🟢 minikube 集群正在运行"
    else
        echo "   🔴 minikube 集群未运行"
        echo "   提示：使用 'minikube start' 启动本地集群"
    fi
else
    echo "❌ minikube 未安装"
fi

if command -v kind &> /dev/null; then
    echo "✅ kind 已安装：$(kind version 2>/dev/null)"
else
    echo "❌ kind 未安装"
fi

if command -v k3s &> /dev/null; then
    echo "✅ k3s 已安装"
else
    echo "❌ k3s 未安装"
fi

# 检查网络工具
echo "\n🌐 网络工具检查："
network_tools=("ip" "netstat" "ss" "ping" "curl" "wget")
for tool in "${network_tools[@]}"; do
    if command -v $tool >/dev/null 2>&1; then
        echo "✅ $tool 可用"
    else
        echo "❌ $tool 未安装"
    fi
done

# 检查存储
echo "\n💾 存储检查："
echo "可用磁盘空间："
df -h / 2>/dev/null | tail -1 | awk '{print "   根分区: " $4 " 可用 (" $5 " 已使用)"}' || echo "   无法获取磁盘信息"

# 检查 /var/lib/docker 目录（如果存在）
if [ -d /var/lib/docker ]; then
    docker_size=$(du -sh /var/lib/docker 2>/dev/null | cut -f1 || echo "未知")
    echo "   Docker 数据目录大小：$docker_size"
fi

# 检查内存
echo "\n🧠 内存检查："
total_mem=$(free -h 2>/dev/null | grep '^Mem:' | awk '{print $2}' || echo "未知")
avail_mem=$(free -h 2>/dev/null | grep '^Mem:' | awk '{print $7}' || echo "未知")
echo "   总内存：$total_mem"
echo "   可用内存：$avail_mem"

# 检查 CPU
echo "\n🖥️ CPU 检查："
cpu_cores=$(nproc 2>/dev/null || echo "未知")
echo "   CPU 核心数：$cpu_cores"
if [ -f /proc/cpuinfo ]; then
    cpu_model=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    echo "   CPU 型号：$cpu_model"
fi

# 安全检查
echo "\n🔒 安全特性检查："
if [ -f /proc/sys/kernel/unprivileged_userns_clone ]; then
    userns_status=$(cat /proc/sys/kernel/unprivileged_userns_clone)
    if [ "$userns_status" = "1" ]; then
        echo "✅ 用户命名空间支持（无特权容器）"
    else
        echo "⚠️ 用户命名空间被禁用"
    fi
fi

if command -v apparmor_status >/dev/null 2>&1; then
    echo "✅ AppArmor 可用"
elif [ -d /sys/kernel/security/apparmor ]; then
    echo "✅ AppArmor 支持"
else
    echo "❌ AppArmor 不可用"
fi

if command -v getenforce >/dev/null 2>&1; then
    selinux_status=$(getenforce 2>/dev/null)
    echo "✅ SELinux 状态：$selinux_status"
else
    echo "❌ SELinux 不可用"
fi

echo "\n=== 总结和建议 ==="
echo "\n📋 系统容器支持评估："

# 基础支持评分
score=0
[ -d /proc/self/ns ] && score=$((score + 1))
[ -d /sys/fs/cgroup ] && score=$((score + 1))
grep -q overlay /proc/filesystems 2>/dev/null && score=$((score + 1))
command -v docker >/dev/null 2>&1 && score=$((score + 2))
command -v kubectl >/dev/null 2>&1 && score=$((score + 1))

if [ $score -ge 5 ]; then
    echo "🟢 优秀：系统完全支持容器技术"
elif [ $score -ge 3 ]; then
    echo "🟡 良好：系统基本支持容器技术，建议安装缺失组件"
else
    echo "🔴 需要改进：系统对容器技术支持有限"
fi

echo "\n💡 学习建议："
if ! command -v docker >/dev/null 2>&1 && ! command -v podman >/dev/null 2>&1; then
    echo "  1. 🐳 安装容器运行时（Docker 或 Podman）"
    echo "     - Docker: https://docs.docker.com/get-docker/"
    echo "     - Podman: https://podman.io/getting-started/installation"
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "  2. ☸️ 安装 kubectl"
    echo "     - https://kubernetes.io/docs/tasks/tools/install-kubectl/"
fi

if ! command -v minikube >/dev/null 2>&1; then
    echo "  3. 🎯 安装本地 Kubernetes 环境"
    echo "     - minikube: https://minikube.sigs.k8s.io/docs/start/"
    echo "     - kind: https://kind.sigs.k8s.io/docs/user/quick-start/"
    echo "     - k3s: https://k3s.io/"
fi

echo "  4. 📚 学习路径建议："
echo "     a. 容器基础概念和 Docker 命令"
echo "     b. 容器镜像构建和管理"
echo "     c. 容器网络和存储"
echo "     d. Kubernetes 基础概念"
echo "     e. Pod、Service、Deployment 等资源"
echo "     f. 实际项目实践"

echo "\n🔧 故障排除提示："
echo "  - 如果 Docker 权限不足：sudo usermod -aG docker \$USER"
echo "  - 如果内核模块缺失：检查发行版的内核配置"
echo "  - 如果网络问题：检查防火墙和 iptables 规则"
echo "  - 如果存储空间不足：清理不需要的镜像和容器"

echo "\n✅ 容器支持检查完成！"
echo "\n📞 获取帮助："
echo "  - Docker 文档：https://docs.docker.com/"
echo "  - Kubernetes 文档：https://kubernetes.io/docs/"
echo "  - 社区论坛：https://discuss.kubernetes.io/"
echo "  - GitHub Issues：相关项目的 GitHub 仓库"