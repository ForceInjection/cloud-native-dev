#!/bin/bash

echo "=== Kubernetes 存储概念 ==="

echo "存储类型："
echo "├── Volume（卷）"
echo "│   ├── emptyDir      # 临时存储，Pod 删除时数据丢失"
echo "│   ├── hostPath      # 挂载宿主机路径"
echo "│   ├── configMap     # 配置文件存储"
echo "│   ├── secret        # 敏感信息存储"
echo "│   └── downwardAPI   # Pod 元数据存储"
echo "├── PersistentVolume (PV)   # 持久化存储资源"
echo "├── PersistentVolumeClaim (PVC)  # 存储请求"
echo "└── StorageClass     # 存储类，定义存储类型"

echo "\n=== 存储生命周期 ==="
echo "1. 供应（Provisioning）："
echo "   - 静态供应：管理员预先创建 PV"
echo "   - 动态供应：根据 PVC 自动创建 PV"

echo "\n2. 绑定（Binding）："
echo "   - PVC 与合适的 PV 进行绑定"
echo "   - 一对一的绑定关系"

echo "\n3. 使用（Using）："
echo "   - Pod 通过 PVC 使用存储"
echo "   - 支持多种访问模式"

echo "\n4. 回收（Reclaiming）："
echo "   - Retain：保留数据，手动回收"
echo "   - Delete：自动删除存储资源"
echo "   - Recycle：清理数据后重新使用（已废弃）"

echo "\n=== 访问模式 ==="
echo "ReadWriteOnce (RWO)：单节点读写"
echo "ReadOnlyMany (ROX)：多节点只读"
echo "ReadWriteMany (RWX)：多节点读写"

echo "\n=== 存储示例 ==="
echo "Web 应用存储需求："
echo "├── 应用代码：只读，可以使用 ConfigMap"
echo "├── 日志文件：读写，使用 emptyDir 或 PV"
echo "├── 数据库数据：持久化，使用 PV"
echo "├── 配置文件：只读，使用 ConfigMap"
echo "└── 密钥信息：只读，使用 Secret"