#!/bin/bash

# Docker 镜像层管理演示脚本
# 模拟 Docker 镜像的分层结构和管理

echo "=== Docker 镜像层概念演示 ==="

# 创建基础镜像层
echo "创建模拟的 Docker 镜像层结构..."
mkdir -p docker-layers/{ubuntu-base,app-layer,config-layer,runtime-layer}

# Ubuntu 基础层（模拟）
echo "创建 Ubuntu 基础层..."
echo "Ubuntu 20.04 LTS" > docker-layers/ubuntu-base/os-release
echo "apt package manager" > docker-layers/ubuntu-base/package-manager
echo "Basic system libraries" > docker-layers/ubuntu-base/lib-info
echo "glibc-2.31" > docker-layers/ubuntu-base/libc-version
echo "bash-5.0" > docker-layers/ubuntu-base/shell

# 应用层
echo "创建应用层..."
echo "Node.js v16.14.0" > docker-layers/app-layer/nodejs
echo "npm packages installed" > docker-layers/app-layer/node_modules
echo "console.log('Hello from containerized app!')" > docker-layers/app-layer/app.js
echo "express@4.18.0" > docker-layers/app-layer/dependencies

# 配置层
echo "创建配置层..."
echo "Production configuration" > docker-layers/config-layer/app.conf
echo "NODE_ENV=production\nPORT=3000" > docker-layers/config-layer/env.conf
echo "log_level=info" > docker-layers/config-layer/logging.conf

# 运行时层（可写层）
echo "创建运行时层..."
echo "[$(date)] Application started" > docker-layers/runtime-layer/app.log
echo "temporary session data" > docker-layers/runtime-layer/temp.data
echo "user uploads" > docker-layers/runtime-layer/uploads

# 显示层次结构
echo "\n=== 镜像层次结构 ==="
echo "镜像层从下到上的堆叠顺序："
echo "┌─────────────────────────────────┐"
echo "│ Runtime Layer (可写层)           │ ← 容器运行时产生的数据"
echo "├─────────────────────────────────┤"
echo "│ Config Layer (只读)             │ ← 应用配置文件"
echo "├─────────────────────────────────┤"
echo "│ App Layer (只读)                │ ← 应用程序和依赖"
echo "├─────────────────────────────────┤"
echo "│ Ubuntu Base Layer (只读)        │ ← 操作系统基础"
echo "└─────────────────────────────────┘"

echo "\n各层详细内容："
echo "\n📁 Runtime Layer (可写):"
ls -la docker-layers/runtime-layer/ | tail -n +2 | awk '{print "  " $9 " (" $5 " bytes)"}'

echo "\n📁 Config Layer (只读):"
ls -la docker-layers/config-layer/ | tail -n +2 | awk '{print "  " $9 " (" $5 " bytes)"}'

echo "\n📁 App Layer (只读):"
ls -la docker-layers/app-layer/ | tail -n +2 | awk '{print "  " $9 " (" $5 " bytes)"}'

echo "\n📁 Ubuntu Base Layer (只读):"
ls -la docker-layers/ubuntu-base/ | tail -n +2 | awk '{print "  " $9 " (" $5 " bytes)"}'

# 计算层大小（模拟）
echo "\n=== 层大小信息 ==="
echo "📊 各层大小（模拟真实 Docker 镜像）："
echo "  Ubuntu Base Layer: 72.8 MB  (操作系统基础)"
echo "  App Layer:         45.2 MB  (Node.js + 应用代码)"
echo "  Config Layer:      1.2 KB   (配置文件)"
echo "  Runtime Layer:     变化中... (运行时数据)"
echo "  ────────────────────────────"
echo "  总镜像大小:        ~118 MB"

echo "\n=== 层共享优势演示 ==="
echo "🔄 多个容器共享相同的只读层："
echo ""
echo "Container 1: [Runtime1] + [Config] + [App] + [Ubuntu Base]"
echo "Container 2: [Runtime2] + [Config] + [App] + [Ubuntu Base]"
echo "Container 3: [Runtime3] + [Config] + [App] + [Ubuntu Base]"
echo ""
echo "💾 存储优化："
echo "  - 不共享: 3 × 118MB = 354MB"
echo "  - 共享层: 3 × 1MB(Runtime) + 117MB(共享层) = 120MB"
echo "  - 节省空间: 234MB (66%)"

echo "\n=== 层修改演示 ==="
echo "📝 模拟容器运行时的文件修改："

# 模拟文件修改
echo "[$(date)] User logged in" >> docker-layers/runtime-layer/app.log
echo "new user session" > docker-layers/runtime-layer/session-$(date +%s)

echo "  ✅ 在运行时层添加了新的日志和会话文件"
echo "  ✅ 只读层保持不变，确保镜像一致性"

echo "\n📋 当前运行时层内容："
ls -la docker-layers/runtime-layer/

echo "\n=== Copy-on-Write 演示 ==="
echo "📄 模拟修改只读层中的文件："
echo "  原始配置: $(cat docker-layers/config-layer/app.conf)"
echo "  容器中修改配置文件..."

# 模拟 Copy-on-Write
cp docker-layers/config-layer/app.conf docker-layers/runtime-layer/app.conf.modified
echo "Development configuration (modified in container)" > docker-layers/runtime-layer/app.conf.modified

echo "  ✅ 文件被复制到运行时层并修改"
echo "  ✅ 原始配置层保持不变"
echo "  修改后配置: $(cat docker-layers/runtime-layer/app.conf.modified)"

echo "\n=== 实际 Docker 命令对比 ==="
echo "🐳 相关的 Docker 命令："
echo "  docker images          # 查看镜像"
echo "  docker history <image> # 查看镜像层历史"
echo "  docker inspect <image> # 查看镜像详细信息"
echo "  docker system df       # 查看存储使用情况"
echo "  docker image prune     # 清理未使用的镜像层"

# 清理函数
cleanup() {
    echo "\n🧹 清理演示文件..."
    rm -rf docker-layers
    echo "✅ 清理完成！"
}

# 询问是否清理
echo "\n❓ 是否清理演示文件？(y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    cleanup
else
    echo "📁 演示文件保留在 docker-layers/ 目录中"
    echo "💡 你可以继续探索各层的内容"
fi

echo "\n🎯 关键要点："
echo "  1. 镜像层是只读的，容器层是可写的"
echo "  2. 多个容器可以共享相同的镜像层"
echo "  3. Copy-on-Write 机制优化存储和性能"
echo "  4. 分层结构便于镜像的构建和分发"