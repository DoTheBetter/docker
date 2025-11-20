#!/command/with-contenv sh

echo "==========================================="
cat /etc/s6-overlay/s6-rc.d/init/00-banner
echo " "
echo " "
echo "ASP.NET Core版本：DOTNET_ASPNETCORE_VERSION | SQL Server版本：2022"
echo "Cron 计划任务：$([ "${ENABLE_CRON}" = "true" ] && echo "[已启用]" || echo "<未启用>")"
echo "==========================================="
