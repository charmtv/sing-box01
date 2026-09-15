# syntax=docker/dockerfile:1

# 构建阶段
FROM alpine:latest AS builder
ARG TARGETARCH=amd64
ARG S6_OVERLAY_VERSION=3.2.3.2
ENV ARCH=$TARGETARCH

# 安装构建依赖
RUN set -ex &&\
  apk add --no-cache wget xz

# 下载并解压 s6-overlay
RUN set -ex &&\
  case "$ARCH" in \
    amd64) S6_ARCH=x86_64 ;; \
    arm64) S6_ARCH=aarch64 ;; \
    armv7) S6_ARCH=armhf ;; \
    *) echo "Unsupported TARGETARCH: $ARCH" >&2; exit 1 ;; \
  esac &&\
  mkdir -p /rootfs &&\
  S6_RELEASE_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}" &&\
  for archive in s6-overlay-noarch.tar.xz "s6-overlay-${S6_ARCH}.tar.xz"; do \
    wget -q "${S6_RELEASE_URL}/${archive}" -O "/tmp/${archive}"; \
    wget -q "${S6_RELEASE_URL}/${archive}.sha256" -O "/tmp/${archive}.sha256"; \
    (cd /tmp && sha256sum -c "${archive}.sha256"); \
    tar -C /rootfs -Jxf "/tmp/${archive}"; \
  done

# 运行阶段
FROM alpine:latest
ARG TARGETARCH=amd64
ENV ARCH=$TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/charmtv/sing-box01" \
      org.opencontainers.image.description="Sing-box 多协议部署镜像"

# 设置工作目录
WORKDIR /sing-box

# 仅复制 s6-overlay 文件，避免把构建依赖带入运行镜像
COPY --from=builder /rootfs/ /

# 复制初始化脚本
COPY docker_init.sh /sing-box/init.sh

# 安装运行时依赖并生成证书
RUN set -ex &&\
  apk add --no-cache bash ca-certificates nginx openssl wget xxd &&\
  mkdir -p /sing-box/cert /sing-box/conf /sing-box/subscribe /sing-box/logs &&\
  chmod +x /sing-box/init.sh &&\
  rm -rf /var/cache/apk/*

CMD [ "./init.sh" ]
