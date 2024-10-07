#!/usr/bin/with-contenv sh

if [ "$SSH" == "true" ]; then
	#设置root账户随机密码
	passwd=`date +%s | sha256sum | base64 | head -c 32 ; echo`
	echo "root:$passwd" | chpasswd
	
#	#禁止使用密码认证登录root
#    #sed -i s/#PermitRootLogin.*/PermitRootLogin\ without-password/ /etc/ssh/sshd_config
#	sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin without-password/g" /etc/ssh/sshd_config
#	#允许公钥认证，用于SSH-2
#	sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
#	#禁用密码登录
#	sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
#
#    echo -e "Host *\nStrictHostKeyChecking accept-new" > /etc/ssh/ssh_config
	
	mkdir -p /conf/.ssh
	chmod 0700 /conf/.ssh
	ln -sf /conf/.ssh /root/.ssh
	
	ssh-keygen -A
	#初次生成ssh密钥
	if [ ! -e "/conf/.ssh/id_ed25519" ];then	
		ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N "" -q -C "docker_rsync"
	fi
	
	if [ ! -e "/conf/.ssh/authorized_keys" ];then	
		touch /conf/.ssh/authorized_keys
	fi	
	chown root:root /conf/.ssh/authorized_keys
	chmod 0600 /conf/.ssh/authorized_keys
	
	#启动ssh服务
	rc-status
	touch /run/openrc/softlevel
	rc-service sshd restart
	
	echo "========================================="
	echo "已启用SSH服务："	
	echo "ssh密钥请编辑/conf/.ssh文件夹中查看。"
	echo "可将命令发起端主机的*.pub文件内容复制到远端authorized_keys中实现免密登录"
	echo "========================================="
fi