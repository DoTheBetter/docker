#!/command/with-contenv sh

echo "==========================================="
cat /etc/s6-overlay/s6-rc.d/init/00-banner
echo " "
echo " "
echo "Aria2版本：ARIA2_VER"
echo "AriaNg版本：AriaNg_VER | Web服务：$([ "$ENABLE_ARIANG" = "true" ] && echo "[已启用]" || echo "<未启用>")"
echo "FileBrowser版本：FileBrowser_VER | 文件服务：$([ "$ENABLE_FILEBROWSER" = "true" ] && echo "[已启用]" || echo "<未启用>")"
echo "==========================================="
