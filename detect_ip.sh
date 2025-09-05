#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🌐 米粒儿 Sing-box IP地址自动检测脚本
#
# 📱 作者：米粒儿
# 💬 TG 群：https://t.me/mlkjfx6
# 🎥 YouTube：youtube.com/@米粒儿813
# 📝 博客：https://ooovps.com
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

# IP检测服务列表
IPV4_SERVICES=(
    "http://api-ipv4.ip.sb"
    "http://ipv4.icanhazip.com"
    "http://ipinfo.io/ip"
    "http://ifconfig.me/ip"
    "http://ipecho.net/plain"
    "http://ident.me"
    "http://whatismyip.akamai.com"
    "http://ip.42.pl/raw"
    "http://myip.dnsomatic.com"
    "http://checkip.amazonaws.com"
)

IPV6_SERVICES=(
    "http://api-ipv6.ip.sb"
    "http://ipv6.icanhazip.com"
    "http://v6.ident.me"
    "http://ipv6.icanhazip.com"
)

# 从网络服务获取IP地址
get_ip_from_service() {
    local service="$1"
    local ip_type="$2"
    
    info "🔍 尝试从 $service 获取${ip_type}地址..."
    
    local ip=""
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        ip=$(wget --no-check-certificate --tries=1 --timeout=$TIMEOUT -qO- "$service" 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9a-fA-F:.]*$' | head -1)
        
        if [ -n "$ip" ]; then
            # 验证IP格式
            if [ "$ip_type" = "IPv4" ]; then
                if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                    # 验证IPv4地址有效性
                    local valid=true
                    IFS='.' read -ra ADDR <<< "$ip"
                    for i in "${ADDR[@]}"; do
                        if [ "$i" -gt 255 ] || [ "$i" -lt 0 ]; then
                            valid=false
                            break
                        fi
                    done
                    if [ "$valid" = true ]; then
                        success "✅ 从 $service 获取到有效IPv4地址: $ip"
                        echo "$ip"
                        return 0
                    fi
                fi
            elif [ "$ip_type" = "IPv6" ]; then
                if [[ "$ip" =~ ^[0-9a-fA-F:]+$ ]] && [[ "$ip" != "::1" ]] && [[ "$ip" != fe80:* ]]; then
                    success "✅ 从 $service 获取到有效IPv6地址: $ip"
                    echo "$ip"
                    return 0
                fi
            fi
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $MAX_RETRIES ]; then
            hint "⏳ 重试 $retry_count/$MAX_RETRIES..."
            sleep 1
        fi
    done
    
    warning "❌ 从 $service 获取${ip_type}地址失败"
    return 1
}

