ARG RSYNC_VER=3.4.1

FROM alpine:edge

ARG S6_VER=3.2.0.2

ENV TZ=Asia/Shanghai \
	SSH=false \
	CRON=false \
	RSYNC=false \
	LSYNCD=false \
	S6_VERBOSITY=1

COPY --chmod=755 rootfs /

RUN apk add --no-cache tzdata lsyncd rsync openssh \
# 安装s6-overlay	
	&& if [ "$(uname -m)" = "x86_64" ];then s6_arch=x86_64;elif [ "$(uname -m)" = "aarch64" ];then s6_arch=aarch64;elif [ "$(uname -m)" = "armv7l" ];then s6_arch=arm; fi \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
	&& wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
	&& tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
# sshd_config设置
	&& passwd=$(tr -dc 'A-Za-z0-9!@#$%^&*()' < /dev/urandom | head -c64) \
	&& echo "root:$passwd" | chpasswd \
	##修改SSH服务端配置
	# 禁用所有账户的密码登录
	&& echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
	&& echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config \
	&& echo "KbdInteractiveAuthentication no" >> /etc/ssh/sshd_config \
	# 限制Root用户仅允许密钥登录
	&& echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config \
	# 限制最大认证尝试次数
	&& echo "MaxAuthTries 3" >> /etc/ssh/sshd_config \
	# 禁用端口转发和其他网络功能
	&& echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config \
	&& echo "X11Forwarding no" >> /etc/ssh/sshd_config \
	&& echo "GatewayPorts no" >> /etc/ssh/sshd_config \
	# 禁用DNS反向解析加速连接
	&& echo "UseDNS no" >> /etc/ssh/sshd_config \
	# 设置会话超时（300秒无活动自动断开）
	&& echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config \
	&& echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config \
	# 限制并发会话数
	&& echo "MaxSessions 5" >> /etc/ssh/sshd_config \
	# 启用详细日志
	&& echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config \
	## 修改SSH客户端配置（自动接受新主机密钥）
	&& echo "Host *" >> /etc/ssh/ssh_config \
	&& echo "    StrictHostKeyChecking accept-new" >> /etc/ssh/ssh_config \
# 清除缓存
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& rm -rf /var/tmp/* \
	&& rm -rf $HOME/.cache


VOLUME /conf /backup
EXPOSE 22 873
ENTRYPOINT [ "/init" ]