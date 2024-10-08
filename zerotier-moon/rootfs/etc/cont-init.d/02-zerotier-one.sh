#!/usr/bin/with-contenv sh

#显示信息
echo "========================================="
echo "当前zerotier版本："
echo `zerotier-cli -v`
echo "========================================="

#参考https://github.com/rwv/docker-zerotier-moon
stableEndpointsForSed=""
if [ "$IPV4_ADDRESS" = "" ]
then # ipv4 address is not set
        if [ "$IPV6_ADDRESS" = "" ]
        then # ipv6 address is not set
                echo "请设置公网IPv4或IPv6地址。"
                exit 0
        else # ipv6 address is set
                stableEndpointsForSed="\"$IPV6_ADDRESS\/$MOON_PORT\""
        fi
else # ipv4 address is set
        if [ "$IPV6_ADDRESS" = "" ]
        then # ipv6 address is not set
                stableEndpointsForSed="\"$IPV4_ADDRESS\/$MOON_PORT\""
        else # ipv6 address is set
                stableEndpointsForSed="\"$IPV4_ADDRESS\/$MOON_PORT\",\"$IPV6_ADDRESS\/$MOON_PORT\""
        fi
fi

if [ -d "/var/lib/zerotier-one/moons.d" ] # check if the moons conf has generated
then
        moon_id=$(cat /var/lib/zerotier-one/identity.public | cut -d ':' -f1)
        echo -e "你的ZeroTier moon id 为 \033[0;31m$moon_id\033[0m"
        echo -e "在其他主机上使用命令 \033[0;31m\"zerotier-cli orbit $moon_id $moon_id\"\033[0m 连接该moon，使用命令 \033[0;31m\"zerotier-cli listpeers\"\033[0m 检查是否连接成功。"
else
        nohup /usr/sbin/zerotier-one >/dev/null 2>&1 &
        # Waiting for identity generation...'
        while [ ! -f /var/lib/zerotier-one/identity.secret ]; do
	        sleep 1
        done
        /usr/sbin/zerotier-idtool initmoon /var/lib/zerotier-one/identity.public >>/var/lib/zerotier-one/moon.json
        sed -i 's/"stableEndpoints": \[\]/"stableEndpoints": ['$stableEndpointsForSed']/g' /var/lib/zerotier-one/moon.json
        /usr/sbin/zerotier-idtool genmoon /var/lib/zerotier-one/moon.json > /dev/null
        mkdir /var/lib/zerotier-one/moons.d
        mv *.moon /var/lib/zerotier-one/moons.d/
        pkill zerotier-one
        moon_id=$(cat /var/lib/zerotier-one/moon.json | grep \"id\" | cut -d '"' -f4)
        echo -e "你的ZeroTier moon id 为 \033[0;31m$moon_id\033[0m"
        echo -e "在其他主机上使用命令 \033[0;31m\"zerotier-cli orbit $moon_id $moon_id\"\033[0m 连接该moon，使用命令 \033[0;31m\"zerotier-cli listpeers\"\033[0m 检查是否连接成功。"
fi

