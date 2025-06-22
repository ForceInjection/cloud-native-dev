#!/bin/bash

echo "=== 系统信息 ==="
echo "内核版本：$(uname -r)"
echo "CPU 信息：$(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2)"
echo "内存信息：$(free -h | grep Mem | awk '{print $2}')"

echo "\n=== CPU 性能测试 ==="
echo "正在进行 CPU 密集型计算..."
time echo "scale=5000; 4*a(1)" | bc -l > /dev/null

echo "\n=== 内存性能测试 ==="
echo "正在测试内存写入性能..."
time dd if=/dev/zero of=/tmp/test bs=1M count=1000 2>/dev/null
rm -f /tmp/test

echo "\n=== 磁盘 I/O 测试 ==="
echo "正在测试磁盘同步性能..."
time sync

echo "\n=== 网络延迟测试 ==="
echo "正在测试网络连通性..."
if command -v ping >/dev/null 2>&1; then
    ping -c 5 8.8.8.8 2>/dev/null | tail -1 || echo "网络测试失败"
else
    echo "ping 命令不可用"
fi

echo "\n=== 系统负载 ==="
echo "当前负载：$(uptime | awk -F'load average:' '{print $2}')"
echo "CPU 使用率：$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1)%"
echo "内存使用率：$(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100.0}')"

echo "\n性能测试完成！"