#!/bin/bash
# 进程管理演示脚本
# 用于第四章：进程和系统管理

echo "=== 进程管理演示 ==="
echo

# 查看进程
echo "1. 查看进程"
echo "当前用户的进程 (ps):"
ps aux | head -10
echo

echo "进程树 (pstree 或 ps):"
ps -ef | head -10
echo

# 后台进程演示
echo "2. 后台进程演示"
echo "启动后台进程..."
sleep 30 &
BG_PID=$!
echo "后台进程 PID: $BG_PID"
echo

echo "查看后台任务:"
jobs
echo

echo "查看特定进程:"
ps -p $BG_PID
echo

# 进程控制
echo "3. 进程控制"
echo "终止后台进程..."
kill $BG_PID
sleep 1
echo "检查进程是否已终止:"
ps -p $BG_PID 2>/dev/null || echo "进程已终止"
echo

# 系统资源监控
echo "4. 系统资源监控"
echo "内存使用情况:"
free -h 2>/dev/null || echo "free 命令不可用，使用 vm_stat:"
vm_stat | head -5
echo

echo "磁盘使用情况:"
df -h | head -5
echo

echo "系统负载:"
uptime
echo

# 网络连接
echo "5. 网络连接"
echo "网络连接状态:"
netstat -an | head -10 2>/dev/null || echo "netstat 不可用，使用 lsof:"
lsof -i | head -5 2>/dev/null || echo "网络工具不可用"
echo

# 系统信息
echo "6. 系统信息"
echo "系统信息:"
uname -a
echo

echo "当前登录用户:"
who
echo

echo "系统运行时间:"
uptime
echo

echo "演示完成"