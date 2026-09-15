#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🏥 Sing-box 健康检查脚本
# ═══════════════════════════════════════════════════════════════

# 设置严格模式
set -euo pipefail

# 颜色输出函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色

# 配置
WORK_DIR=${WORK_DIR:-/sing-box}
HEALTH_PORT=${HEALTH_PORT:-8800}
TIMEOUT=${TIMEOUT:-5}

# 检查服务状态
check_service_status() {
    local service_name="$1"
    local status=""
    
    if command -v supervisorctl >/dev/null 2>&1; then
        status=$(supervisorctl status "$service_name" 2>/dev/null | awk '{print $2}' || echo "UNKNOWN")
    elif command -v systemctl >/dev/null 2>&1; then
        status=$(systemctl is-active "$service_name" 2>/dev/null || echo "unknown")
    else
        # 检查进程是否存在
        if pgrep -f "$service_name" >/dev/null 2>&1; then
            status="running"
        else
            status="stopped"
        fi
    fi
    
    case "$status" in
        "RUNNING"|"running"|"active")
            info "✅ $service_name: 运行中"
            return 0
            ;;
        "STOPPED"|"stopped"|"inactive")
            warning "❌ $service_name: 已停止"
            return 1
            ;;
        *)
            warning "⚠️ $service_name: 状态未知 ($status)"
            return 1
            ;;
    esac
}

# 检查端口监听
check_port_listening() {
    local port="$1"
    local service_name="$2"
    
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        info "✅ $service_name 端口 $port: 监听中"
        return 0
    elif ss -tuln 2>/dev/null | grep -q ":$port "; then
        info "✅ $service_name 端口 $port: 监听中"
        return 0
    else
        warning "❌ $service_name 端口 $port: 未监听"
        return 1
    fi
}

# 检查 HTTP 健康端点
check_http_health() {
    local url="$1"
    local service_name="$2"
    
    if curl -f -s --max-time "$TIMEOUT" "$url" >/dev/null 2>&1; then
        info "✅ $service_name HTTP 健康检查: 通过"
        return 0
    else
        warning "❌ $service_name HTTP 健康检查: 失败"
        return 1
    fi
}

