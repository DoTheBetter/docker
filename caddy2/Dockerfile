ARG CADDY_VER=2.8.4

FROM caddy:2.8.4-builder-alpine AS caddybuilder
#https://github.com/docker-library/docs/tree/master/caddy
RUN xcaddy build \
	--with github.com/lucaslorentz/caddy-docker-proxy/v2 \
	--with github.com/mholt/caddy-webdav \
	--with github.com/porech/caddy-maxmind-geolocation \
	--with github.com/greenpau/caddy-security \
	--with github.com/caddy-dns/cloudflare \
	--with github.com/caddy-dns/dnspod \
	--with github.com/caddy-dns/alidns \
	--with github.com/caddy-dns/godaddy \
	--with github.com/caddy-dns/googleclouddns \
	--with github.com/caddy-dns/namecheap \
	--with github.com/caddy-dns/namesilo

FROM golang:alpine3.20 AS geoipbuilder
#https://github.com/maxmind/geoipupdate/blob/main/README.md
RUN go install github.com/maxmind/geoipupdate/v7/cmd/geoipupdate@latest \
	&& geoipupdate -V \
	&& which geoipupdate

FROM alpine:3.20
ARG S6_VER=3.2.0.0

ENV TZ=Asia/Shanghai \
	#https://caddyserver.com/docs/conventions#file-locations
	XDG_CONFIG_HOME=/config \
	XDG_DATA_HOME=/data \
	#https://github.com/lucaslorentz/caddy-docker-proxy
	CADDY_DOCKER_CADDYFILE_PATH=/config/Caddyfile \
	#https://github.com/maxmind/geoipupdate/blob/main/doc/docker.md
	GEOIPUPDATE_AUTO=false \
	GEOIPUPDATE_EDITION_IDS=GeoLite2-Country \
	GEOIPUPDATE_ACCOUNT_ID= \
	GEOIPUPDATE_LICENSE_KEY= \
	GEOIPUPDATE_FREQUENCY=72

COPY --from=caddybuilder /usr/bin/caddy /usr/bin/caddy
COPY --from=geoipbuilder /go/bin/geoipupdate /usr/bin/geoipupdate
COPY --chmod=755 rootfs /

RUN apk upgrade --update --no-cache \
# 安装应用
	&& apk add --no-cache ca-certificates tzdata \
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
# 清除缓存
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& rm -rf /var/tmp/* \
	&& rm -rf $HOME/.cache

VOLUME /config /data
EXPOSE 80 443 443/udp 2019
ENTRYPOINT [ "/init" ]