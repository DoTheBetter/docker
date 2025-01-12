#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
#显示信息
echo "当前服务器时间:$(date "+%Y-%m-%d %H:%M:%S")"

echo "2.修改文件夹权限"
chown -R kms:kms /vlmcsd
chmod -R 755 /vlmcsd

chown -R http:http /www
chmod -R 755 /www

