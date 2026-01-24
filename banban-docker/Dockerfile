ARG BANBAN_DOCKER_VER=202601024

FROM debian:stable-slim

ARG S6_VER=3.2.1.0

ENV S6_VERBOSITY=1 \
    TZ=Asia/Shanghai \
    UID=1000 \
    GID=1000

COPY --chmod=755 rootfs /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates passwd tzdata wget xz-utils \
# 创建用户组和用户
    && groupadd -g ${GID} banbanuser-group \
    && useradd -g ${GID} -M -s /sbin/nologin -u ${UID} banban-user \
# 安装s6-overlay
    && if [ "$(uname -m)" = "x86_64" ]; then s6_arch=x86_64; \
    elif [ "$(uname -m)" = "aarch64" ]; then s6_arch=aarch64; \
    elif [ "$(uname -m)" = "armv7l" ]; then s6_arch=arm; \
    fi \
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
# 清除缓存
    && apt-get autoremove -y \
    && apt-get autoclean \
    && apt-get clean \
    && rm -rf /var/cache/apt/lists/* \
    && rm -rf /var/cache/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf ${HOME}/.cache \
    && rm -rf /var/log/*

ENTRYPOINT [ "/init" ]