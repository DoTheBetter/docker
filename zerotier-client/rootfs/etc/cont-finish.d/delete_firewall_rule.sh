#!/usr/bin/with-contenv sh

ZT_IFACE="zt+"
	
echo "即将退出容器，使用 ${IPTABLES_CMD} 删除注释标志为dockers-ZeroTierde 防火墙放行规则"
	
${IPTABLES_CMD} -t nat -D POSTROUTING -o ${ZT_IFACE} -j MASQUERADE -m comment --comment "dockers-ZeroTier"
for PHY_IFACE in ${PHY_IFACES} ; do
	${IPTABLES_CMD} -t nat -D POSTROUTING -o ${PHY_IFACE} -j MASQUERADE -m comment --comment "dockers-ZeroTier"
	${IPTABLES_CMD} -D FORWARD -i ${ZT_IFACE} -o ${PHY_IFACE} -j ACCEPT -m comment --comment "dockers-ZeroTier"
	${IPTABLES_CMD} -D FORWARD -i ${PHY_IFACE} -o ${ZT_IFACE} -j ACCEPT -m comment --comment "dockers-ZeroTier"
done