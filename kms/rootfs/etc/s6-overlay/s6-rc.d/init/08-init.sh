#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
#显示信息
echo "→当前服务器时间:$(date "+%Y-%m-%d %H:%M:%S")"

echo "2.配置vlmcsd"
# 建立文件及文件夹
mkdir -p /vlmcsd/config
# 检查config文件
if [ ! -f "/vlmcsd/config/vlmcsd.ini" ]; then
  cp "/vlmcsd/vlmcsd.ini" "/vlmcsd/config/vlmcsd.ini"
fi
# 检查数据文件
if [ ! -f "/vlmcsd/config/vlmcsd.kmd" ]; then
  cp "/vlmcsd/vlmcsd.kmd" "/vlmcsd/config/vlmcsd.kmd"
fi

# 定义文件修改函数
modify_config() {
    local config_file="$1"
    local config_name="$2"
    local config_value="$3"

    if [ -n "${config_value}" ]; then
        if grep -q "^${config_name} =" "${config_file}"; then
            # 更新已存在的未注释配置行
            sed -i "s|^${config_name} = .*|${config_name} = ${config_value}|g" "${config_file}"
        elif grep -q "^;${config_name} =" "${config_file}"; then
            # 替换注释行为新的配置行
            sed -i "s|^;${config_name} = .*|${config_name} = ${config_value}|g" "${config_file}"
        else
            # 如果没有找到任何配置行，则在文件末尾添加
            echo "${config_name} = ${config_value}" >> "${config_file}"
        fi
    else
        # 如果没有设置值，注释掉所有未注释的配置行
        sed -i "s|^${config_name} =|;${config_name} =|g" "${config_file}"
    fi
}
modify_config "/vlmcsd/config/vlmcsd.ini" "DisconnectClientsImmediately" "yes"
modify_config "/vlmcsd/config/vlmcsd.ini" "KmsData" "/vlmcsd/config/vlmcsd.kmd"
modify_config "/vlmcsd/config/vlmcsd.ini" "user" "kms"
modify_config "/vlmcsd/config/vlmcsd.ini" "PidFile" "/vlmcsd/config/vlmcsd.pid"
modify_config "/vlmcsd/config/vlmcsd.ini" "LogFile" "/vlmcsd/config/vlmcsd.log"

echo "3.修改文件夹权限"
#修改用户UID GID
groupmod -o -g "$GID" kms
usermod -o -u "$UID" kms

# 检查配置目录权限
chown -R kms:kms "/vlmcsd/config"
chmod 755 "/vlmcsd/config"
chmod -R 644 "/vlmcsd/config"/*

chown -R http:http /vlmcsd/www
chmod -R 755 /vlmcsd/www
