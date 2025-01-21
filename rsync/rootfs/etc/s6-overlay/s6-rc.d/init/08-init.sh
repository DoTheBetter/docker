#!/command/with-contenv sh

echo "+正在运行初始化任务..."

# 创建 /conf 目录
mkdir -p /conf

echo "1.设置系统时区"
# 设置时区 https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
# 显示当前服务器时间
echo "当前服务器时间:$(date "+%Y-%m-%d %H:%M:%S")"

echo "2.配置SSH服务"
if [ "$SSH" == "true" ]; then
    # 每次重启设置root账户随机密码
    passwd=$(date +%s | sha256sum | base64 | head -c 32)
    echo "root:$passwd" | chpasswd

    # 创建.ssh目录并设置权限
    mkdir -p /conf/.ssh
    chmod 0700 /conf/.ssh
    ln -sf /conf/.ssh /root/.ssh

    # 生成SSH主机密钥
    ssh-keygen -A

    # 生成SSH密钥对（如果不存在）
    if [ ! -e "/conf/.ssh/id_ed25519" ]; then
        ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N "" -q -C "docker_rsync"
    fi

    # 创建authorized_keys文件并设置权限
    if [ ! -e "/conf/.ssh/authorized_keys" ]; then
        touch /conf/.ssh/authorized_keys
    fi
    chown root:root /conf/.ssh/authorized_keys
    chmod 0600 /conf/.ssh/authorized_keys

    # 初始化 OpenRC（如果尚未初始化）
    if [ ! -e "/run/openrc/softlevel" ]; then
        echo "初始化 OpenRC..."
        mkdir -p /run/openrc
        touch /run/openrc/softlevel
    fi
	
    # 启动SSH服务
    rc-status
    rc-update add sshd
    rc-service sshd start

    echo "SSH服务已启用"
    echo "SSH密钥位于 /conf/.ssh 目录中"
    echo "您可以将发起同步的客户端 *.pub 文件内容复制到远程主机的 authorized_keys 文件中，以实现免密登录。"
else
    echo "SSH服务未启用"
fi

echo "3.配置cron计划任务"
if [ "$CRON" == "true" ]; then
    # 首次运行创建crontabs文件
    if [ ! -e "/conf/crontabs" ]; then
        touch /conf/crontabs
    fi

    # 设置crontabs文件权限
    chown root:root /conf/crontabs
    chmod 0600 /conf/crontabs  # 通常crontab文件的权限应为0600

    # 创建符号链接
    ln -sf /conf/crontabs /var/spool/cron/crontabs/root
else
    echo "系统crontabs服务未启用。"
fi

echo "4.配置rsync"
#显示信息
echo `rsync --version`

if [ ! -e "/conf/rsync.password.example" ]; then
    cp -f /rsync.password.example /conf/rsync.password.example
fi
chmod 0400 /conf/rsync.password.example  # 设置示例密码文件权限

if [ "$RSYNC" == "true" ]; then
    # 首次运行复制rsyncd.conf配置文件
    if [ ! -e "/conf/rsyncd.conf" ]; then
        cp -f /rsyncd.conf.server /conf/rsyncd.conf
    fi
	
    # 首次运行复制rsync密码文件
    if [ ! -e "/conf/rsync.password" ]; then
        cp -f /rsync.password /conf/rsync.password
    fi
    chmod 0400 /conf/rsync.password  # 设置密码文件权限
else
    echo "Rsync daemon守护进程服务未启用。"
fi

echo "5.配置Lsyncd"
if [ "$LSYNCD" == "true" ]; then
    # 首次运行复制lsyncd.conf配置文件
    if [ ! -e "/conf/lsyncd.conf" ]; then
        cp -f /lsyncd.conf /conf/lsyncd.conf
    fi

    # 复制示例配置文件
    cp -f /lsyncd.conf.example /conf/lsyncd.conf.example
else
    echo "Lsyncd守护进程服务未启用。"
fi