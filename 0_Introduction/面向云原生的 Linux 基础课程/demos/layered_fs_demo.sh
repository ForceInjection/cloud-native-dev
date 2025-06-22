#!/bin/bash

# 分层文件系统演示脚本
# 模拟容器镜像的分层结构

echo "=== 分层文件系统演示 ==="

# 创建演示目录结构
mkdir -p layered-fs-demo/{base,layer1,layer2,final}
echo "创建分层目录结构..."

# 基础层
echo "创建基础层..."
echo "Base system files" > layered-fs-demo/base/system.conf
echo "#!/bin/bash\necho 'Base application'" > layered-fs-demo/base/app.sh
chmod +x layered-fs-demo/base/app.sh
echo "version=1.0" > layered-fs-demo/base/version.txt

# 第一层：添加配置
echo "创建第一层（配置层）..."
echo "Updated configuration" > layered-fs-demo/layer1/system.conf
echo "Additional config" > layered-fs-demo/layer1/extra.conf
echo "middleware=enabled" > layered-fs-demo/layer1/middleware.conf

# 第二层：添加应用更新
echo "创建第二层（应用更新层）..."
echo "#!/bin/bash\necho 'Updated application v2.0'" > layered-fs-demo/layer2/app.sh
chmod +x layered-fs-demo/layer2/app.sh
echo "New feature config" > layered-fs-demo/layer2/feature.conf
echo "version=2.0" > layered-fs-demo/layer2/version.txt

# 显示各层内容
echo "\n=== 各层内容展示 ==="
echo "基础层内容："
ls -la layered-fs-demo/base/
echo "  system.conf: $(cat layered-fs-demo/base/system.conf)"
echo "  version: $(cat layered-fs-demo/base/version.txt)"

echo "\n第一层内容："
ls -la layered-fs-demo/layer1/
echo "  system.conf: $(cat layered-fs-demo/layer1/system.conf)"
echo "  extra.conf: $(cat layered-fs-demo/layer1/extra.conf)"

echo "\n第二层内容："
ls -la layered-fs-demo/layer2/
echo "  version: $(cat layered-fs-demo/layer2/version.txt)"
echo "  feature.conf: $(cat layered-fs-demo/layer2/feature.conf)"

# 模拟容器镜像层合并
echo "\n=== 模拟容器镜像层合并 ==="

# 检查是否可以使用 OverlayFS
if [ "$EUID" -eq 0 ] && grep -q overlay /proc/filesystems; then
    echo "使用 OverlayFS 进行真实层合并..."
    mkdir -p /tmp/work-layered /tmp/merged-layers
    mount -t overlay overlay \
        -o lowerdir=layered-fs-demo/layer2:layered-fs-demo/layer1:layered-fs-demo/base,upperdir=layered-fs-demo/final,workdir=/tmp/work-layered \
        /tmp/merged-layers 2>/dev/null && echo "OverlayFS 挂载成功" || echo "OverlayFS 挂载失败，使用手动合并"
else
    echo "使用手动合并模拟层合并（需要 root 权限才能使用 OverlayFS）..."
fi

# 手动合并演示（按层次顺序，后面的层覆盖前面的层）
echo "执行手动层合并..."
cp -r layered-fs-demo/base/* layered-fs-demo/final/ 2>/dev/null || true
cp -r layered-fs-demo/layer1/* layered-fs-demo/final/ 2>/dev/null || true
cp -r layered-fs-demo/layer2/* layered-fs-demo/final/ 2>/dev/null || true

echo "\n=== 合并结果 ==="
echo "合并后的最终层："
ls -la layered-fs-demo/final/

echo "\n最终应用版本："
layered-fs-demo/final/app.sh

echo "\n最终配置文件："
echo "  system.conf: $(cat layered-fs-demo/final/system.conf)"
echo "  version: $(cat layered-fs-demo/final/version.txt)"
echo "  feature.conf: $(cat layered-fs-demo/final/feature.conf)"
echo "  extra.conf: $(cat layered-fs-demo/final/extra.conf)"

echo "\n=== 层覆盖演示 ==="
echo "注意：layer2 的 system.conf 和 version.txt 覆盖了之前层的同名文件"
echo "这就是容器镜像分层的工作原理！"

# 清理函数
cleanup() {
    echo "\n清理演示文件..."
    # 如果使用了 OverlayFS，先卸载
    umount /tmp/merged-layers 2>/dev/null || true
    rm -rf layered-fs-demo /tmp/work-layered /tmp/merged-layers
    echo "清理完成！"
}

# 询问是否清理
echo "\n是否清理演示文件？(y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    cleanup
else
    echo "演示文件保留在 layered-fs-demo/ 目录中"
fi