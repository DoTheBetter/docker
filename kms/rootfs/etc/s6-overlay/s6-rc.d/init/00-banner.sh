#!/command/with-contenv sh

echo "==========================================="
cat /etc/s6-overlay/s6-rc.d/init/00-banner
echo " "
echo " "
echo "Vlmcsd版本： 1113 | Web服务：$([ "$WEB" = "true" ] && echo "[已启用]" || echo "<未启用>")"
echo "==========================================="
