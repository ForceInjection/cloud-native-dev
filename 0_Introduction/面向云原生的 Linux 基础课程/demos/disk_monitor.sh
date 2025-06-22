#!/bin/bash

# 磁盘使用率监控脚本
# 当磁盘使用率超过80%时发出警告

USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $USAGE -gt 80 ]; then
    echo "Warning: Disk usage is ${USAGE}%" | logger -t disk_monitor
    echo "Warning: Disk usage is ${USAGE}%"
else
    echo "Disk usage is normal: ${USAGE}%"
fi

# 显示详细磁盘使用情况
echo "\nDetailed disk usage:"
df -h /

# 显示最大的目录（需要root权限）
if [ "$EUID" -eq 0 ]; then
    echo "\nLargest directories in /:"
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10
else
    echo "\nRun as root to see largest directories"
fi