ARG CADDY_VER=2.11.4
ARG CADDY_DOCKER_VER=2.11.4-20260828

FROM ghcr.io/dothebetter/baseimage_caddy2:${CADDY_VER} AS caddybuilder

FROM alpine:3.24
ARG S6_VER=3.2.3.0

ENV TZ=Asia/Shanghai \
    S6_VERBOSITY=1 \
    #https://caddyserver.com/docs/conventions#file-locations
    XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/data \
    #https://github.com/lucaslorentz/caddy-docker-proxy
    CADDY_DOCKER_CADDYFILE_PATH=/config/Caddyfile \
    CADDY_DOCKER_LOG_LEVEL=WARN \
    #GeoIP数据库下载
    GEOIPUPDATE_AUTO=false \
    GEOIPUPDATE_EDITION_IDS=GeoLite2-Country \
    GEOIPUPDATE_DL_URL=https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download \
    GEOIPUPDATE_FREQUENCY=72 \
    #MaxMind凭证：与GEOIPUPDATE_AUTO配合，配置后geoip数据库由caddy-geo-ops插件auto_update通过MaxMind官方协议自动更新
    GEOIPUPDATE_ACCOUNT_ID= \
    GEOIPUPDATE_LICENSE_KEY=

COPY --from=caddybuilder /usr/bin/caddy /usr/bin/caddy
COPY --chmod=755 rootfs /

RUN apk upgrade --update --no-cache \
# 安装应用
	&& apk add --no-cache ca-certificates curl tzdata \
# 安装s6-overlay
    && if [ "$(uname -m)" = "x86_64" ]; then s6_arch=x86_64; \
    elif [ "$(uname -m)" = "aarch64" ]; then s6_arch=aarch64; \
    elif [ "$(uname -m)" = "armv7l" ]; then s6_arch=arm; fi \
    && curl -fSL --retry 3 --connect-timeout 30 -o /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && curl -fSL --retry 3 --connect-timeout 30 -o /tmp/s6-overlay-${s6_arch}.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
# 设置执行权限
	&& caddy version \
# 清除缓存
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& rm -rf /var/tmp/* \
	&& rm -rf $HOME/.cache

VOLUME /config /data
EXPOSE 80 443 443/udp 2019
ENTRYPOINT [ "/init" ]