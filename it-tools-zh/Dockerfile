ARG IT_TOOLS_ZH_DOCKER_VER=20260821
ARG IT_TOOLS_VER=002a211

FROM ghcr.io/dothebetter/baseimage_it-tools-zh:${IT_TOOLS_VER} AS www-builder

# caddy 定制构建：标准发行版无响应体改写能力，需 replace_response 插件
FROM caddy:builder-alpine AS caddy-builder
# 注意：插件模块 ID 为 http.handlers.replace_response，但其 Caddyfile 指令名为 replace
RUN xcaddy build \
    --output /usr/bin/caddy \
    --with github.com/caddyserver/replace-response \
    && /usr/bin/caddy version \
    && /usr/bin/caddy list-modules --packages | grep -F 'http.handlers.replace_response'

FROM alpine:3.24
ARG S6_VER=3.2.3.2
ARG BASE_URL=/

ENV S6_VERBOSITY=1 \
	XDG_CONFIG_HOME=/etc \
	XDG_DATA_HOME=/etc \
    TZ=Asia/Shanghai \
    BASE_URL=${BASE_URL} \
    PORT=8080

COPY --from=www-builder /www /www
COPY --from=caddy-builder /usr/bin/caddy /usr/bin/caddy
COPY --chmod=755 rootfs /

RUN apk add --no-cache \
    ca-certificates tzdata \
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
# 校验 Caddyfile 语法（env 占位符需注入模拟值，redir 不接受空目标）
    && BASE_URL=/ BASE_URL_RE=/ BASE_URL_NOSLASH_RE= \
       caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile \
# 清除缓存
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf $HOME/.cache

WORKDIR /www

EXPOSE 8080

ENTRYPOINT ["/init"]