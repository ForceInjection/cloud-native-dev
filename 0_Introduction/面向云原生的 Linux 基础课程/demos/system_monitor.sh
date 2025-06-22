#!/bin/bash
# 系统监控脚本
# 用于第七章：Shell 脚本编程 - 实用脚本示例

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置参数
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=90
LOG_FILE="/tmp/system_monitor.log"

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# 获取系统信息
get_system_info() {
    echo -e "${BLUE}=== 系统信息 ===${NC}"
    echo "主机名: $(hostname)"
    echo "系统: $(uname -s)"
    echo "内核版本: $(uname -r)"
    echo "架构: $(uname -m)"
    echo "运行时间: $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
    echo
}

# CPU 监控
monitor_cpu() {
    echo -e "${BLUE}=== CPU 监控 ===${NC}"
    
    # macOS 和 Linux 的 CPU 使用率获取方式不同
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CPU_USAGE=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
        if [[ -z "$CPU_USAGE" ]]; then
            CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
        fi
    else
        # Linux
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
        if [[ -z "$CPU_USAGE" ]]; then
            CPU_USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
        fi
    fi
    
    # 确保 CPU_USAGE 是数字
    if ! [[ "$CPU_USAGE" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        CPU_USAGE=0
    fi
    
    printf "CPU 使用率: %.1f%%\n" "$CPU_USAGE"
    
    # 检查阈值
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        echo -e "${RED}警告: CPU 使用率过高!${NC}"
        log_message "WARNING: High CPU usage: ${CPU_USAGE}%"
    else
        echo -e "${GREEN}CPU 使用率正常${NC}"
    fi
    
    echo "CPU 核心数: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "未知")"
    echo "负载平均值: $(uptime | awk -F'load average:' '{print $2}')"
    echo
}

# 内存监控
monitor_memory() {
    echo -e "${BLUE}=== 内存监控 ===${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        MEMORY_INFO=$(vm_stat)
        TOTAL_MEM=$(sysctl -n hw.memsize)
        TOTAL_MEM_GB=$((TOTAL_MEM / 1024 / 1024 / 1024))
        
        # 简化的内存使用率计算
        FREE_PAGES=$(echo "$MEMORY_INFO" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        USED_PERCENT=$(echo "scale=1; (1 - $FREE_PAGES / 1000000) * 100" | bc -l 2>/dev/null || echo "50")
        
        echo "总内存: ${TOTAL_MEM_GB}GB"
        printf "内存使用率: %.1f%%\n" "$USED_PERCENT"
    else
        # Linux
        MEMORY_INFO=$(free -m)
        TOTAL_MEM=$(echo "$MEMORY_INFO" | awk 'NR==2{print $2}')
        USED_MEM=$(echo "$MEMORY_INFO" | awk 'NR==2{print $3}')
        USED_PERCENT=$(echo "scale=1; $USED_MEM * 100 / $TOTAL_MEM" | bc -l)
        
        echo "总内存: ${TOTAL_MEM}MB"
        echo "已用内存: ${USED_MEM}MB"
        printf "内存使用率: %.1f%%\n" "$USED_PERCENT"
    fi
    
    # 检查阈值
    if (( $(echo "$USED_PERCENT > $MEMORY_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        echo -e "${RED}警告: 内存使用率过高!${NC}"
        log_message "WARNING: High memory usage: ${USED_PERCENT}%"
    else
        echo -e "${GREEN}内存使用率正常${NC}"
    fi
    echo
}

# 磁盘监控
monitor_disk() {
    echo -e "${BLUE}=== 磁盘监控 ===${NC}"
    
    df -h | grep -E '^/dev/' | while read line; do
        USAGE=$(echo $line | awk '{print $5}' | sed 's/%//')
        MOUNT=$(echo $line | awk '{print $6}')
        SIZE=$(echo $line | awk '{print $2}')
        USED=$(echo $line | awk '{print $3}')
        AVAIL=$(echo $line | awk '{print $4}')
        
        echo "挂载点: $MOUNT"
        echo "总大小: $SIZE, 已用: $USED, 可用: $AVAIL"
        echo "使用率: ${USAGE}%"
        
        if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
            echo -e "${RED}警告: 磁盘空间不足!${NC}"
            log_message "WARNING: Low disk space on $MOUNT: ${USAGE}%"
        else
            echo -e "${GREEN}磁盘空间充足${NC}"
        fi
        echo
    done
}

# 网络监控
monitor_network() {
    echo -e "${BLUE}=== 网络监控 ===${NC}"
    
    # 检查网络连接
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo -e "${GREEN}网络连接正常${NC}"
    else
        echo -e "${RED}网络连接异常${NC}"
        log_message "WARNING: Network connectivity issue"
    fi
    
    # 显示网络接口
    echo "活动网络接口:"
    if command -v ifconfig >/dev/null 2>&1; then
        ifconfig | grep -E '^[a-z]' | awk '{print $1}'
    elif command -v ip >/dev/null 2>&1; then
        ip link show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/:$//'
    fi
    
    # 显示监听端口
    echo "监听端口 (前10个):"
    if command -v netstat >/dev/null 2>&1; then
        netstat -an | grep LISTEN | head -10
    elif command -v lsof >/dev/null 2>&1; then
        lsof -i -P | grep LISTEN | head -10
    fi
    echo
}

# 进程监控
monitor_processes() {
    echo -e "${BLUE}=== 进程监控 ===${NC}"
    
    echo "CPU 使用率最高的进程 (前5个):"
    ps aux --sort=-%cpu 2>/dev/null | head -6 || ps aux | sort -k3 -nr | head -6
    echo
    
    echo "内存使用率最高的进程 (前5个):"
    ps aux --sort=-%mem 2>/dev/null | head -6 || ps aux | sort -k4 -nr | head -6
    echo
}

# 生成报告
generate_report() {
    REPORT_FILE="/tmp/system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "系统监控报告"
        echo "生成时间: $(date)"
        echo "==========================================="
        get_system_info
        monitor_cpu
        monitor_memory
        monitor_disk
        monitor_network
        monitor_processes
    } > "$REPORT_FILE"
    
    echo -e "${GREEN}报告已生成: $REPORT_FILE${NC}"
    log_message "System report generated: $REPORT_FILE"
}

# 主函数
main() {
    echo -e "${YELLOW}=== 系统监控脚本启动 ===${NC}"
    echo "开始时间: $(date)"
    echo
    
    # 创建日志文件
    touch "$LOG_FILE"
    log_message "System monitoring started"
    
    # 检查参数
    case "${1:-monitor}" in
        "monitor")
            get_system_info
            monitor_cpu
            monitor_memory
            monitor_disk
            monitor_network
            monitor_processes
            ;;
        "report")
            generate_report
            ;;
        "cpu")
            monitor_cpu
            ;;
        "memory")
            monitor_memory
            ;;
        "disk")
            monitor_disk
            ;;
        "network")
            monitor_network
            ;;
        "help")
            echo "用法: $0 [monitor|report|cpu|memory|disk|network|help]"
            echo "  monitor  - 完整监控 (默认)"
            echo "  report   - 生成报告文件"
            echo "  cpu      - 仅监控 CPU"
            echo "  memory   - 仅监控内存"
            echo "  disk     - 仅监控磁盘"
            echo "  network  - 仅监控网络"
            echo "  help     - 显示帮助"
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 '$0 help' 查看帮助"
            exit 1
            ;;
    esac
    
    log_message "System monitoring completed"
    echo -e "${YELLOW}=== 监控完成 ===${NC}"
}

# 检查依赖
check_dependencies() {
    MISSING_DEPS=()
    
    # 检查 bc 命令（用于浮点数计算）
    if ! command -v bc >/dev/null 2>&1; then
        echo -e "${YELLOW}注意: bc 命令未安装，某些计算可能不准确${NC}"
    fi
}

# 运行脚本
check_dependencies
main "$@"