ARG ARIA2_DOCKER_VER=1.37.0-20250618

FROM alpine:3.22

ARG ARIA2_VER=1.37.0
ARG AriaNg_VER=1.3.10
ARG FileBrowser_VER=2.32.3
ARG S6_VER=3.2.1.0

ENV PATH="/aria2/bin:${PATH}" \
    S6_VERBOSITY=1 \
    TZ=Asia/Shanghai \
    UID=1000 \
    GID=1000 \
    UMASK=022 \
    ARIA2_RPC_SECRET= \
    ARIA2_RPC_LISTEN_PORT=6800 \
    ARIA2_BT_LISTEN_PORT=6881 \
    CUSTOM_TRACKER_URL= \
    UPDATE_TRACKER=1 \
    ENABLE_IPV6=false \
    ENABLE_ARIANG=true \
    ENABLE_FILEBROWSER=true \
    HTTP_PORT=8080 \
    FILEBROWSER_PORT=8081

COPY --chmod=755 rootfs /

RUN apk add --no-cache \
    bash curl ca-certificates tzdata findutils jq mailcap shadow darkhttpd \
    && if [ "$(uname -m)" = "x86_64" ]; then s6_arch=x86_64; aria2_arch=x86_64-linux-musl; filemanager_arch=amd64; \
    elif [ "$(uname -m)" = "aarch64" ]; then s6_arch=aarch64; aria2_arch=aarch64-linux-musl; filemanager_arch=arm64; \
    elif [ "$(uname -m)" = "armv7l" ]; then s6_arch=arm; aria2_arch=arm-linux-musleabi; filemanager_arch=armv7; \
    fi \
# 安装s6-overlay
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
# 安装aria2
    && mkdir -p /aria2/bin \
    && wget -P /tmp https://github.com/DoTheBetter/aria2_build/releases/download/v${ARIA2_VER}/aria2-${ARIA2_VER}-${aria2_arch}_static.zip \
    && unzip /tmp/aria2-${ARIA2_VER}-${aria2_arch}_static.zip -d /aria2/bin \
    && chmod +x /aria2/bin/aria2c \
    && aria2c --version \
# 安装AriaNg
    && mkdir -p /aria2/www \
    && wget -P /tmp https://github.com/mayswind/AriaNg/releases/download/${AriaNg_VER}/AriaNg-${AriaNg_VER}.zip \
    && unzip /tmp/AriaNg-${AriaNg_VER}.zip -d /aria2/www \
# 安装filebrowser
    && wget -P /tmp https://github.com/filebrowser/filebrowser/releases/download/v${FileBrowser_VER}/linux-${filemanager_arch}-filebrowser.tar.gz \
    && tar -C /aria2/bin -xzf "/tmp/linux-${filemanager_arch}-filebrowser.tar.gz" "filebrowser" \
    && chmod +x /aria2/bin/filebrowser \
    && filebrowser version \
# 创建用户及组
    && addgroup download \
    && adduser -D -H -G download -s /sbin/nologin download \
    && addgroup http \
    && adduser -D -H -G http -s /sbin/nologin http \
# 设置目录权限
    && chown -R download:download /aria2/bin \
    && chmod -R 755 /aria2/bin \
    && chown -R http:http /aria2/www \
    && chmod -R 755 /aria2/www \
# 清除缓存
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf $HOME/.cache

WORKDIR /aria2
VOLUME /aria2/download /aria2/config
EXPOSE 6800 6881 6881/udp 8080 8081
ENTRYPOINT ["/init"]