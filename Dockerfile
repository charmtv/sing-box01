# ═══════════════════════════════════════════════════════════════
# 🌟 Sing-box 全家桶 Docker 镜像 🌟
# ═══════════════════════════════════════════════════════════════

# 🔐 第一阶段：生成 SSL 证书
FROM alpine/openssl:3.19 AS ssl-generator

# 🔑 生成更安全的私钥和自签名证书
RUN openssl ecparam -genkey -name secp384r1 -out /private.key && \
    openssl req -new -x509 -days 365 -key /private.key -out /cert.pem \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=SingBox/OU=Proxy/CN=localhost" \
    -extensions v3_ca \
    -config <(echo "
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = CN
ST = Beijing
L = Beijing
O = SingBox
OU = Proxy
CN = localhost

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
")

# 🚀 第二阶段：构建主镜像
FROM alpine:3.19

# 🏷️ 镜像标签信息
LABEL maintainer="charmtv" \
      description="Sing-box 全家桶 - 一键部署多协议代理服务器" \
      version="1.2.18" \
      url="https://github.com/charmtv/sing-box01" \
      vendor="charmtv"

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
    apk add --no-cache --virtual .build-deps supervisor wget nginx bash curl && \
    # 👤 创建非root用户
    addgroup -g 1000 singbox && \
    adduser -D -u 1000 -G singbox singbox && \
    # 📂 创建必要的目录
    mkdir -p /sing-box/conf /sing-box/subscribe /sing-box/logs /var/log/supervisor && \
    # 🔑 设置执行权限和文件所有权
    chmod +x /sing-box/init.sh && \
    chown -R singbox:singbox /sing-box && \
    # 🔒 设置证书文件权限
    chmod 600 /sing-box/cert/private.key && \
    chmod 644 /sing-box/cert/cert.pem && \
    # 🧹 清理缓存和临时文件
    apk del .build-deps && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# 👤 切换到非root用户
USER singbox

# 💡 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8800/health || exit 1

# 🔌 暴露端口
EXPOSE 8800-8820

# 🏃 启动命令
CMD ["./init.sh"]
