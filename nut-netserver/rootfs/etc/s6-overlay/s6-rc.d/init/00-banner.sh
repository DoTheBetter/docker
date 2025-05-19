#!/command/with-contenv sh

echo "==========================================="
cat /etc/s6-overlay/s6-rc.d/init/00-banner
echo " "
echo " "
echo "nut版本: NUT_VER | 运行模式: $(grep '^MODE=' /nut/etc/nut.conf 2>/dev/null | cut -d'=' -f2 || echo "netserver")"
echo "web服务：$([ "$WEB" = "true" ] && echo "[已启用]" || echo "<未启用>")"
echo "==========================================="
