#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/"$TZ" /etc/localtime
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
# GEOIPUPDATE_FREQUENCY非法（空/0/全零如00/非数字/负数）时回退默认值72（防止run服务sleep失败进入忙循环）
if ! printf '%s' "$GEOIPUPDATE_FREQUENCY" | grep -Eq '^[1-9][0-9]*$'; then
    echo "==>警告:GEOIPUPDATE_FREQUENCY='${GEOIPUPDATE_FREQUENCY}'非法（须为正整数），已回退默认值72"
    GEOIPUPDATE_FREQUENCY=72
fi
# GEOIPUPDATE_EDITION_IDS为空时回退默认值GeoLite2-Country
if [ -z "$GEOIPUPDATE_EDITION_IDS" ]; then
    echo "==>警告:GEOIPUPDATE_EDITION_IDS未设置，已回退默认值GeoLite2-Country"
    GEOIPUPDATE_EDITION_IDS=GeoLite2-Country
fi
# GEOIPUPDATE_DL_URL为空时回退默认镜像源（P3TERX/GeoLite.mmdb，免账号下载）
if [ -z "$GEOIPUPDATE_DL_URL" ]; then
    echo "==>警告:GEOIPUPDATE_DL_URL未设置，已回退默认值https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download"
    GEOIPUPDATE_DL_URL=https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download
fi
# 回退结果写回s6-overlay容器环境目录（/run/s6/container_environment，with-contenv脚本启动时自动读取，无需source；printf避免尾随换行）
printf '%s' "$GEOIPUPDATE_FREQUENCY" > /run/s6/container_environment/GEOIPUPDATE_FREQUENCY
printf '%s' "$GEOIPUPDATE_EDITION_IDS" > /run/s6/container_environment/GEOIPUPDATE_EDITION_IDS
printf '%s' "$GEOIPUPDATE_DL_URL" > /run/s6/container_environment/GEOIPUPDATE_DL_URL

echo "4.生成GeoIP插件配置"
# 生成 caddy-geo-ops 插件配置片段，供 Caddyfile 的 options 块 import 引入
# 此处由脚本把环境变量实际值写入片段文件（不暴露在主 Caddyfile），环境变量变更后重启即生效
GEO_OPS_FILE=/config/geoopts.caddy
{
    echo "# caddy-geo-ops 插件配置（由 init 脚本根据环境变量自动生成，勿手动修改）"
    echo "# 用法：在 Caddyfile 全局 options 块内使用 import /config/geoopts.caddy 引入"
    echo "# db_path：GeoIP 数据库目录（mmdb 库由 geoipupdate 服务与插件 auto_update 统一管理，文件变更自动热重载）"
    echo "geo_ops {"
    echo "    db_path /data/GeoIP"

    if [ -n "$GEOIPUPDATE_ACCOUNT_ID" ] && [ -n "$GEOIPUPDATE_LICENSE_KEY" ]; then
        echo "    # 已配置 MaxMind 凭证，启用官方协议定时自动更新（频率取自 GEOIPUPDATE_FREQUENCY）"
        echo "    auto_update"
        echo "    update_frequency ${GEOIPUPDATE_FREQUENCY}h"
        echo "    account_id ${GEOIPUPDATE_ACCOUNT_ID}"
        echo "    license_key ${GEOIPUPDATE_LICENSE_KEY}"
    else
        echo "    # 未配置 MaxMind 凭证：仅加载库供 {geo.*} 匹配，不启用自动更新"
    fi
    echo "}"
} > "$GEO_OPS_FILE"
chmod 600 "$GEO_OPS_FILE"  # 片段可能含密钥，收紧权限
echo "==>已生成geo_ops插件配置：$GEO_OPS_FILE"

echo "5.生成Geo过滤片段"
# 生成 geo 过滤逻辑片段（反向定义“拒绝”规则：放行请求不匹配 @denied 而自然 fall through 到站点后续 handler），供站点 handle 内 import 引入
# 放在独立文件以规避 caddy-docker-proxy 重序列化对 heredoc 空行 / 空 handle 块的破坏
GEO_FILTER_FILE=/config/geofilter.caddy
# GEOFILTER_COUNTRIES为空时回退默认值CN（否则会生成末尾无值的非法matcher导致Caddy启动失败）
if [ -z "$GEOFILTER_COUNTRIES" ]; then
    echo "==>警告:GEOFILTER_COUNTRIES未设置，已回退默认值CN"
    GEOFILTER_COUNTRIES=CN
fi
countries=$(echo "$GEOFILTER_COUNTRIES" | tr ',' ' ')
{
    echo "# geo 过滤逻辑（由 init 脚本根据环境变量自动生成，勿手动修改）"
    echo "# 用法：在站点 handle 内使用 import /config/geofilter.caddy 引入"
    echo "# 放行规则：放行国家码（GEOFILTER_COUNTRIES）+ 白名单 IP/CIDR（GEOFILTER_WHITELIST），其余请求返回 403"
    echo "# 先加载 geo_ops handler，使 {geo.*} 占位符可用"
    echo "geo_ops"
    echo "# 拒绝 matcher：既不在放行国家、也不在白名单内的请求"
    echo "@denied {"
    echo "    not geo_ops geolite2-country.country.iso_code $countries"
    if [ -n "$GEOFILTER_WHITELIST" ]; then
        whitelist=$(echo "$GEOFILTER_WHITELIST" | tr ',' ' ')
        echo "    not remote_ip $whitelist"
    fi
    echo "}"

    echo "# 对 @denied 命中的请求返回 403；放行请求自然 fall through 到站点后续 handler"
    echo "handle @denied {"
    echo '    header Content-Type "text/html; charset=utf-8"'
    echo '    respond <<HTML'
    echo '        <!DOCTYPE html>'
    echo '        <html>'
    echo '        <head><meta charset="utf-8"><title>Access restricted</title></head>'
    echo '        <body style="font-family:sans-serif;text-align:center;padding-top:80px">'
    echo '            <h1>403 Access restricted</h1>'
    echo '            <p>Your IP: {client_ip} ({geo.geolite2-country.country.names.en})</p>'
    echo '        </body>'
    echo '        </html>'
    echo '    HTML 403'
    echo '}'
} > "$GEO_FILTER_FILE"
chmod 644 "$GEO_FILTER_FILE"
echo "==>已生成geo过滤片段：$GEO_FILTER_FILE"

echo "6.GeoIP数据库初始下载"
# 目录为空时从镜像源（GEOIPUPDATE_DL_URL，已在第3步校验非空）下载全部edition，确保caddy启动时geo_ops即可加载mmdb
# 下载函数：临时文件+大小校验（正常mmdb库远大于1MB）+原子替换，失败保留原文件（不影响启动）
GEOIP_DB_DIR=${XDG_DATA_HOME}/GeoIP
# 下载数据库
geoip_download() {
    edition=$1
    db_name=$(echo "$edition" | tr 'A-Z' 'a-z')
    db_file=$GEOIP_DB_DIR/${db_name}.mmdb
    tmp_file=$GEOIP_DB_DIR/.${db_name}.mmdb.tmp
    if timeout 120 curl -fSL --retry 3 --connect-timeout 30 -o "$tmp_file" "$GEOIPUPDATE_DL_URL/${edition}.mmdb" && [ "$(wc -c < "$tmp_file")" -gt 1000000 ]; then
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
