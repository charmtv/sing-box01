#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🧪 米粒儿 Sing-box Docker 测试脚本
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

# 配置
CONTAINER_NAME="milier-sing-box-test"
IMAGE_NAME="milier-sing-box-test"
TEST_TIMEOUT=60

# 清理函数
cleanup() {
    hint "🧹 清理测试环境..."
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rmi "$IMAGE_NAME" >/dev/null 2>&1 || true
}

# 错误处理
error_exit() {
    warning "❌ 测试失败: $1"
    cleanup
    exit 1
}

# 检查 Docker 环境
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        error_exit "Docker 未安装"
    fi
    
    if ! docker info >/dev/null 2>&1; then
        error_exit "Docker 服务未运行"
    fi
    
    info "✅ Docker 环境检查通过"
}

info "🧪 开始测试 Docker 容器..."

# 检查 Docker 环境
check_docker

# 构建镜像
info "📦 构建 Docker 镜像..."
if docker build -t "$IMAGE_NAME" .; then
    info "✅ 镜像构建成功！"
else
    error_exit "镜像构建失败"
fi

# 运行容器测试
info "🚀 启动容器进行测试..."
if docker run -d \
    --name "$CONTAINER_NAME" \
    -p 8800-8820:8800-8820/tcp \
    -p 8800-8820:8800-8820/udp \
    -e START_PORT=8800 \
    -e SERVER_IP=127.0.0.1 \
    -e XTLS_REALITY=true \
    -e HYSTERIA2=true \
    -e TUIC=true \
    -e SHADOWTLS=true \
    -e SHADOWSOCKS=true \
    -e TROJAN=true \
    -e VMESS_WS=true \
    -e VLESS_WS=true \
    -e H2_REALITY=true \
    -e GRPC_REALITY=true \
    -e ANYTLS=true \
    -e UUID=20f7fca4-86e5-4ddf-9eed-24142073d197 \
    -e CDN=www.csgo.com \
    -e NODE_NAME=米粒儿测试节点 \
    "$IMAGE_NAME"; then
    info "✅ 容器启动成功！"
    
    # 等待容器初始化
    hint "⏳ 等待容器初始化 (30秒)..."
    sleep 30
    
    # 检查容器状态
    if docker ps | grep -q "$CONTAINER_NAME"; then
        info "✅ 容器运行正常！"
        
        # 检查日志
        hint "📋 查看容器日志："
        docker logs "$CONTAINER_NAME" --tail 20
        
        # 检查服务状态
        hint "🔍 检查服务状态："
        docker exec "$CONTAINER_NAME" supervisorctl status
        
        # 运行健康检查
        hint "🏥 运行健康检查："
        if docker exec "$CONTAINER_NAME" /bin/bash -c "if [ -f /sing-box/health_check.sh ]; then /sing-box/health_check.sh; else echo '健康检查脚本未找到'; fi"; then
            info "✅ 健康检查通过！"
        else
            warning "⚠️ 健康检查发现问题"
        fi
        
        info "🎉 测试完成！容器运行正常。"
        hint "🔗 使用以下命令查看完整日志："
        echo "   docker logs $CONTAINER_NAME"
        hint "🗑️ 使用以下命令清理测试环境："
        echo "   docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME && docker rmi $IMAGE_NAME"
        
        # 自动清理
        cleanup
        
    else
        error_exit "容器启动失败"
    fi
    
else
    error_exit "容器启动失败"
fi

