#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🔍 米粒儿 Sing-box 配置验证脚本
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

# 验证环境配置
validate_environment() {
    echo "🔍 验证环境配置..."
    local errors=0
    
    # 检查必需的环境变量
    local required_vars=("START_PORT" "SERVER_IP")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            warning "❌ 错误: $var 未设置"
            errors=$((errors + 1))
        else
            info "✅ $var: ${!var}"
        fi
    done
    
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
