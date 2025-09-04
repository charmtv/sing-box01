# ═══════════════════════════════════════════════════════════════
# 🌟 米粒儿 Sing-box 全家桶 Docker 镜像 🌟
# 
# 📱 作者：米粒儿
# 💬 TG 群：https://t.me/mlkjfx6  
# 🎥 YouTube：youtube.com/@米粒儿813
# 📝 博客：https://ooovps.com
# ═══════════════════════════════════════════════════════════════

# 🔐 第一阶段：生成 SSL 证书
FROM alpine/openssl:latest AS ssl-generator

# 🔑 生成私钥和自签名证书
RUN openssl ecparam -genkey -name prime256v1 -out /private.key && \
    openssl req -new -x509 -days 36500 -key /private.key -out /cert.pem \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=MiLier/OU=VPS/CN=milier.tech/emailAddress=admin@milier.tech"

# 🚀 第二阶段：构建主镜像
FROM alpine:latest

# 🏷️ 镜像标签信息
LABEL maintainer="米粒儿 <admin@milier.tech>" \
      description="米粒儿 Sing-box 全家桶 - 一键部署多协议代理服务器" \
      version="1.2.18" \
      url="https://t.me/mlkjfx6" \
      vendor="MiLier"

# 🎯 构建参数
ARG TARGETARCH
ENV ARCH=$TARGETARCH

# 📁 设置工作目录
WORKDIR /sing-box

# 📋 复制文件
COPY --from=ssl-generator /private.key /sing-box/cert/private.key
COPY --from=ssl-generator /cert.pem /sing-box/cert/cert.pem
COPY docker_init.sh /sing-box/init.sh

# 🔧 系统配置和依赖安装
RUN set -ex && \
    # 📦 安装必要的软件包
    apk add --no-cache supervisor wget nginx bash curl && \
    # 📂 创建必要的目录
    mkdir -p /sing-box/conf /sing-box/subscribe /sing-box/logs && \
    # 🔑 设置执行权限
    chmod +x /sing-box/init.sh && \
    # 🧹 清理缓存
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# 💡 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8800/health || exit 1

# 🔌 暴露端口
EXPOSE 8800-8820

# 🏃 启动命令
CMD ["./init.sh"]