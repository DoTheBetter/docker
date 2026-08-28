#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
#显示信息
echo "→当前服务器时间:$(date "+%Y-%m-%d %H:%M:%S")"


echo "2.配置Caddy2"
# 修复 Alpine + 旧版 Go netgo 颠倒域名解析顺序、/etc/hosts 不生效的经典问题；
[ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

mkdir -p /usr/share/caddy
cp /etc/caddy/index.html /usr/share/caddy/index.html
# 复制默认配置文件
cp -f /etc/caddy/Caddyfile.default $CADDY_DOCKER_CADDYFILE_PATH.default
if [ ! -e $CADDY_DOCKER_CADDYFILE_PATH ];then
    cp /etc/caddy/Caddyfile.default $CADDY_DOCKER_CADDYFILE_PATH
    echo "==>Caddyfile文件已建立。"
else
	echo "==>Caddyfile文件已存在。"
fi

echo "3.GeoIP参数校验"
# GEOIPUPDATE_FREQUENCY非法（空/0/非数字）时回退默认值72（防止run服务sleep失败进入忙循环）
case "$GEOIPUPDATE_FREQUENCY" in
    ''|0|*[!0-9]*)
        echo "==>警告:GEOIPUPDATE_FREQUENCY='${GEOIPUPDATE_FREQUENCY}'非法（须为正整数），已回退默认值72"
        GEOIPUPDATE_FREQUENCY=72
        ;;
esac
# GEOIPUPDATE_EDITION_IDS为空时回退默认值GeoLite2-Country
if [ -z "$GEOIPUPDATE_EDITION_IDS" ]; then
    echo "==>警告:GEOIPUPDATE_EDITION_IDS未设置，已回退默认值GeoLite2-Country"
    GEOIPUPDATE_EDITION_IDS=GeoLite2-Country
fi
# 回退结果写回s6-overlay容器环境目录（/run/s6/container_environment，with-contenv脚本启动时自动读取，无需source；printf避免尾随换行）
printf '%s' "$GEOIPUPDATE_FREQUENCY" > /run/s6/container_environment/GEOIPUPDATE_FREQUENCY
printf '%s' "$GEOIPUPDATE_EDITION_IDS" > /run/s6/container_environment/GEOIPUPDATE_EDITION_IDS

echo "4.GeoIP数据库初始下载"
# 目录为空时从镜像源（P3TERX/GeoLite.mmdb，可用GEOIPUPDATE_DL_URL覆盖）下载全部edition，确保caddy启动时geo_ops即可加载mmdb
# 下载函数：临时文件+大小校验（正常mmdb库远大于1MB）+原子替换，失败保留原文件（不影响启动）
GEOIP_DB_DIR=${XDG_DATA_HOME}/GeoIP
GEOIP_BASE_URL=${GEOIPUPDATE_DL_URL:-https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download}
# 下载数据库
geoip_download() {
    edition=$1
    db_name=$(echo "$edition" | tr 'A-Z' 'a-z')
    db_file=$GEOIP_DB_DIR/${db_name}.mmdb
    tmp_file=$GEOIP_DB_DIR/.${db_name}.mmdb.tmp
    if timeout 120 curl -fSL --retry 3 --connect-timeout 30 -o "$tmp_file" "$GEOIP_BASE_URL/${edition}.mmdb" && [ "$(wc -c < "$tmp_file")" -gt 1000000 ]; then
        mv -f "$tmp_file" "$db_file"
        echo "==>[GeoIP Init] ${db_name}.mmdb 下载成功"
    else
        echo "==>[GeoIP Init] ${db_name}.mmdb 下载失败或校验未通过"
        rm -f "$tmp_file"
        return 1
    fi
}
mkdir -p $GEOIP_DB_DIR
# GEOIPUPDATE_AUTO未开启时跳过初始下载（与geoipupdate/run服务行为一致）
if [ "$GEOIPUPDATE_AUTO" = "true" ]; then
    if ! ls $GEOIP_DB_DIR/*.mmdb >/dev/null 2>&1; then
        echo "==>未检测到GeoIP数据库，开始初始下载..."
        for edition in $(echo $GEOIPUPDATE_EDITION_IDS | tr ',' ' '); do
            geoip_download $edition
        done
    else
        echo "==>已存在GeoIP数据库，跳过初始下载。"
    fi
else
    echo "==>未开启GeoIP Update（GEOIPUPDATE_AUTO!=true），跳过初始下载。"
fi
