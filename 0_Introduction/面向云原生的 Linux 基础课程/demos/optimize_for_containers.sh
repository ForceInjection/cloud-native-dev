#!/bin/bash

# 容器环境内核参数优化脚本
# 注意：需要 root 权限

if [ "$EUID" -ne 0 ]; then
    echo "请使用 root 权限运行此脚本"
    echo "使用方法: sudo $0"
    exit 1
fi

echo "优化容器环境内核参数..."

# 备份原始配置
cp /etc/sysctl.conf /etc/sysctl.conf.backup.$(date +%Y%m%d_%H%M%S)
echo "已备份原始 sysctl.conf"

# 网络优化
echo "\n# 容器网络优化" >> /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf

# 内存优化
echo "\n# 容器内存优化" >> /etc/sysctl.conf
echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
echo "vm.swappiness = 10" >> /etc/sysctl.conf
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf

# 文件系统优化
echo "\n# 容器文件系统优化" >> /etc/sysctl.conf
echo "fs.file-max = 1048576" >> /etc/sysctl.conf
echo "fs.inotify.max_user_instances = 8192" >> /etc/sysctl.conf
echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf

# 网络连接优化
echo "\n# 网络连接优化" >> /etc/sysctl.conf
echo "net.core.somaxconn = 32768" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf

# 应用设置
echo "\n应用新的内核参数..."
sysctl -p

echo "\n=== 优化完成 ==="
echo "内核参数优化完成！"
echo "当前关键参数值："
echo "  IP转发: $(sysctl -n net.ipv4.ip_forward)"
echo "  最大文件数: $(sysctl -n fs.file-max)"
echo "  内存过量分配: $(sysctl -n vm.overcommit_memory)"
echo "  交换倾向: $(sysctl -n vm.swappiness)"
echo "\n建议重启系统以确保所有设置生效。"
echo "如需恢复原始设置，请使用备份文件: /etc/sysctl.conf.backup.*"