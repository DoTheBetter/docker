#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区 https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
# 显示信息
echo "→当前服务器时间:$(date "+%Y-%m-%d %H:%M:%S")"

echo "2.配置Aria2"
# 变量定义
DOWNLOAD_DIR="/aria2/download"
ARIA2_CONF_DIR="/aria2/config"
ARIA2_CONF="${ARIA2_CONF_DIR}/aria2.conf"
ARIA2_SESSION="${ARIA2_CONF_DIR}/aria2.session"
ARIA2_DHT="${ARIA2_CONF_DIR}/dht.dat"
ARIA2_DHT6="${ARIA2_CONF_DIR}/dht6.dat"
SCRIPT_DIR="/aria2/script"
SCRIPT_CONF="${SCRIPT_DIR}/script.conf"

# 建立文件及文件夹
mkdir -p "${DOWNLOAD_DIR}"
mkdir -p "${ARIA2_CONF_DIR}"

# 检查config文件
if [ ! -f "${ARIA2_CONF}" ]; then
  cp "/aria2/aria2.conf" "${ARIA2_CONF}"
fi
# 检查session文件
if [ ! -f "${ARIA2_SESSION}" ]; then
  touch "${ARIA2_SESSION}"
fi
# 检查dht文件
if [ ! -f "${ARIA2_DHT}" ]; then
  touch "${ARIA2_DHT}"
fi
if [ ! -f "${ARIA2_DHT6}" ]; then
  touch "${ARIA2_DHT6}"
fi

# 修改配置文件
echo "→修改aria2.conf"

# 定义文件修改函数
modify_config() {
    local config_file="$1"
    local config_name="$2"
    local config_value="$3"

    if [ -n "${config_value}" ]; then
        if grep -q "^${config_name}=" "${config_file}"; then
            # 更新已存在的未注释配置行
            sed -i "s|^${config_name}=.*|${config_name}=${config_value}|g" "${config_file}"
        elif grep -q "^#.*${config_name}=" "${config_file}"; then
            # 替换注释行为新的配置行
            sed -i "s|^#.*${config_name}=.*|${config_name}=${config_value}|g" "${config_file}"
        else
            # 如果没有找到任何配置行，则在文件末尾添加
            echo "${config_name}=${config_value}" >> "${config_file}"
        fi
    else
        # 如果没有设置值，注释掉所有未注释的配置行
        sed -i "s|^${config_name}=|#${config_name}=|g" "${config_file}"
    fi
}
# 修改rpc-secret
modify_config "${ARIA2_CONF}" "rpc-secret" "${ARIA2_RPC_SECRET}"
# 修改下载目录配置
modify_config "${ARIA2_CONF}" "dir" "${DOWNLOAD_DIR}"
# 修改file-allocation配置
TMP_FILE="${DOWNLOAD_DIR}/test_allocation"
if fallocate -l 1G "${TMP_FILE}" 2>/dev/null; then
  FILE_ALLOCATION="falloc"
else
  FILE_ALLOCATION="none"
fi
rm -f "${TMP_FILE}"
modify_config "${ARIA2_CONF}" "file-allocation" "${FILE_ALLOCATION}"
# 修改RPC监听端口
modify_config "${ARIA2_CONF}" "rpc-listen-port" "${ARIA2_RPC_LISTEN_PORT}"
# 修改BT监听端口
modify_config "${ARIA2_CONF}" "listen-port" "${ARIA2_BT_LISTEN_PORT}"
modify_config "${ARIA2_CONF}" "dht-listen-port" "${ARIA2_BT_LISTEN_PORT}"
# 修改会话文件
modify_config "${ARIA2_CONF}" "input-file" "${ARIA2_SESSION}"
modify_config "${ARIA2_CONF}" "save-session" "${ARIA2_SESSION}"
# 修改 IPv4 DHT 路由表文件路径
modify_config "${ARIA2_CONF}" "dht-file-path" "${ARIA2_DHT}"
# 根据ENABLE_IPV6环境变量配置IPv6相关选项
if [ "${ENABLE_IPV6}" = "true" ]; then
    echo "→启用IPv6支持"
    modify_config "${ARIA2_CONF}" "disable-ipv6" "false"
    modify_config "${ARIA2_CONF}" "enable-dht6" "true"
    modify_config "${ARIA2_CONF}" "dht-file-path6" "${ARIA2_DHT6}"
else
    echo "→禁用IPv6支持"
    modify_config "${ARIA2_CONF}" "disable-ipv6" "true"
    modify_config "${ARIA2_CONF}" "enable-dht6" "false"
    modify_config "${ARIA2_CONF}" "dht-file-path6" "${ARIA2_DHT6}"
fi
# 修改单服务器最大连接线程数
#modify_config "${ARIA2_CONF}" "max-connection-per-server" "32"
# 增强扩展设置(非官方)
modify_config "${ARIA2_CONF}" "retry-on-400" "true"
modify_config "${ARIA2_CONF}" "retry-on-403" "true"
modify_config "${ARIA2_CONF}" "retry-on-406" "true"
modify_config "${ARIA2_CONF}" "retry-on-unknown" "true"
# 添加额外脚本
# 从 正在下载 到 删除、错误、完成 时触发
modify_config "${ARIA2_CONF}" "on-download-stop" "${SCRIPT_DIR}/delete.sh"
# 下载完成后执行的命令
modify_config "${ARIA2_CONF}" "on-download-complete" "${SCRIPT_DIR}/clean.sh"

echo "→修改额外脚本文件"
modify_config "${SCRIPT_DIR}/core" "ARIA2_CONF_DIR" "${ARIA2_CONF_DIR}"
modify_config "${SCRIPT_DIR}/core" "SCRIPT_CONF" "${SCRIPT_CONF}"

echo "3.配置FileBrowser"
if [ "${ENABLE_FILEBROWSER}" = "true" ]; then
    echo "→修改filebrowser.json"
    FILEBROWSER_CONF="${ARIA2_CONF_DIR}/filebrowser.json"
    if [ ! -f "${FILEBROWSER_CONF}" ]; then
      cp "/aria2/filebrowser_config.json" "${FILEBROWSER_CONF}"
    fi

    # 替换配置文件中的路径
    sed -i "s|[[:space:]]*\"port\":[[:space:]]*[0-9]*|  \"port\": ${FILEBROWSER_PORT}|" "${FILEBROWSER_CONF}"
    sed -i "s|[[:space:]]*\"database\":[[:space:]]*\"[^\"]*\"|  \"database\": \"${ARIA2_CONF_DIR}/filebrowser.db\"|" "${FILEBROWSER_CONF}"
    sed -i "s|[[:space:]]*\"root\":[[:space:]]*\"[^\"]*\"|  \"root\": \"${DOWNLOAD_DIR}\"|" "${FILEBROWSER_CONF}"
else
    echo "→filebrowser服务已禁用"
fi

echo "4.修改文件夹权限"
#修改用户UID GID
groupmod -o -g "$GID" download
usermod -o -u "$UID" download

# 检查配置目录权限
chown -R download:download "${ARIA2_CONF_DIR}"
chmod 755 "${ARIA2_CONF_DIR}"
chmod -R 600 "${ARIA2_CONF_DIR}"/*

# 检查下载目录权限
chown -R download:download "${DOWNLOAD_DIR}"
chmod 755 "${DOWNLOAD_DIR}"

# 检查脚本目录权限
chown -R download:download "${SCRIPT_DIR}"
chmod 755 "${SCRIPT_DIR}"
chmod -R 700 "${SCRIPT_DIR}"/*



