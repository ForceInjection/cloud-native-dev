#!/bin/bash
# Web 服务器日志分析脚本
# 用于第七章：Shell 脚本编程 - 实用脚本示例

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_LOG_FILE="/tmp/sample_access.log"
OUTPUT_DIR="/tmp/log_analysis"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建示例日志文件
create_sample_log() {
    echo -e "${BLUE}创建示例日志文件...${NC}"
    
    cat > "$DEFAULT_LOG_FILE" << 'EOF'
192.168.1.100 - - [10/Oct/2023:13:55:36 +0000] "GET /index.html HTTP/1.1" 200 2326 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
10.0.0.50 - - [10/Oct/2023:13:55:37 +0000] "GET /about.html HTTP/1.1" 200 1024 "http://example.com/" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
203.0.113.45 - - [10/Oct/2023:13:55:38 +0000] "POST /login HTTP/1.1" 302 0 "http://example.com/login" "Mozilla/5.0 (X11; Linux x86_64)"
192.168.1.100 - - [10/Oct/2023:13:55:39 +0000] "GET /dashboard HTTP/1.1" 200 5432 "http://example.com/login" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
198.51.100.25 - - [10/Oct/2023:13:55:40 +0000] "GET /api/users HTTP/1.1" 200 1234 "-" "curl/7.68.0"
203.0.113.45 - - [10/Oct/2023:13:55:41 +0000] "GET /profile HTTP/1.1" 200 2048 "http://example.com/dashboard" "Mozilla/5.0 (X11; Linux x86_64)"
192.168.1.101 - - [10/Oct/2023:13:55:42 +0000] "GET /nonexistent HTTP/1.1" 404 162 "-" "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X)"
10.0.0.50 - - [10/Oct/2023:13:55:43 +0000] "GET /images/logo.png HTTP/1.1" 200 15678 "http://example.com/index.html" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
203.0.113.45 - - [10/Oct/2023:13:55:44 +0000] "POST /api/data HTTP/1.1" 500 0 "http://example.com/dashboard" "Mozilla/5.0 (X11; Linux x86_64)"
192.168.1.100 - - [10/Oct/2023:13:55:45 +0000] "GET /logout HTTP/1.1" 302 0 "http://example.com/dashboard" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
198.51.100.25 - - [10/Oct/2023:13:55:46 +0000] "GET /api/status HTTP/1.1" 200 89 "-" "curl/7.68.0"
192.168.1.102 - - [10/Oct/2023:13:55:47 +0000] "GET /admin HTTP/1.1" 403 162 "-" "Mozilla/5.0 (compatible; Googlebot/2.1)"
10.0.0.51 - - [10/Oct/2023:13:55:48 +0000] "GET /contact HTTP/1.1" 200 1567 "http://example.com/about.html" "Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X)"
203.0.113.45 - - [10/Oct/2023:13:55:49 +0000] "GET /search?q=linux HTTP/1.1" 200 3456 "http://example.com/" "Mozilla/5.0 (X11; Linux x86_64)"
192.168.1.100 - - [10/Oct/2023:13:55:50 +0000] "GET /index.html HTTP/1.1" 200 2326 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
EOF
    
    echo -e "${GREEN}示例日志文件已创建: $DEFAULT_LOG_FILE${NC}"
    echo
}

# 基本统计信息
basic_stats() {
    local log_file="$1"
    echo -e "${BLUE}=== 基本统计信息 ===${NC}"
    
    echo "总请求数: $(wc -l < "$log_file")"
    echo "唯一IP数: $(awk '{print $1}' "$log_file" | sort -u | wc -l)"
    echo "日志时间范围:"
    echo "  开始: $(head -1 "$log_file" | awk '{print $4 " " $5}' | tr -d '[]')"
    echo "  结束: $(tail -1 "$log_file" | awk '{print $4 " " $5}' | tr -d '[]')"
    echo
}

# 状态码分析
status_code_analysis() {
    local log_file="$1"
    echo -e "${BLUE}=== HTTP 状态码分析 ===${NC}"
    
    echo "状态码统计:"
    awk '{print $9}' "$log_file" | sort | uniq -c | sort -nr | while read count code; do
        case $code in
            200) echo -e "  ${GREEN}$code (成功): $count${NC}" ;;
            302) echo -e "  ${YELLOW}$code (重定向): $count${NC}" ;;
            404) echo -e "  ${RED}$code (未找到): $count${NC}" ;;
            403) echo -e "  ${RED}$code (禁止访问): $count${NC}" ;;
            500) echo -e "  ${RED}$code (服务器错误): $count${NC}" ;;
            *) echo "  $code: $count" ;;
        esac
    done
    echo
    
    # 错误请求详情
    echo "错误请求详情 (4xx, 5xx):"
    awk '$9 >= 400 {print $1, $7, $9}' "$log_file" | while read ip url code; do
        echo -e "  ${RED}$code${NC} - $ip - $url"
    done
    echo
}

