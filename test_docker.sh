#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🧪 米粒儿 Sing-box Docker 测试脚本
#
# 📱 作者：米粒儿
# 💬 TG 群：https://t.me/mlkjfx6
# 🎥 YouTube：youtube.com/@米粒儿813
# 📝 博客：https://ooovps.com
# ═══════════════════════════════════════════════════════════════

echo "🧪 开始测试 Docker 容器..."

# 构建镜像
echo "📦 构建 Docker 镜像..."
docker build -t milier-sing-box-test .

if [ $? -eq 0 ]; then
    echo "✅ 镜像构建成功！"
else
    echo "❌ 镜像构建失败！"
    exit 1
fi

# 运行容器测试
echo "🚀 启动容器进行测试..."
docker run -d \
    --name milier-sing-box-test \
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
    milier-sing-box-test

if [ $? -eq 0 ]; then
    echo "✅ 容器启动成功！"
    
    # 等待容器初始化
    echo "⏳ 等待容器初始化 (30秒)..."
    sleep 30
    
    # 检查容器状态
    if docker ps | grep -q milier-sing-box-test; then
        echo "✅ 容器运行正常！"
        
        # 检查日志
        echo "📋 查看容器日志："
        docker logs milier-sing-box-test --tail 20
        
        # 检查服务状态
        echo "🔍 检查服务状态："
        docker exec milier-sing-box-test supervisorctl status
        
        echo "✅ 测试完成！容器运行正常。"
        echo "🔗 使用以下命令查看完整日志："
        echo "   docker logs milier-sing-box-test"
        echo "🗑️ 使用以下命令清理测试环境："
        echo "   docker stop milier-sing-box-test && docker rm milier-sing-box-test && docker rmi milier-sing-box-test"
        
    else
        echo "❌ 容器启动失败！"
        echo "📋 错误日志："
        docker logs milier-sing-box-test
        docker stop milier-sing-box-test >/dev/null 2>&1
        docker rm milier-sing-box-test >/dev/null 2>&1
        exit 1
    fi
    
else
    echo "❌ 容器启动失败！"
    exit 1
fi
