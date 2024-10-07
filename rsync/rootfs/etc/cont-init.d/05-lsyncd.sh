#!/usr/bin/with-contenv sh

mkdir -p /conf
if [ "$LSYNCD" == "true" ]; then
	#首次运行
	if [ ! -e "/conf/lsyncd.conf" ];then
		cp -f /lsyncd.conf /conf/lsyncd.conf
	fi
	cp -f /lsyncd.conf.example /conf/lsyncd.conf.example
	echo "========================================="
	echo "已开启Lysncd守护进程，请编辑/conf/lsyncd.conf配置文件。"
	echo "========================================="
else
	echo "========================================="
	echo "Lysncd守护进程服务未启用。"
	echo "========================================="
fi