# 从网络接口获取IP地址
get_ip_from_interface() {
    local ip_type="$1"
    
    info "🔍 尝试从网络接口获取${ip_type}地址..."
    
    # 获取默认网络接口
    local default_interface=$(ip route | grep default | head -1 | awk '{print $5}' 2>/dev/null)
    if [ -z "$default_interface" ]; then
        warning "❌ 无法获取默认网络接口"
        return 1
    fi
    
    info "📡 默认网络接口: $default_interface"
    
    if [ "$ip_type" = "IPv4" ]; then
        # 获取IPv4地址
        local ipv4=$(ip -4 addr show "$default_interface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
        if [ -n "$ipv4" ]; then
            success "✅ 从接口 $default_interface 获取到IPv4地址: $ipv4"
            echo "$ipv4"
            return 0
        fi
    elif [ "$ip_type" = "IPv6" ]; then
        # 获取IPv6地址
        local ipv6=$(ip -6 addr show "$default_interface" 2>/dev/null | grep -oP '(?<=inet6\s)[0-9a-fA-F:]+' | grep -v '^::1$' | grep -v '^fe80:' | head -1)
        if [ -n "$ipv6" ]; then
            success "✅ 从接口 $default_interface 获取到IPv6地址: $ipv6"
            echo "$ipv6"
            return 0
        fi
    fi
    
    warning "❌ 从网络接口获取${ip_type}地址失败"
    return 1
}

# 使用hostname命令获取IP
get_ip_from_hostname() {
    local ip_type="$1"
    
    info "🔍 尝试使用hostname命令获取${ip_type}地址..."
    
    local hostname_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    if [ -n "$hostname_ip" ]; then
        if [ "$ip_type" = "IPv4" ] && [[ "$hostname_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            success "✅ 从hostname获取到IPv4地址: $hostname_ip"
            echo "$hostname_ip"
            return 0
        elif [ "$ip_type" = "IPv6" ] && [[ "$hostname_ip" =~ ^[0-9a-fA-F:]+$ ]]; then
            success "✅ 从hostname获取到IPv6地址: $hostname_ip"
            echo "$hostname_ip"
            return 0
        fi
    fi
    
    warning "❌ 从hostname获取${ip_type}地址失败"
    return 1
}

# 检测IPv4地址
detect_ipv4() {
    info "🌐 开始检测IPv4地址..."
    
    local detected_ip=""
    
    # 方法1: 从网络服务获取
    for service in "${IPV4_SERVICES[@]}"; do
        detected_ip=$(get_ip_from_service "$service" "IPv4" 2>/dev/null || true)
        if [ -n "$detected_ip" ]; then
            echo "$detected_ip"
            return 0
        fi
    done
    
    # 方法2: 从网络接口获取
    detected_ip=$(get_ip_from_interface "IPv4" 2>/dev/null || true)
    if [ -n "$detected_ip" ]; then
        echo "$detected_ip"
        return 0
    fi
    
    # 方法3: 从hostname获取
    detected_ip=$(get_ip_from_hostname "IPv4" 2>/dev/null || true)
    if [ -n "$detected_ip" ]; then
        echo "$detected_ip"
        return 0
    fi
    
    warning "❌ 无法检测到IPv4地址"
    return 1
}

# 检测IPv6地址
detect_ipv6() {
    info "🌐 开始检测IPv6地址..."
    
    local detected_ip=""
    
    # 方法1: 从网络服务获取
    for service in "${IPV6_SERVICES[@]}"; do
        detected_ip=$(get_ip_from_service "$service" "IPv6" 2>/dev/null || true)
        if [ -n "$detected_ip" ]; then
            echo "$detected_ip"
            return 0
        fi
    done
    
    # 方法2: 从网络接口获取
    detected_ip=$(get_ip_from_interface "IPv6" 2>/dev/null || true)
    if [ -n "$detected_ip" ]; then
        echo "$detected_ip"
        return 0
    fi
    
    # 方法3: 从hostname获取
    detected_ip=$(get_ip_from_hostname "IPv6" 2>/dev/null || true)
    if [ -n "$detected_ip" ]; then
        echo "$detected_ip"
        return 0
    fi
    
    warning "❌ 无法检测到IPv6地址"
    return 1
}

# 获取IP地址信息
get_ip_info() {
    local ip="$1"
    
    info "📊 获取IP地址信息: $ip"
    
    # 尝试获取IP地理位置信息
    local ip_info=""
    if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        # IPv4
        ip_info=$(wget --no-check-certificate --tries=1 --timeout=5 -qO- "https://ipinfo.io/$ip/json" 2>/dev/null || echo "")
    else
        # IPv6
        ip_info=$(wget --no-check-certificate --tries=1 --timeout=5 -qO- "https://ipinfo.io/$ip/json" 2>/dev/null || echo "")
    fi
    
    if [ -n "$ip_info" ]; then
        local country=$(echo "$ip_info" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        local city=$(echo "$ip_info" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        local org=$(echo "$ip_info" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$country" ]; then
            hint "📍 国家/地区: $country"
        fi
        if [ -n "$city" ]; then
            hint "🏙️ 城市: $city"
        fi
        if [ -n "$org" ]; then
            hint "🏢 运营商: $org"
        fi
    fi
}

# 主函数
main() {
    echo "🚀 米粒儿 Sing-box IP地址自动检测工具"
    echo "═══════════════════════════════════════════════════════════════"
    
    local detected_ipv4=""
    local detected_ipv6=""
    local final_ip=""
    
    # 检测IPv4
    detected_ipv4=$(detect_ipv4 2>/dev/null || echo "")
    
    # 检测IPv6
    detected_ipv6=$(detect_ipv6 2>/dev/null || echo "")
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    
    # 选择最终IP地址
    if [ -n "$detected_ipv4" ]; then
        final_ip="$detected_ipv4"
        success "🎯 选择IPv4地址: $final_ip"
        get_ip_info "$final_ip"
    elif [ -n "$detected_ipv6" ]; then
        final_ip="$detected_ipv6"
        success "🎯 选择IPv6地址: $final_ip"
        get_ip_info "$final_ip"
    else
        warning "❌ 无法检测到任何有效的IP地址"
        echo ""
        hint "💡 建议检查："
        hint "   1. 网络连接是否正常"
        hint "   2. 防火墙是否阻止了外网访问"
        hint "   3. 服务器是否有公网IP地址"
        exit 1
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    success "🎉 IP地址检测完成！"
    echo ""
    hint "📋 检测结果："
    if [ -n "$detected_ipv4" ]; then
        info "   IPv4: $detected_ipv4"
    fi
    if [ -n "$detected_ipv6" ]; then
        info "   IPv6: $detected_ipv6"
    fi
    success "   推荐使用: $final_ip"
    echo ""
    hint "🔧 使用方法："
    echo "   export SERVER_IP=\"$final_ip\""
    echo "   # 或者在Docker运行时使用："
    echo "   docker run -e SERVER_IP=\"$final_ip\" ..."
    echo ""
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
