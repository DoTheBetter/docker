#!/command/with-contenv sh

echo "==========================================="
cat /etc/s6-overlay/s6-rc.d/init/00-banner
echo " "
echo " "
echo "Rsync版本: $(rsync --version | sed -n 's/.*\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')"
echo "SSH服务：$([ "$SSH" = "true" ] && echo "[已启用]" || echo "<未启用>") | 计划任务：$([ "$CRON" = "true" ] && echo "[已启用]" || echo "<未启用>")"
echo "Rsync守护进程：$([ "$RSYNC" = "true" ] && echo "[已启用]" || echo "<未启用>") | Lsyncd守护进程：$([ "$LSYNCD" = "true" ] && echo "[已启用]" || echo "<未启用>")"
if [ "$SSH" = "true" ]; then
   echo "说明："
   echo "SSH密钥位于 /conf/.ssh 目录中。"
   echo "您可以将发起同步的客户端 *.pub 文件内容复制到远程主机的 authorized_keys 文件中，以实现免密登录。"
fi
echo "==========================================="