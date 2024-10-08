#!/usr/bin/with-contenv sh

#显示信息
echo "========================================="
echo "当前zerotier版本："
echo `zerotier-cli -v`
echo "========================================="

#参考https://github.com/zyclonite/zerotier-docker/blob/main/scripts/entrypoint-router.sh
if [ "$GATEWAY_MODE" == "true" ]; then
	
	# is routing enabled?
	if [ $(sysctl -n net.ipv4.ip_forward) -ne 1 ] ; then
	
		# no! there is no point in setting up rules or termination handler
		echo "========================================="
		echo "未允许 IPv4 流量转发，ZeroTier-One将运行于单机模式"
		echo "如需运行于网关模式，请在宿主机运行以下命令开启内核转发后重启容器："
		echo "echo net.ipv4.ip_forward=1 | tee -a /etc/sysctl.conf && sysctl -p"
		echo "========================================="
		
	else
	
		echo "========================================="
		echo "GATEWAY_MODE = true ，ZeroTier-One将运行于网关模式"
		echo "使用 ${IPTABLES_CMD} 设置防火墙放行规则，注释标志为dockers-ZeroTier"
		echo "可用 ${IPTABLES_CMD} -nvL 查看是否添加成功"
		echo "========================================="
		
		#防火墙规则
		ZT_IFACE="zt+"		
		${IPTABLES_CMD} -t nat -A POSTROUTING -o ${ZT_IFACE} -j MASQUERADE -m comment --comment "dockers-ZeroTier"
		for PHY_IFACE in ${PHY_IFACES} ; do
			${IPTABLES_CMD} -t nat -A POSTROUTING -o ${PHY_IFACE} -j MASQUERADE -m comment --comment "dockers-ZeroTier"
			${IPTABLES_CMD} -A FORWARD -i ${ZT_IFACE} -o ${PHY_IFACE} -j ACCEPT -m comment --comment "dockers-ZeroTier"
			${IPTABLES_CMD} -A FORWARD -i ${PHY_IFACE} -o ${ZT_IFACE} -j ACCEPT -m comment --comment "dockers-ZeroTier"
		done

	fi
	
else

	echo "========================================="
	echo "ZeroTier-One将运行于单机模式"
	echo "========================================="

fi

CONFIG_DIR="/var/lib/zerotier-one"
NETWORKS_DIR="${CONFIG_DIR}/networks.d"

# set up network auto-join if (a) the networks directory does not exist
# and (b) the ZEROTIER_ONE_NETWORK_IDS environment variable is non-null.
if [ ! -d "${NETWORKS_DIR}" -a -n "${ZEROTIER_ONE_NETWORK_IDS}" ] ; then
	mkdir -p "${NETWORKS_DIR}"
	for NETWORK_ID in ${ZEROTIER_ONE_NETWORK_IDS} ; do
		echo "========================================="
		echo "配置network ID: ${NETWORK_ID}"
		touch "${NETWORKS_DIR}/${NETWORK_ID}.conf"
		echo "访问zerotier管理界面批准，如："
		echo "   https://my.zerotier.com/network/${NETWORK_ID}"
		echo "========================================="
	done
fi