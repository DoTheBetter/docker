#!/usr/bin/with-contenv sh

# 设置时区https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

#显示信息
echo "========================================="
echo "当前服务器时间："
echo `date "+%Y-%m-%d %H:%M:%S"`
echo "========================================="