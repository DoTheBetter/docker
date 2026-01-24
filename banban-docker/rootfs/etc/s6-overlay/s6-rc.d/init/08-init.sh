#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区 - Debian方式
echo "${TZ}" > /etc/timezone
ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

echo "2.配置斑斑低代码系统..."
CONFIG_DIR=~/.config
for dir in "${CONFIG_DIR}" "/root/.cache" /app; do
    if [ ! -d "${dir}" ]; then
        mkdir -p "${dir}"
    fi
done

echo "3.修复权限"
if [ -n "${UID}" ] && [ -n "${GID}" ]; then
    echo "检查 banban-user 用户 UID/GID 配置..."

    CURRENT_GID=$(getent group banbanuser-group | cut -d: -f3)
    if [ "${CURRENT_GID}" != "${GID}" ]; then
        echo "修改 banbanuser-group 用户组 GID: ${CURRENT_GID} -> ${GID}"
        groupmod -g "${GID}" banbanuser-group
    else
        echo "banbanuser-group 用户组 GID 已正确设置: ${GID}"
    fi

    CURRENT_UID=$(id -u banban-user)
    if [ "${CURRENT_UID}" != "${UID}" ]; then
        echo "修改 banban-user 用户 UID: ${CURRENT_UID} -> ${UID}"
        usermod -u "${UID}" banban-user
    else
        echo "banban-user 用户 UID 已正确设置: ${UID}"
    fi
else
    echo "未设置 UID/GID 环境变量，使用默认用户配置"
fi

chown -R "${UID}:${GID}" /root
chown -R "${UID}:${GID}" /app
chmod +x /app/banban
