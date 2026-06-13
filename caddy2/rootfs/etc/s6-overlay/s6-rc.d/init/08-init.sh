#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
#显示信息
echo "→当前服务器时间:$(date "+%Y-%m-%d %H:%M:%S")"


echo "2.配置Caddy2"
# 修复 Alpine + 旧版 Go netgo 颠倒域名解析顺序、/etc/hosts 不生效的经典问题；
[ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

mkdir -p /usr/share/caddy
cp /etc/caddy/index.html /usr/share/caddy/index.html
# 复制默认配置文件
cp -f /etc/caddy/Caddyfile.default $CADDY_DOCKER_CADDYFILE_PATH.default
if [ ! -e $CADDY_DOCKER_CADDYFILE_PATH ];then
    cp /etc/caddy/Caddyfile.default $CADDY_DOCKER_CADDYFILE_PATH
    echo "==>Caddyfile文件已建立。"
else
	echo "==>Caddyfile文件已存在。"
fi
