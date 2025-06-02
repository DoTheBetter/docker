ARG IT_TOOLS_ZH_DOCKER_VER=20250602
ARG IT_TOOLS_VER=8b7cdb4

FROM ghcr.io/dothebetter/baseimage_it-tools-zh:latest AS builder

FROM alpine:3.21
ARG S6_VER=3.2.1.0

ENV S6_VERBOSITY=1 \
	XDG_CONFIG_HOME=/etc \
	XDG_DATA_HOME=/etc \
    TZ=Asia/Shanghai

COPY --from=builder /www /www
COPY --chmod=755 rootfs /

RUN apk add --no-cache \
    ca-certificates tzdata caddy \
# 安装s6-overlay
    && if [ "$(uname -m)" = "x86_64" ]; then s6_arch=x86_64; \
    elif [ "$(uname -m)" = "aarch64" ]; then s6_arch=aarch64; \
    elif [ "$(uname -m)" = "armv7l" ]; then s6_arch=arm; fi \
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
# 创建http用户及组
    && addgroup http \
    && adduser -D -H -G http -s /sbin/nologin http \
# 清除缓存
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf $HOME/.cache

WORKDIR /www

EXPOSE 8080

ENTRYPOINT ["/init"]