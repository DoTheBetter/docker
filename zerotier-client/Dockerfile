ARG ZeroTierOne_VER=1.14.1

#编译ZeroTierOne
#https://git.alpinelinux.org/aports/tree/community/zerotier-one?id=eab757ac9e60bc25cf5d0c5b07785b12e7a4bb04
FROM alpine:3.20 AS builder
RUN apk upgrade --update \
	&& apk add linux-headers cargo openssl-dev \
	&& apk add make g++ \
	&& wget https://github.com/zerotier/ZeroTierOne/archive/refs/tags/1.14.1.zip -O /zerotier.zip \
	&& unzip /zerotier.zip -d / \
	&& cd /ZeroTierOne-1.14.1 \
	&& make \
	&& make DESTDIR=/tmp/build install

	
FROM alpine:3.20

ARG S6_VER=3.2.0.0
ENV TZ=Asia/Shanghai \
	GATEWAY_MODE=true \
	PHY_IFACES="eth0" \
	IPTABLES_CMD=iptables-legacy \
	ZEROTIER_ONE_NETWORK_IDS=

COPY --chmod=755 rootfs /
COPY --from=builder /tmp/build/usr/sbin/* /usr/sbin/

RUN apk upgrade --update --no-cache \
# 安装应用
	&& apk add --no-cache iptables iptables-legacy tzdata \
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