# 检查配置文件
check_config_files() {
    local config_dir="$1"
    local errors=0
    
    if [ ! -d "$config_dir" ]; then
        warning "❌ 配置目录不存在: $config_dir"
        return 1
    fi
    
    # 检查主要配置文件
    local required_files=(
        "00_log.json"
        "01_outbounds.json"
        "02_endpoints.json"
        "03_route.json"
        "04_experimental.json"
        "05_dns.json"
        "06_ntp.json"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$config_dir/$file" ]; then
            info "✅ 配置文件存在: $file"
        else
            warning "❌ 配置文件缺失: $file"
            errors=$((errors + 1))
        fi
    done
    
    # 检查协议配置文件
    local protocol_files=(
        "11_xtls-reality_inbounds.json"
        "12_hysteria2_inbounds.json"
        "13_tuic_inbounds.json"
        "14_ShadowTLS_inbounds.json"
        "15_shadowsocks_inbounds.json"
        "16_trojan_inbounds.json"
        "17_vmess-ws_inbounds.json"
        "18_vless-ws-tls_inbounds.json"
        "19_h2-reality_inbounds.json"
        "20_grpc-reality_inbounds.json"
        "21_anytls_inbounds.json"
    )
    
    local found_protocols=0
    for file in "${protocol_files[@]}"; do
        if [ -f "$config_dir/$file" ]; then
            info "✅ 协议配置存在: $file"
            found_protocols=$((found_protocols + 1))
        fi
    done
    
    if [ $found_protocols -eq 0 ]; then
        warning "⚠️ 未找到任何协议配置文件"
        errors=$((errors + 1))
    else
        info "✅ 找到 $found_protocols 个协议配置文件"
    fi
    
    return $errors
}

# 检查日志文件
check_log_files() {
    local log_dir="$1"
    local errors=0
    
    if [ ! -d "$log_dir" ]; then
        warning "❌ 日志目录不存在: $log_dir"
        return 1
    fi
    
    # 检查主要日志文件
    local log_files=(
        "box.log"
        "nginx_access.log"
        "nginx_error.log"
    )
    
    for file in "${log_files[@]}"; do
        if [ -f "$log_dir/$file" ]; then
            local size=$(stat -c%s "$log_dir/$file" 2>/dev/null || echo "0")
            if [ "$size" -gt 0 ]; then
                info "✅ 日志文件存在且有内容: $file ($size bytes)"
            else
                hint "⚠️ 日志文件为空: $file"
            fi
        else
            hint "ℹ️ 日志文件不存在: $file"
        fi
    done
    
    return 0
}

# 检查系统资源
check_system_resources() {
    echo "💻 检查系统资源..."
    
    # 检查内存使用
    local mem_info=$(free -m 2>/dev/null || echo "0 0 0")
    local mem_total=$(echo "$mem_info" | awk 'NR==2{print $2}')
    local mem_used=$(echo "$mem_info" | awk 'NR==2{print $3}')
    local mem_percent=0
    
    if [ "$mem_total" -gt 0 ]; then
        mem_percent=$((mem_used * 100 / mem_total))
        if [ "$mem_percent" -gt 90 ]; then
            warning "⚠️ 内存使用率过高: ${mem_percent}%"
        else
            info "✅ 内存使用率: ${mem_percent}%"
        fi
    fi
    
    # 检查磁盘使用
    local disk_usage=$(df / | awk 'NR==2{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
    if [ "$disk_usage" -gt 90 ]; then
        warning "⚠️ 磁盘使用率过高: ${disk_usage}%"
    else
        info "✅ 磁盘使用率: ${disk_usage}%"
    fi
    
    # 检查 CPU 负载
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//' 2>/dev/null || echo "0")
    local cpu_cores=$(nproc 2>/dev/null || echo "1")
    local load_percent=$(echo "$load_avg $cpu_cores" | awk '{printf "%.0f", $1/$2*100}')
    
    if [ "$load_percent" -gt 80 ]; then
        warning "⚠️ CPU 负载过高: ${load_percent}%"
    else
        info "✅ CPU 负载: ${load_percent}%"
    fi
}

# 主健康检查函数
main_health_check() {
    echo "🏥 开始健康检查..."
    echo "═══════════════════════════════════════════════════════════════"
    
    local total_errors=0
    
    # 检查服务状态
    echo "🔧 检查服务状态..."
    check_service_status "sing-box" || total_errors=$((total_errors + 1))
    check_service_status "nginx" || total_errors=$((total_errors + 1))
    echo ""
    
    # 检查端口监听
    echo "🔌 检查端口监听..."
    check_port_listening "$HEALTH_PORT" "sing-box" || total_errors=$((total_errors + 1))
    check_port_listening "80" "nginx" || total_errors=$((total_errors + 1))
    check_port_listening "443" "nginx" || total_errors=$((total_errors + 1))
    echo ""
    
    # 检查 HTTP 健康端点
    echo "🌐 检查 HTTP 健康端点..."
    check_http_health "http://localhost:$HEALTH_PORT/health" "sing-box" || total_errors=$((total_errors + 1))
    echo ""
    
    # 检查配置文件
    echo "📋 检查配置文件..."
    check_config_files "$WORK_DIR/conf" || total_errors=$((total_errors + 1))
    echo ""
    
    # 检查日志文件
    echo "📝 检查日志文件..."
    check_log_files "$WORK_DIR/logs" || total_errors=$((total_errors + 1))
    echo ""
    
    # 检查系统资源
    check_system_resources
    echo ""
    
    # 输出总结
    echo "═══════════════════════════════════════════════════════════════"
    if [ $total_errors -eq 0 ]; then
        info "🎉 健康检查通过！所有服务运行正常"
        exit 0
    else
        warning "⚠️ 健康检查发现问题，共 $total_errors 个错误"
        exit 1
    fi
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main_health_check "$@"
fi
