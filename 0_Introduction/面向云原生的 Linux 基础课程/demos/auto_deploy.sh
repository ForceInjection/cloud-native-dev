#!/bin/bash
# 自动化部署脚本
# 用于第七章：Shell 脚本编程 - 实用脚本示例

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
APP_NAME="myapp"
APP_VERSION="1.0.0"
DEPLOY_DIR="/tmp/deploy"
BACKUP_DIR="/tmp/backup"
LOG_FILE="/tmp/deploy.log"
GIT_REPO="https://github.com/example/myapp.git"
BRANCH="main"
SERVICE_PORT=8080

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log "[INFO] $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log "[SUCCESS] $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log "[WARNING] $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "[ERROR] $1"
}

# 错误处理
set -e
trap 'log_error "部署失败，退出码: $?"' ERR

# 检查依赖
check_dependencies() {
    log_info "检查部署依赖..."
    
    local missing_deps=()
    
    # 检查必要的命令
    for cmd in git curl tar; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "缺少依赖: ${missing_deps[*]}"
        exit 1
    fi
    
    log_success "依赖检查通过"
}

# 创建目录结构
setup_directories() {
    log_info "创建目录结构..."
    
    mkdir -p "$DEPLOY_DIR" "$BACKUP_DIR" "$(dirname "$LOG_FILE")"
    
    # 创建示例应用目录结构
    mkdir -p "$DEPLOY_DIR/src" "$DEPLOY_DIR/config" "$DEPLOY_DIR/logs"
    
    log_success "目录结构创建完成"
}

# 备份当前版本
backup_current_version() {
    log_info "备份当前版本..."
    
    if [ -d "$DEPLOY_DIR/current" ]; then
        local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
        cp -r "$DEPLOY_DIR/current" "$BACKUP_DIR/$backup_name"
        log_success "当前版本已备份到: $BACKUP_DIR/$backup_name"
    else
        log_warning "没有找到当前版本，跳过备份"
    fi
}

# 下载应用代码（模拟）
download_application() {
    log_info "下载应用代码..."
    
    # 创建模拟的应用代码
    local temp_dir="$DEPLOY_DIR/temp"
    mkdir -p "$temp_dir"
    
    # 创建示例应用文件
    cat > "$temp_dir/app.py" << 'EOF'
#!/usr/bin/env python3
# 示例 Web 应用
import http.server
import socketserver
import os

PORT = int(os.environ.get('PORT', 8080))

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<h1>Hello from MyApp v1.0.0</h1>')
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'OK')
        else:
            super().do_GET()

if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"Server running on port {PORT}")
        httpd.serve_forever()
EOF
    
    cat > "$temp_dir/requirements.txt" << 'EOF'
# Python dependencies
# (示例应用无需额外依赖)
EOF
    
    cat > "$temp_dir/Dockerfile" << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8080
CMD ["python", "app.py"]
EOF
    
    cat > "$temp_dir/config.json" << 'EOF'
{
  "app_name": "myapp",
  "version": "1.0.0",
  "port": 8080,
  "debug": false,
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "myapp_db"
  }
}
EOF
    
    # 创建启动脚本
    cat > "$temp_dir/start.sh" << 'EOF'
#!/bin/bash
export PORT=8080
python3 app.py
EOF
    chmod +x "$temp_dir/start.sh"
    
    # 创建停止脚本
    cat > "$temp_dir/stop.sh" << 'EOF'
#!/bin/bash
PID_FILE="/tmp/myapp.pid"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm -f "$PID_FILE"
        echo "应用已停止"
    else
        echo "进程不存在，清理PID文件"
        rm -f "$PID_FILE"
    fi
else
    echo "PID文件不存在"
fi
EOF
    chmod +x "$temp_dir/stop.sh"
    
    log_success "应用代码下载完成"
}