# IP 地址分析
ip_analysis() {
    local log_file="$1"
    echo -e "${BLUE}=== IP 地址分析 ===${NC}"
    
    echo "访问量最高的IP地址 (Top 10):"
    awk '{print $1}' "$log_file" | sort | uniq -c | sort -nr | head -10 | while read count ip; do
        echo "  $ip: $count 次访问"
    done
    echo
    
    # 可疑IP检测（访问量异常高的IP）
    local avg_requests=$(awk '{print $1}' "$log_file" | sort | uniq -c | awk '{sum+=$1} END {print int(sum/NR)}')
    local threshold=$((avg_requests * 3))
    
    echo "可疑IP地址 (访问量超过平均值3倍: $threshold):"
    awk '{print $1}' "$log_file" | sort | uniq -c | sort -nr | while read count ip; do
        if [ "$count" -gt "$threshold" ]; then
            echo -e "  ${RED}$ip: $count 次访问 (可疑)${NC}"
        fi
    done
    echo
}

# URL 访问分析
url_analysis() {
    local log_file="$1"
    echo -e "${BLUE}=== URL 访问分析 ===${NC}"
    
    echo "最受欢迎的页面 (Top 10):"
    awk '{print $7}' "$log_file" | sort | uniq -c | sort -nr | head -10 | while read count url; do
        echo "  $url: $count 次访问"
    done
    echo
    
    echo "HTTP 方法统计:"
    awk '{print $6}' "$log_file" | tr -d '"' | sort | uniq -c | sort -nr | while read count method; do
        echo "  $method: $count 次"
    done
    echo
    
    echo "文件类型访问统计:"
    awk '{print $7}' "$log_file" | grep -o '\.[a-zA-Z0-9]*$' | sort | uniq -c | sort -nr | head -10 | while read count ext; do
        echo "  $ext: $count 次"
    done
    echo
}

# 用户代理分析
user_agent_analysis() {
    local log_file="$1"
    echo -e "${BLUE}=== 用户代理分析 ===${NC}"
    
    echo "浏览器类型统计:"
    awk -F'"' '{print $6}' "$log_file" | grep -o 'Mozilla\|Chrome\|Safari\|Firefox\|curl\|Googlebot' | sort | uniq -c | sort -nr | while read count browser; do
        echo "  $browser: $count 次"
    done
    echo
    
    echo "操作系统统计:"
    awk -F'"' '{print $6}' "$log_file" | grep -o 'Windows\|Macintosh\|Linux\|iPhone\|iPad\|Android' | sort | uniq -c | sort -nr | while read count os; do
        echo "  $os: $count 次"
    done
    echo
}

# 流量分析
traffic_analysis() {
    local log_file="$1"
    echo -e "${BLUE}=== 流量分析 ===${NC}"
    
    # 计算总流量
    local total_bytes=$(awk '{sum+=$10} END {print sum}' "$log_file")
    local total_mb=$((total_bytes / 1024 / 1024))
    
    echo "总流量: $total_bytes 字节 (约 $total_mb MB)"
    echo
    
    echo "流量最大的请求 (Top 5):"
    awk '{print $10, $1, $7}' "$log_file" | sort -nr | head -5 | while read bytes ip url; do
        local mb=$((bytes / 1024 / 1024))
        echo "  $url - $ip: $bytes 字节 ($mb MB)"
    done
    echo
    
    echo "平均响应大小: $(awk '{sum+=$10; count++} END {print int(sum/count)}' "$log_file") 字节"
    echo
}

# 时间分析
time_analysis() {
    local log_file="$1"
    echo -e "${BLUE}=== 时间分析 ===${NC}"
    
    echo "每小时访问量:"
    awk '{print $4}' "$log_file" | cut -d: -f2 | sort | uniq -c | while read count hour; do
        echo "  ${hour}:00 - $count 次访问"
    done
    echo
    
    echo "访问高峰时段:"
    awk '{print $4}' "$log_file" | cut -d: -f2 | sort | uniq -c | sort -nr | head -3 | while read count hour; do
        echo -e "  ${YELLOW}${hour}:00 - $count 次访问${NC}"
    done
    echo
}

# 安全分析
security_analysis() {
    local log_file="$1"
    echo -e "${BLUE}=== 安全分析 ===${NC}"
    
    echo "潜在攻击模式检测:"
    
    # SQL注入尝试
    local sql_attempts=$(grep -i "union\|select\|insert\|delete\|drop" "$log_file" | wc -l)
    if [ "$sql_attempts" -gt 0 ]; then
        echo -e "  ${RED}SQL注入尝试: $sql_attempts 次${NC}"
        grep -i "union\|select\|insert\|delete\|drop" "$log_file" | head -3
    fi
    
    # XSS尝试
    local xss_attempts=$(grep -i "script\|javascript\|alert" "$log_file" | wc -l)
    if [ "$xss_attempts" -gt 0 ]; then
        echo -e "  ${RED}XSS尝试: $xss_attempts 次${NC}"
    fi
    
    # 目录遍历尝试
    local dir_traversal=$(grep -E "\.\./|\.\.\\\\" "$log_file" | wc -l)
    if [ "$dir_traversal" -gt 0 ]; then
        echo -e "  ${RED}目录遍历尝试: $dir_traversal 次${NC}"
    fi
    
    # 扫描器检测
    echo "扫描器/爬虫检测:"
    awk -F'"' '{print $6}' "$log_file" | grep -i "bot\|crawler\|spider\|scan" | sort | uniq -c | while read count agent; do
        echo "  $agent: $count 次"
    done
    echo
}

