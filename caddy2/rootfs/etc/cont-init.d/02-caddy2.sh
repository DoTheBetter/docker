#!/usr/bin/with-contenv sh
# caddy设置
mkdir -p /usr/share/caddy
cp /index.html /usr/share/caddy/index.html
# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/docker-library/golang/blob/1eb096131592bcbc90aa3b97471811c798a93573/1.14/alpine3.12/Dockerfile#L9
[ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf
chmod +x /usr/bin/caddy
	
#显示信息
echo "========================================="
echo "当前Caddy2版本："
echo `caddy version`
echo "========================================="

# 复制默认配置文件
cp -f /Caddyfile.default $CADDY_DOCKER_CADDYFILE_PATH.default
if [ ! -e $CADDY_DOCKER_CADDYFILE_PATH ];then
    cp /Caddyfile.default $CADDY_DOCKER_CADDYFILE_PATH
    echo "==>Caddyfile文件已建立。"
else 
	echo "==>Caddyfile文件已存在。"
fi