FROM alpine:3.24
LABEL maintainer="Aleksandar Puharic xzero@elite7haers.net"

# https://github.com/just-containers/s6-overlay
# 多架构构建时通过 --build-arg S6_ARCH=... 指定架构（amd64=x86_64、arm64=aarch64、arm/v7=arm）
ARG S6_OVERLAY_VERSION=3.2.3.2
ARG S6_OVERLAY_BASE_URL=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_ARCH=x86_64

# 官方说明：v3 需要同时安装 noarch 与架构两个 tar.xz 包
ADD ${S6_OVERLAY_BASE_URL}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD ${S6_OVERLAY_BASE_URL}/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz /tmp

COPY rootfs /

# 官方说明：解压需保留文件权限（tar -p），并需要 xz 支持
RUN apk upgrade --update --no-cache \
    && apk add --no-cache xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

# Init
ENTRYPOINT [ "/init" ]