# 安装依赖
install_dependencies() {
    log_info "安装应用依赖..."
    
    local temp_dir="$DEPLOY_DIR/temp"
    
    # 检查 Python
    if command -v python3 &> /dev/null; then
        log_info "Python3 已安装"
        
        # 模拟安装 Python 依赖
        if [ -f "$temp_dir/requirements.txt" ]; then
            log_info "安装 Python 依赖..."
            # pip3 install -r "$temp_dir/requirements.txt" --quiet
            log_success "Python 依赖安装完成"
        fi
    else
        log_warning "Python3 未安装，跳过依赖安装"
    fi
}

# 配置应用
configure_application() {
    log_info "配置应用..."
    
    local temp_dir="$DEPLOY_DIR/temp"
    local config_file="$temp_dir/config.json"
    
    if [ -f "$config_file" ]; then
        # 更新配置文件中的端口
        if command -v python3 &> /dev/null; then
            python3 -c "
import json
with open('$config_file', 'r') as f:
    config = json.load(f)
config['port'] = $SERVICE_PORT
with open('$config_file', 'w') as f:
    json.dump(config, f, indent=2)
" 2>/dev/null || log_warning "配置文件更新失败"
        fi
        
        log_success "应用配置完成"
    else
        log_warning "配置文件不存在"
    fi
}

# 运行测试
run_tests() {
    log_info "运行应用测试..."
    
    # 创建简单的测试脚本
    cat > "$DEPLOY_DIR/temp/test.sh" << 'EOF'
#!/bin/bash
echo "运行单元测试..."
echo "✓ 配置文件验证"
echo "✓ 依赖检查"
echo "✓ 语法检查"
echo "所有测试通过"
EOF
    chmod +x "$DEPLOY_DIR/temp/test.sh"
    
    # 运行测试
    if bash "$DEPLOY_DIR/temp/test.sh"; then
        log_success "测试通过"
    else
        log_error "测试失败"
        exit 1
    fi
}

# 部署应用
deploy_application() {
    log_info "部署应用..."
    
    local temp_dir="$DEPLOY_DIR/temp"
    local current_dir="$DEPLOY_DIR/current"
    
    # 停止当前运行的应用
    if [ -f "$current_dir/stop.sh" ]; then
        log_info "停止当前应用..."
        bash "$current_dir/stop.sh" || log_warning "停止应用失败"
    fi
    
    # 移除旧版本
    if [ -d "$current_dir" ]; then
        rm -rf "$current_dir"
    fi
    
    # 部署新版本
    mv "$temp_dir" "$current_dir"
    
    log_success "应用部署完成"
}

# 启动应用
start_application() {
    log_info "启动应用..."
    
    local current_dir="$DEPLOY_DIR/current"
    
    if [ -f "$current_dir/start.sh" ]; then
        # 后台启动应用
        cd "$current_dir"
        nohup bash start.sh > "$DEPLOY_DIR/logs/app.log" 2>&1 &
        echo $! > "/tmp/myapp.pid"
        
        # 等待应用启动
        sleep 3
        
        log_success "应用已启动，PID: $(cat /tmp/myapp.pid 2>/dev/null || echo '未知')"
    else
        log_error "启动脚本不存在"
        exit 1
    fi
}

# 健康检查
health_check() {
    log_info "执行健康检查..."
    
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "健康检查尝试 $attempt/$max_attempts"
        
        if curl -s "http://localhost:$SERVICE_PORT/health" > /dev/null 2>&1; then
            log_success "健康检查通过"
            return 0
        fi
        
        sleep 5
        ((attempt++))
    done
    
    log_error "健康检查失败"
    return 1
}

# 回滚函数
rollback() {
    log_warning "开始回滚..."
    
    local latest_backup=$(ls -t "$BACKUP_DIR" | head -1)
    
    if [ -n "$latest_backup" ] && [ -d "$BACKUP_DIR/$latest_backup" ]; then
        # 停止当前应用
        if [ -f "$DEPLOY_DIR/current/stop.sh" ]; then
            bash "$DEPLOY_DIR/current/stop.sh"
        fi
        
        # 恢复备份
        rm -rf "$DEPLOY_DIR/current"
        cp -r "$BACKUP_DIR/$latest_backup" "$DEPLOY_DIR/current"
        
        # 启动应用
        start_application
        
        log_success "回滚完成"
    else
        log_error "没有可用的备份进行回滚"
        exit 1
    fi
}

