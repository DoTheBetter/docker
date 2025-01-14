ARG KMS_VER=20250114

FROM alpine:3.21 AS builder

WORKDIR /root

COPY --chmod=755 backupfiles/ /root/

RUN apk add --no-cache p7zip coreutils make build-base \
    && sha256_actual=$(sha256sum /root/vlmcsd-1113-2020-03-28-Hotbird64.7z | awk '{print $1}') \
    && sha256_expected=$(cat /root/SHA256.txt) \
    && if [ "$sha256_actual" != "$sha256_expected" ]; then \
        echo "Error: SHA256 checksum mismatch! Actual: $sha256_actual, Expected: $sha256_expected"; \
        exit 1; \
    fi \
    && mkdir -p /root/vlmcsd \
    && 7z x /root/vlmcsd-1113-2020-03-28-Hotbird64.7z -o/root/vlmcsd -p2020 \
    && cd /root/vlmcsd \
    && make \
    && cp /root/vlmcsd/bin/vlmcsd /usr/bin/vlmcsd \
    && chmod +x /usr/bin/vlmcsd \
    && vlmcsd -V


FROM alpine:3.21

ARG S6_VER=3.2.0.2

ENV TZ=Asia/Shanghai \
    VLKMCSD_OPTS="-i /vlmcsd/vlmcsd.ini -D -e" \
	WEB=true \
	S6_VERBOSITY=1

COPY --chmod=755 rootfs /
COPY --from=builder --chmod=755 /root/vlmcsd/bin/vlmcsd /usr/bin/vlmcsd

RUN set -ex \
# 安装应用
	&& apk add --no-cache ca-certificates tzdata darkhttpd \
# 安装s6-overlay	
	&& if [ "$(uname -m)" = "x86_64" ];then s6_arch=x86_64;elif [ "$(uname -m)" = "aarch64" ];then s6_arch=aarch64;elif [ "$(uname -m)" = "armv7l" ];then s6_arch=arm; fi \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
# 创建kms用户组,创建无密码、无登录权限的用户
	&& addgroup kms \
	&& adduser -D -H -G kms -s /sbin/nologin kms \
# 创建http用户及组
	&& addgroup http \
	&& adduser -D -H -G http -s /sbin/nologin http \
# 清除缓存
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& rm -rf /var/tmp/* \
	&& rm -rf $HOME/.cache

EXPOSE 1688 8080
ENTRYPOINT [ "/init" ]
