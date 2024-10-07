#!/usr/bin/with-contenv sh

#显示信息
echo "========================================="
echo "当前rsync版本："
echo `rsync --version`
echo "========================================="

mkdir -p /conf
if [ ! -e "/conf/rsync.password.example" ];then
	cp -f /rsync.password.example /conf/rsync.password.example
fi
chmod 0400 /conf/rsync.password.example

if [ "$RSYNC" == "true" ]; then
	#首次运行
	if [ ! -e "/conf/rsyncd.conf" ];then
		cp -f /rsyncd.conf.server /conf/rsyncd.conf
	fi
	ln -sf /conf/rsyncd.conf /etc/rsyncd.conf
	
	if [ ! -e "/conf/rsync.password" ];then
		cp -f /rsync.password /conf/rsync.password
	fi
	chmod 0400 /conf/rsync.password
	
	echo "========================================="
	echo "已开启Rsync daemon守护进程，请编辑/conf/rsyncd.conf配置文件。"
	echo "========================================="
else
	echo "========================================="
	echo "Rsync daemon守护进程服务未启用。"
	echo "========================================="

fi