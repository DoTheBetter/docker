ARG ZeroTierOne_VER=1.14.2

FROM ghcr.io/dothebetter/baseimage_zerotier:latest AS builder

FROM alpine:3.20

ARG S6_VER=3.2.0.0
ENV TZ=Asia/Shanghai \
    MOON_PORT=9993 \
    IPV4_ADDRESS= \
    IPV6_ADDRESS=

COPY --chmod=755 rootfs /
COPY --from=builder /tmp/build/usr/sbin/* /usr/sbin/

RUN apk upgrade --update --no-cache \
# 安装应用
	&& apk add --no-cache tzdata \
# 安装s6-overlay	
	&& if [ "$(uname -m)" = "x86_64" ];then s6_arch=x86_64;elif [ "$(uname -m)" = "aarch64" ];then s6_arch=aarch64;elif [ "$(uname -m)" = "armv7l" ];then s6_arch=arm; fi \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-symlinks-noarch.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-symlinks-arch.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz \
# 安装ZeroTierOne
	&& apk add --no-cache libgcc libstdc++ \		
	&& mkdir -p /var/lib/zerotier-one \
	&& zerotier-cli -v \
# 清除缓存
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& rm -rf /var/tmp/* \
	&& rm -rf $HOME/.cache

EXPOSE 9993/udp

VOLUME /var/lib/zerotier-one

WORKDIR /var/lib/zerotier-one

ENTRYPOINT [ "/init" ]