#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🔍 Sing-box 配置验证脚本
# ═══════════════════════════════════════════════════════════════

# 设置严格模式
set -euo pipefail

# 颜色输出函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色

# IP地址自动检测函数
detect_server_ip() {
    info "🔍 正在自动检测服务器IP地址..."
    
    local detected_ipv4=""
    local detected_ipv6=""
    local final_ip=""
    
    # 方法1: 使用多个IP检测服务
    local ip_services=(
        "http://api-ipv4.ip.sb"
        "http://ipv4.icanhazip.com"
        "http://ipinfo.io/ip"
        "http://ifconfig.me/ip"
        "http://ipecho.net/plain"
        "http://ident.me"
        "http://whatismyip.akamai.com"
    )
    
    # 检测IPv4
    for service in "${ip_services[@]}"; do
        info "尝试从 $service 获取IPv4地址..."
        detected_ipv4=$(wget --no-check-certificate --tries=1 --timeout=5 -qO- "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        if [ -n "$detected_ipv4" ]; then
            info "✅ 检测到IPv4地址: $detected_ipv4"
            break
        fi
    done
    
    # 检测IPv6
    local ipv6_services=(
        "http://api-ipv6.ip.sb"
        "http://ipv6.icanhazip.com"
        "http://v6.ident.me"
    )
    
    for service in "${ipv6_services[@]}"; do
        info "尝试从 $service 获取IPv6地址..."
        detected_ipv6=$(wget --no-check-certificate --tries=1 --timeout=5 -qO- "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9a-fA-F:]+$')
        if [ -n "$detected_ipv6" ]; then
            info "✅ 检测到IPv6地址: $detected_ipv6"
            break
        fi
    done
    
    # 方法2: 从网络接口获取
    if [ -z "$detected_ipv4" ] && [ -z "$detected_ipv6" ]; then
        info "尝试从网络接口获取IP地址..."
        
        # 获取默认网络接口
        local default_interface=$(ip route | grep default | head -1 | awk '{print $5}')
        if [ -n "$default_interface" ]; then
            info "默认网络接口: $default_interface"
            
            # 从接口获取IPv4
            detected_ipv4=$(ip -4 addr show "$default_interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
            if [ -n "$detected_ipv4" ]; then
                info "✅ 从接口获取IPv4: $detected_ipv4"
            fi
            
            # 从接口获取IPv6
            detected_ipv6=$(ip -6 addr show "$default_interface" | grep -oP '(?<=inet6\s)[0-9a-fA-F:]+' | grep -v '^::1$' | grep -v '^fe80:' | head -1)
            if [ -n "$detected_ipv6" ]; then
                info "✅ 从接口获取IPv6: $detected_ipv6"
            fi
        fi
    fi
    
    # 方法3: 使用hostname命令
    if [ -z "$detected_ipv4" ] && [ -z "$detected_ipv6" ]; then
        info "尝试使用hostname命令获取IP地址..."
        local hostname_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
        if [ -n "$hostname_ip" ]; then
            if [[ "$hostname_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                detected_ipv4="$hostname_ip"
                info "✅ 从hostname获取IPv4: $detected_ipv4"
            elif [[ "$hostname_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
                detected_ipv6="$hostname_ip"
                info "✅ 从hostname获取IPv6: $detected_ipv6"
            fi
        fi
    fi
    
    # 选择最终IP地址
    if [ -n "$detected_ipv4" ]; then
        final_ip="$detected_ipv4"
        info "🎯 选择IPv4地址: $final_ip"
    elif [ -n "$detected_ipv6" ]; then
        final_ip="$detected_ipv6"
        info "🎯 选择IPv6地址: $final_ip"
    else
        warning "❌ 无法自动检测到服务器IP地址"
        return 1
    fi
    
    # 验证IP地址格式
    if [[ "$final_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # IPv4格式验证
        local valid_ipv4=true
        IFS='.' read -ra ADDR <<< "$final_ip"
        for i in "${ADDR[@]}"; do
            if [ "$i" -gt 255 ] || [ "$i" -lt 0 ]; then
                valid_ipv4=false
                break
            fi
        done
        if [ "$valid_ipv4" = true ]; then
            info "✅ IPv4地址格式验证通过"
        else
            warning "❌ IPv4地址格式无效"
            return 1
        fi
    elif [[ "$final_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
        info "✅ IPv6地址格式验证通过"
    else
        warning "❌ IP地址格式无效"
        return 1
    fi
    
    # 设置SERVER_IP环境变量
    export SERVER_IP="$final_ip"
    info "🎉 服务器IP地址已自动设置为: $SERVER_IP"
    return 0
}

# 验证环境配置
validate_environment() {
    echo "🔍 验证环境配置..."
    local errors=0
    
    # 检查必需的环境变量
    if [ -z "${START_PORT:-}" ]; then
        warning "❌ 错误: START_PORT 未设置"
        errors=$((errors + 1))
    else
        info "✅ START_PORT: ${START_PORT}"
    fi
    
    # 检查SERVER_IP，如果未设置则自动检测
    if [ -z "${SERVER_IP:-}" ]; then
        warning "⚠️ SERVER_IP 未设置，尝试自动检测..."
        if detect_server_ip; then
            info "✅ 服务器IP地址自动检测成功: $SERVER_IP"
        else
            warning "❌ 服务器IP地址自动检测失败"
            errors=$((errors + 1))
        fi
    else
        info "✅ 使用预设的SERVER_IP: $SERVER_IP"
    fi
    
    # 验证端口范围
    if [ -n "${START_PORT:-}" ]; then
        if ! [[ "$START_PORT" =~ ^[0-9]+$ ]] || [ "$START_PORT" -lt 100 ] || [ "$START_PORT" -gt 65520 ]; then
            warning "❌ 错误: START_PORT 必须在 100-65520 范围内"
            errors=$((errors + 1))
        else
            info "✅ START_PORT 范围验证通过"
        fi
    fi
    
    # 验证IP地址格式
    if [ -n "${SERVER_IP:-}" ]; then
        if ! [[ "$SERVER_IP" =~ ^[0-9a-fA-F:.]*$ ]]; then
            warning "❌ 错误: SERVER_IP 格式不正确"
            errors=$((errors + 1))
        else
            info "✅ SERVER_IP 格式验证通过"
        fi
    fi
    
    # 验证可选配置
    if [ -n "${UUID_CONFIRM:-}" ]; then
        if [[ "$UUID_CONFIRM" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
            info "✅ UUID 格式验证通过"
        else
            warning "⚠️ UUID 格式可能不正确"
        fi
    fi
    
    if [ $errors -gt 0 ]; then
        warning "配置验证失败，发现 $errors 个错误"
        return 1
    fi
    
    info "✅ 环境配置验证通过"
    return 0
}

# 验证网络连接
validate_network() {
    echo "🌐 验证网络连接..."
    
    # 检查外网连接
    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        info "✅ 外网连接正常"
    else
        warning "⚠️ 外网连接异常"
    fi
    
    # 检查 GitHub 连接
    if ping -c 1 -W 3 github.com >/dev/null 2>&1; then
        info "✅ GitHub 连接正常"
    else
        warning "⚠️ GitHub 连接异常"
    fi
    
    # 检查 Cloudflare 连接
    if ping -c 1 -W 3 cloudflare.com >/dev/null 2>&1; then
        info "✅ Cloudflare 连接正常"
    else
        warning "⚠️ Cloudflare 连接异常"
    fi
}

# 验证系统资源
validate_system() {
    echo "💻 验证系统资源..."
    
    # 检查内存
    local mem_total=$(free -m | awk 'NR==2{print $2}')
    if [ "$mem_total" -lt 512 ]; then
        warning "⚠️ 系统内存不足 512MB，可能影响性能"
    else
        info "✅ 系统内存: ${mem_total}MB"
    fi
    
    # 检查磁盘空间
    local disk_usage=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        warning "⚠️ 磁盘空间不足，使用率: ${disk_usage}%"
    else
        info "✅ 磁盘使用率: ${disk_usage}%"
    fi
    
    # 检查 CPU 核心数
    local cpu_cores=$(nproc)
    info "✅ CPU 核心数: $cpu_cores"
}

# 验证 Docker 环境
validate_docker() {
    echo "🐳 验证 Docker 环境..."
    
    if command -v docker >/dev/null 2>&1; then
        info "✅ Docker 已安装"
        
        # 检查 Docker 版本
        local docker_version=$(docker --version | awk '{print $3}' | sed 's/,//')
        info "✅ Docker 版本: $docker_version"
        
        # 检查 Docker 服务状态
        if docker info >/dev/null 2>&1; then
            info "✅ Docker 服务运行正常"
        else
            warning "⚠️ Docker 服务未运行"
        fi
    else
        warning "❌ Docker 未安装"
        return 1
    fi
}

# 主函数
main() {
    echo "🚀 开始配置验证..."
    echo "═══════════════════════════════════════════════════════════════"
    
    local total_errors=0
    
    # 执行各项验证
    validate_environment || total_errors=$((total_errors + 1))
    echo ""
    
    validate_network || total_errors=$((total_errors + 1))
    echo ""
    
    validate_system || total_errors=$((total_errors + 1))
    echo ""
    
    validate_docker || total_errors=$((total_errors + 1))
    echo ""
    
    # 输出总结
    echo "═══════════════════════════════════════════════════════════════"
    if [ $total_errors -eq 0 ]; then
        info "🎉 所有验证通过！系统已准备好部署 sing-box"
    else
        warning "⚠️ 发现 $total_errors 个问题，请检查后重试"
        exit 1
    fi
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
