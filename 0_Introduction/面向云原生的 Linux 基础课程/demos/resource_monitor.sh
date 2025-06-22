#!/bin/bash

echo "=== 启动时间对比 ==="
echo "容器启动时间："
if command -v docker >/dev/null 2>&1; then
    time docker run --rm hello-world > /dev/null 2>&1
else
    echo "Docker 未安装，无法测试容器启动时间"
fi

echo "\n=== 资源占用对比 ==="
echo "宿主机资源使用："
echo "内存使用情况："
free -h
echo "\n磁盘使用情况："
df -h /

if command -v docker >/dev/null 2>&1; then
    echo "\n容器资源使用："
    # 检查是否有运行中的容器
    if [ "$(docker ps -q | wc -l)" -gt 0 ]; then
        docker stats --no-stream
    else
        echo "当前没有运行中的容器"
        # 启动一个临时容器来展示资源使用
        echo "启动临时容器进行资源监控..."
        docker run -d --name temp-monitor ubuntu:20.04 sleep 30 >/dev/null 2>&1
        sleep 2
        docker stats --no-stream temp-monitor 2>/dev/null || echo "无法获取容器统计信息"
        docker rm -f temp-monitor >/dev/null 2>&1
    fi
else
    echo "\nDocker 未安装，跳过容器资源监控"
fi

echo "\n=== 进程隔离验证 ==="
echo "宿主机进程数：$(ps aux | wc -l)"
if command -v docker >/dev/null 2>&1; then
    echo "容器中的进程数："
    container_processes=$(docker run --rm ubuntu:20.04 ps aux 2>/dev/null | wc -l)
    echo "$container_processes"
else
    echo "Docker 未安装，无法验证容器进程隔离"
fi

echo "\n=== 系统负载信息 ==="
echo "当前系统负载：$(uptime)"
echo "CPU 核心数：$(nproc)"
echo "总内存：$(free -h | awk '/^Mem:/ {print $2}')"
echo "可用内存：$(free -h | awk '/^Mem:/ {print $7}')"

echo "\n资源监控完成！"