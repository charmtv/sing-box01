#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🔧 Sing-box IP地址识别修复脚本
# ═══════════════════════════════════════════════════════════════

# 设置严格模式
set -euo pipefail

# 颜色输出函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色
success() { echo -e "\033[36m\033[01m$*\033[0m"; } # 青色

# 配置
TIMEOUT=10
MAX_RETRIES=3

echo "🔧 Sing-box IP地址识别修复工具"
echo "═══════════════════════════════════════════════════════════════"

# 检查系统环境
check_system() {
    info "🔍 检查系统环境..."
    
    # 检查必要的命令
    local required_commands=("wget" "curl" "ip" "hostname")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            info "✅ $cmd 已安装"
        else
            warning "❌ $cmd 未安装"
        fi
    done
    
    # 检查网络连接
    if ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
        info "✅ 网络连接正常"
    else
        warning "⚠️ 网络连接异常"
    fi
}

# 多方法IP检测
detect_ip_comprehensive() {
    info "🌐 开始全面IP地址检测..."
    
    local detected_ipv4=""
    local detected_ipv6=""
    local final_ip=""
    
    # 方法1: 使用多个IP检测服务
    local ipv4_services=(
        "https://api.ipify.org"
        "https://ipv4.icanhazip.com"
        "https://api.ip.sb"
        "https://ipinfo.io/ip"
        "https://checkip.amazonaws.com"
        "https://ifconfig.me/ip"
        "http://api-ipv4.ip.sb"
        "https://ip.3322.net"
        "https://myip.ipip.net"
        "http://ipecho.net/plain"
        "http://ident.me"
        "http://whatismyip.akamai.com"
        "http://ip.42.pl/raw"
        "http://myip.dnsomatic.com"
        "http://checkip.amazonaws.com"
    )
    
    local ipv6_services=(
        "http://api-ipv6.ip.sb"
        "http://ipv6.icanhazip.com"
        "http://v6.ident.me"
    )
    
    # 检测IPv4
    info "🔍 检测IPv4地址..."
    for service in "${ipv4_services[@]}"; do
        hint "尝试: $service"
        detected_ipv4=$(wget --no-check-certificate --tries=1 --timeout=$TIMEOUT -qO- "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' | head -1)
        if [ -n "$detected_ipv4" ]; then
            # 验证IPv4地址
            local valid=true
            IFS='.' read -ra ADDR <<< "$detected_ipv4"
            for i in "${ADDR[@]}"; do
                if [ "$i" -gt 255 ] || [ "$i" -lt 0 ]; then
                    valid=false
                    break
                fi
            done
            if [ "$valid" = true ]; then
                success "✅ IPv4检测成功: $detected_ipv4 (来源: $service)"
                break
            fi
        fi
    done
    
    # 检测IPv6
    info "🔍 检测IPv6地址..."
    for service in "${ipv6_services[@]}"; do
        hint "尝试: $service"
        detected_ipv6=$(wget --no-check-certificate --tries=1 --timeout=$TIMEOUT -qO- "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9a-fA-F:]+$' | grep -v '^::1$' | head -1)
        if [ -n "$detected_ipv6" ]; then
            success "✅ IPv6检测成功: $detected_ipv6 (来源: $service)"
            break
        fi
    done
    
    # 方法2: 从网络接口获取
    if [ -z "$detected_ipv4" ] && [ -z "$detected_ipv6" ]; then
        info "🔍 从网络接口获取IP地址..."
        
        # 获取所有网络接口
        local interfaces=$(ip link show | grep -E '^[0-9]+:' | awk -F': ' '{print $2}' | grep -v 'lo')
        
        for interface in $interfaces; do
            hint "检查接口: $interface"
            
            # 获取IPv4
            if [ -z "$detected_ipv4" ]; then
                local ipv4=$(ip -4 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
                if [ -n "$ipv4" ]; then
                    detected_ipv4="$ipv4"
                    success "✅ 从接口 $interface 获取IPv4: $detected_ipv4"
                fi
            fi
            
            # 获取IPv6
            if [ -z "$detected_ipv6" ]; then
                local ipv6=$(ip -6 addr show "$interface" 2>/dev/null | grep -oP '(?<=inet6\s)[0-9a-fA-F:]+' | grep -v '^::1$' | grep -v '^fe80:' | head -1)
                if [ -n "$ipv6" ]; then
                    detected_ipv6="$ipv6"
                    success "✅ 从接口 $interface 获取IPv6: $detected_ipv6"
                fi
            fi
        done
    fi
    
    # 方法3: 使用hostname命令
    if [ -z "$detected_ipv4" ] && [ -z "$detected_ipv6" ]; then
        info "🔍 使用hostname命令获取IP地址..."
        local hostname_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
        if [ -n "$hostname_ip" ]; then
            if [[ "$hostname_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                detected_ipv4="$hostname_ip"
                success "✅ 从hostname获取IPv4: $detected_ipv4"
            elif [[ "$hostname_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
                detected_ipv6="$hostname_ip"
                success "✅ 从hostname获取IPv6: $detected_ipv6"
            fi
        fi
    fi
    
    # 方法4: 使用curl命令
    if [ -z "$detected_ipv4" ] && [ -z "$detected_ipv6" ]; then
        info "🔍 使用curl命令获取IP地址..."
        if command -v curl >/dev/null 2>&1; then
            local curl_ip=$(curl -s --max-time $TIMEOUT http://api-ipv4.ip.sb 2>/dev/null | tr -d '\n\r')
            if [[ "$curl_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                detected_ipv4="$curl_ip"
                success "✅ 从curl获取IPv4: $detected_ipv4"
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
        warning "❌ 所有方法都无法检测到IP地址"
        return 1
    fi
    
    # 获取IP地址信息
    get_ip_info "$final_ip"
    
    echo "$final_ip"
    return 0
}

# 获取IP地址信息
get_ip_info() {
    local ip="$1"
    
    info "📊 获取IP地址详细信息..."
    
    # 尝试获取地理位置信息
    local ip_info=""
    if command -v curl >/dev/null 2>&1; then
        ip_info=$(curl -s --max-time 5 "https://ipinfo.io/$ip/json" 2>/dev/null || echo "")
    elif command -v wget >/dev/null 2>&1; then
        ip_info=$(wget --no-check-certificate --tries=1 --timeout=5 -qO- "https://ipinfo.io/$ip/json" 2>/dev/null || echo "")
    fi
    
    if [ -n "$ip_info" ]; then
        local country=$(echo "$ip_info" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        local city=$(echo "$ip_info" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        local region=$(echo "$ip_info" | grep -o '"region":"[^"]*"' | cut -d'"' -f4)
        local org=$(echo "$ip_info" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
        local timezone=$(echo "$ip_info" | grep -o '"timezone":"[^"]*"' | cut -d'"' -f4)
        
        echo ""
        hint "📍 IP地址信息:"
        if [ -n "$country" ]; then
            hint "   国家/地区: $country"
        fi
        if [ -n "$region" ]; then
            hint "   地区: $region"
        fi
        if [ -n "$city" ]; then
            hint "   城市: $city"
        fi
        if [ -n "$org" ]; then
            hint "   运营商: $org"
        fi
        if [ -n "$timezone" ]; then
            hint "   时区: $timezone"
        fi
    fi
}

# 生成配置建议
generate_config_suggestions() {
    local ip="$1"
    
    echo ""
    info "🔧 配置建议:"
    echo ""
    hint "1. 环境变量设置:"
    echo "   export SERVER_IP=\"$ip\""
    echo ""
    hint "2. Docker运行命令:"
    echo "   docker run -d \\"
    echo "     --name sing-box-family \\"
    echo "     -p 8800-8820:8800-8820/tcp \\"
    echo "     -p 8800-8820:8800-8820/udp \\"
    echo "     -e START_PORT=8800 \\"
    echo "     -e SERVER_IP=\"$ip\" \\"
    echo "     -e XTLS_REALITY=true \\"
    echo "     -e HYSTERIA2=true \\"
    echo "     sing-box-family"
    echo ""
    hint "3. 配置文件设置:"
    echo "   在 config.conf 中设置:"
    echo "   SERVER_IP='$ip'"
    echo ""
}

# 测试IP地址连通性
test_ip_connectivity() {
    local ip="$1"
    
    info "🔍 测试IP地址连通性..."
    
    # 测试ping
    if ping -c 1 -W 3 "$ip" >/dev/null 2>&1; then
        success "✅ IP地址 $ip 可以ping通"
    else
        warning "⚠️ IP地址 $ip 无法ping通"
    fi
    
    # 测试端口连通性
    local test_ports=(80 443 22)
    for port in "${test_ports[@]}"; do
        if timeout 3 bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
            success "✅ 端口 $port 可访问"
        else
            hint "ℹ️ 端口 $port 不可访问"
        fi
    done
}

# 主函数
main() {
    local detected_ip=""
    
    # 检查系统环境
    check_system
    echo ""
    
    # 检测IP地址
    if detected_ip=$(detect_ip_comprehensive); then
        echo ""
        success "🎉 IP地址检测成功: $detected_ip"
        
        # 测试连通性
        test_ip_connectivity "$detected_ip"
        
        # 生成配置建议
        generate_config_suggestions "$detected_ip"
        
        # 保存到文件
        echo "SERVER_IP=\"$detected_ip\"" > detected_ip.conf
        info "💾 IP地址已保存到 detected_ip.conf"
        
        echo ""
        success "🎊 IP地址识别修复完成！"
        
    else
        warning "❌ IP地址检测失败"
        echo ""
        hint "💡 故障排除建议:"
        hint "   1. 检查网络连接是否正常"
        hint "   2. 检查防火墙是否阻止了外网访问"
        hint "   3. 确认服务器是否有公网IP地址"
        hint "   4. 尝试手动设置SERVER_IP环境变量"
        echo ""
        hint "🔧 手动设置示例:"
        echo "   export SERVER_IP=\"你的服务器IP地址\""
        exit 1
    fi
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