# 清理旧备份
cleanup_old_backups() {
    log_info "清理旧备份..."
    
    # 保留最近5个备份
    local keep_count=5
    local backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
    
    if [ "$backup_count" -gt "$keep_count" ]; then
        ls -t "$BACKUP_DIR" | tail -n +$((keep_count + 1)) | while read backup; do
            rm -rf "$BACKUP_DIR/$backup"
            log_info "删除旧备份: $backup"
        done
    fi
    
    log_success "备份清理完成"
}

# 显示部署状态
show_status() {
    echo -e "${BLUE}=== 部署状态 ===${NC}"
    
    if [ -f "/tmp/myapp.pid" ]; then
        local pid=$(cat /tmp/myapp.pid)
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${GREEN}应用状态: 运行中 (PID: $pid)${NC}"
        else
            echo -e "${RED}应用状态: 已停止${NC}"
        fi
    else
        echo -e "${RED}应用状态: 未运行${NC}"
    fi
    
    echo "部署目录: $DEPLOY_DIR"
    echo "备份目录: $BACKUP_DIR"
    echo "日志文件: $LOG_FILE"
    echo "服务端口: $SERVICE_PORT"
    
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
        echo "备份数量: $backup_count"
    fi
}

# 显示帮助
show_help() {
    echo "自动化部署脚本"
    echo
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  deploy     执行完整部署流程 (默认)"
    echo "  rollback   回滚到上一个版本"
    echo "  status     显示部署状态"
    echo "  start      启动应用"
    echo "  stop       停止应用"
    echo "  restart    重启应用"
    echo "  health     执行健康检查"
    echo "  cleanup    清理旧备份"
    echo "  help       显示帮助信息"
    echo
    echo "环境变量:"
    echo "  APP_NAME       应用名称 (默认: myapp)"
    echo "  APP_VERSION    应用版本 (默认: 1.0.0)"
    echo "  SERVICE_PORT   服务端口 (默认: 8080)"
    echo "  DEPLOY_DIR     部署目录 (默认: /tmp/deploy)"
    echo "  BACKUP_DIR     备份目录 (默认: /tmp/backup)"
}

# 主部署流程
main_deploy() {
    log_info "开始部署 $APP_NAME v$APP_VERSION"
    
    check_dependencies
    setup_directories
    backup_current_version
    download_application
    install_dependencies
    configure_application
    run_tests
    deploy_application
    start_application
    
    if health_check; then
        cleanup_old_backups
        log_success "部署成功完成！"
        show_status
    else
        log_error "健康检查失败，开始回滚"
        rollback
    fi
}

# 停止应用
stop_application() {
    log_info "停止应用..."
    
    if [ -f "$DEPLOY_DIR/current/stop.sh" ]; then
        bash "$DEPLOY_DIR/current/stop.sh"
        log_success "应用已停止"
    else
        log_warning "停止脚本不存在"
    fi
}

# 重启应用
restart_application() {
    log_info "重启应用..."
    stop_application
    sleep 2
    start_application
    health_check
}

# 主函数
main() {
    # 创建日志文件
    mkdir -p "$(dirname "$LOG_FILE")"
    touch "$LOG_FILE"
    
    case "${1:-deploy}" in
        "deploy")
            main_deploy
            ;;
        "rollback")
            rollback
            ;;
        "status")
            show_status
            ;;
        "start")
            start_application
            health_check
            ;;
        "stop")
            stop_application
            ;;
        "restart")
            restart_application
            ;;
        "health")
            health_check
            ;;
        "cleanup")
            cleanup_old_backups
            ;;
        "help")
            show_help
            ;;
        *)
            echo "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行脚本
main "$@"