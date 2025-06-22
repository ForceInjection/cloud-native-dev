#!/bin/bash
# 网络和安全演示脚本
# 用于第五章：网络配置和安全基础

echo "=== 网络和安全演示 ==="
echo

# 网络配置查看
echo "1. 网络配置查看"
echo "网络接口信息:"
ifconfig 2>/dev/null || ip addr show 2>/dev/null || echo "网络命令不可用"
echo

echo "路由表:"
route -n 2>/dev/null || netstat -rn 2>/dev/null || echo "路由命令不可用"
echo

# DNS 配置
echo "2. DNS 配置"
echo "DNS 配置文件内容:"
cat /etc/resolv.conf 2>/dev/null || echo "无法访问 DNS 配置文件"
echo

echo "DNS 查询测试:"
nslookup google.com 2>/dev/null || dig google.com 2>/dev/null || echo "DNS 查询工具不可用"
echo

# 网络连通性测试
echo "3. 网络连通性测试"
echo "Ping 测试 (限制 3 次):"
ping -c 3 8.8.8.8 2>/dev/null || echo "ping 命令执行失败"
echo

echo "端口连通性测试:"
nc -z google.com 80 2>/dev/null && echo "Google 80 端口可达" || echo "端口测试失败或 nc 不可用"
echo

# 防火墙状态（macOS 使用 pfctl）
echo "4. 防火墙状态"
echo "防火墙状态:"
sudo pfctl -s info 2>/dev/null || echo "需要管理员权限查看防火墙状态"
echo

# SSH 配置
echo "5. SSH 配置"
echo "SSH 客户端配置:"
ls -la ~/.ssh/ 2>/dev/null || echo "SSH 目录不存在"
echo

echo "SSH 公钥 (如果存在):"
cat ~/.ssh/id_rsa.pub 2>/dev/null || echo "SSH 公钥不存在"
echo

# 网络监控
echo "6. 网络监控"
echo "网络连接统计:"
netstat -s 2>/dev/null | head -10 || echo "netstat 不可用"
echo

echo "活动网络连接:"
lsof -i 2>/dev/null | head -10 || netstat -an 2>/dev/null | head -10 || echo "网络监控工具不可用"
echo

# 安全检查
echo "7. 安全检查"
echo "当前用户权限:"
id
echo

echo "sudo 权限检查:"
sudo -l 2>/dev/null || echo "无 sudo 权限或需要密码"
echo

echo "最近登录记录:"
last | head -5 2>/dev/null || echo "登录记录不可用"
echo

echo "演示完成"