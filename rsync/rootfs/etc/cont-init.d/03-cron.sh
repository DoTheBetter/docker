#!/usr/bin/with-contenv sh

mkdir -p /conf
if [ "$CRON" == "true" ]; then
	#首次运行
	if [ ! -e "/conf/crontabs" ];then
		touch /conf/crontabs
	fi
	chown root:root /conf/crontabs
	chmod 0755 /conf/crontabs
	ln -sf /conf/crontabs /var/spool/cron/crontabs/root
	echo "========================================="
	echo "已开启系统crontabs服务，请编辑/conf/crontabs文件。"
	echo "========================================="
else
	echo "========================================="
	echo "系统crontabs服务未启用。"
	echo "========================================="
fi