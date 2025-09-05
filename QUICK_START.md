# 🚀 米粒儿 Sing-box 快速开始指南

## 🔧 IP地址识别问题修复

如果您遇到服务器VPS地址识别不出来的问题，请按照以下步骤操作：

### 方法1: 使用IP修复脚本（推荐）

```bash
# 运行IP地址修复脚本
./fix_ip_detection.sh
```

这个脚本会：
- ✅ 自动检测服务器IP地址
- ✅ 测试IP地址连通性
- ✅ 生成配置建议
- ✅ 提供故障排除指导

### 方法2: 使用IP检测脚本

```bash
# 运行IP地址检测脚本
./detect_ip.sh
```

### 方法3: 使用配置验证脚本

```bash
# 运行配置验证（包含IP检测）
./validate_config.sh
```

## 🐳 Docker 快速部署

### 1. 自动检测IP并启动

```bash
# 构建镜像
docker build -t milier-sing-box .

# 自动检测IP地址并启动容器
docker run -d \
    --name milier-sing-box \
    -p 8800-8820:8800-8820/tcp \
    -p 8800-8820:8800-8820/udp \
    -e START_PORT=8800 \
    -e SERVER_IP=$(./detect_ip.sh) \
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
    -e NODE_NAME=米粒儿节点 \
    milier-sing-box
```

### 2. 手动指定IP地址

```bash
# 如果您知道服务器IP地址
docker run -d \
    --name milier-sing-box \
    -p 8800-8820:8800-8820/tcp \
    -p 8800-8820:8800-8820/udp \
    -e START_PORT=8800 \
    -e SERVER_IP=你的服务器IP地址 \
    -e XTLS_REALITY=true \
    -e HYSTERIA2=true \
    milier-sing-box
```

## 🧪 测试部署

```bash
# 运行测试脚本
./test_docker.sh
```

测试脚本会：
- ✅ 检查Docker环境
- ✅ 自动检测服务器IP
- ✅ 构建镜像
- ✅ 启动容器
- ✅ 运行健康检查
- ✅ 自动清理测试环境

## 🔍 故障排除

### 常见问题

1. **IP地址检测失败**
   ```bash
   # 运行修复脚本
   ./fix_ip_detection.sh
   ```

2. **容器启动失败**
   ```bash
   # 检查日志
   docker logs milier-sing-box
   
   # 检查配置
   ./validate_config.sh
   ```

3. **服务无法访问**
   ```bash
   # 运行健康检查
   docker exec milier-sing-box /sing-box/health_check.sh
   ```

### 手动设置IP地址

如果自动检测失败，您可以手动设置：

```bash
# 设置环境变量
export SERVER_IP="你的服务器IP地址"

# 或者在Docker运行时指定
docker run -e SERVER_IP="你的服务器IP地址" ...
```

## 📋 常用命令

```bash
# 查看容器状态
docker ps

# 查看容器日志
docker logs milier-sing-box

# 进入容器
docker exec -it milier-sing-box bash

# 停止容器
docker stop milier-sing-box

# 删除容器
docker rm milier-sing-box

# 查看镜像
docker images

# 删除镜像
docker rmi milier-sing-box
```

## 🎯 获取帮助

- 📱 TG 群：https://t.me/mlkjfx6
- 🎥 YouTube：youtube.com/@米粒儿813
- 📝 博客：https://ooovps.com

---

**🎉 现在您可以享受更安全、更快速、更稳定的 sing-box 服务了！**