# 生成报告
generate_report() {
    local log_file="$1"
    local report_file="$OUTPUT_DIR/log_analysis_report_$DATE.txt"
    
    mkdir -p "$OUTPUT_DIR"
    
    {
        echo "Web服务器日志分析报告"
        echo "生成时间: $(date)"
        echo "日志文件: $log_file"
        echo "==========================================="
        echo
        
        basic_stats "$log_file"
        status_code_analysis "$log_file"
        ip_analysis "$log_file"
        url_analysis "$log_file"
        user_agent_analysis "$log_file"
        traffic_analysis "$log_file"
        time_analysis "$log_file"
        security_analysis "$log_file"
        
    } > "$report_file"
    
    echo -e "${GREEN}详细报告已生成: $report_file${NC}"
}

# 实时监控模式
real_time_monitor() {
    local log_file="$1"
    echo -e "${YELLOW}启动实时监控模式 (Ctrl+C 退出)${NC}"
    echo "监控文件: $log_file"
    echo
    
    tail -f "$log_file" | while read line; do
        ip=$(echo "$line" | awk '{print $1}')
        method=$(echo "$line" | awk '{print $6}' | tr -d '"')
        url=$(echo "$line" | awk '{print $7}')
        status=$(echo "$line" | awk '{print $9}')
        
        case $status in
            200) color="$GREEN" ;;
            302) color="$YELLOW" ;;
            4*|5*) color="$RED" ;;
            *) color="$NC" ;;
        esac
        
        echo -e "${color}$(date '+%H:%M:%S') - $ip - $method $url - $status${NC}"
    done
}

# 显示帮助
show_help() {
    echo "Web服务器日志分析脚本"
    echo
    echo "用法: $0 [选项] [日志文件]"
    echo
    echo "选项:"
    echo "  -h, --help          显示帮助信息"
    echo "  -s, --sample        创建示例日志文件"
    echo "  -a, --analyze       完整分析 (默认)"
    echo "  -r, --report        生成详细报告"
    echo "  -m, --monitor       实时监控模式"
    echo "  --basic             仅基本统计"
    echo "  --status            仅状态码分析"
    echo "  --ip                仅IP分析"
    echo "  --url               仅URL分析"
    echo "  --security          仅安全分析"
    echo
    echo "示例:"
    echo "  $0 -s                           # 创建示例日志"
    echo "  $0 /var/log/apache2/access.log  # 分析指定日志文件"
    echo "  $0 -r /var/log/nginx/access.log # 生成详细报告"
    echo "  $0 -m /var/log/apache2/access.log # 实时监控"
}

# 主函数
main() {
    local log_file="$DEFAULT_LOG_FILE"
    local mode="analyze"
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--sample)
                create_sample_log
                exit 0
                ;;
            -a|--analyze)
                mode="analyze"
                shift
                ;;
            -r|--report)
                mode="report"
                shift
                ;;
            -m|--monitor)
                mode="monitor"
                shift
                ;;
            --basic)
                mode="basic"
                shift
                ;;
            --status)
                mode="status"
                shift
                ;;
            --ip)
                mode="ip"
                shift
                ;;
            --url)
                mode="url"
                shift
                ;;
            --security)
                mode="security"
                shift
                ;;
            -*)
                echo "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                log_file="$1"
                shift
                ;;
        esac
    done
    
    # 检查日志文件
    if [ ! -f "$log_file" ]; then
        echo -e "${RED}错误: 日志文件不存在: $log_file${NC}"
        echo "使用 '$0 -s' 创建示例日志文件"
        exit 1
    fi
    
    echo -e "${YELLOW}=== Web服务器日志分析 ===${NC}"
    echo "日志文件: $log_file"
    echo "分析模式: $mode"
    echo
    
    # 执行相应的分析
    case $mode in
        "analyze")
            basic_stats "$log_file"
            status_code_analysis "$log_file"
            ip_analysis "$log_file"
            url_analysis "$log_file"
            user_agent_analysis "$log_file"
            traffic_analysis "$log_file"
            time_analysis "$log_file"
            security_analysis "$log_file"
            ;;
        "report")
            generate_report "$log_file"
            ;;
        "monitor")
            real_time_monitor "$log_file"
            ;;
        "basic")
            basic_stats "$log_file"
            ;;
        "status")
            status_code_analysis "$log_file"
            ;;
        "ip")
            ip_analysis "$log_file"
            ;;
        "url")
            url_analysis "$log_file"
            ;;
        "security")
            security_analysis "$log_file"
            ;;
    esac
    
    echo -e "${GREEN}分析完成${NC}"
}

# 运行脚本
main "$@"