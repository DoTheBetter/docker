#!/command/with-contenv sh

echo "+正在运行初始化任务..."

echo "1.设置系统时区"
# 设置时区https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
#显示信息
echo "→当前服务器时间:$(date "+%Y-%m-%d %H:%M:%S")"


echo "2.设置访问路径"
# 规范化/校验 BASE_URL，并经 s6 环境目录注入给 caddy

# 规范化：补全首尾斜杠
base=$(printf '%s' "${BASE_URL:-/}" | sed -e 's#^/*#/#' -e 's#/*$#/#')

# 校验：仅允许 URL 路径安全字符（值会进入 HTML 属性与正则）
case "$base" in
    /) ;;
    */../*|*//*) base=/ ;;
    *[!A-Za-z0-9._~/-]*) base=/ ;;
esac

# 产物锚点检查（缺失说明 builder 镜像未用最新代码重建）
if ! grep -q '<base href=' /www/index.html; then
    echo "init-base-url: 错误：/www/index.html 无 <base> 锚点，builder 需用最新代码重建" >&2
fi

# 生成正则安全形式：'.' 转义；根路径时 NOSLASH 为空串（^$ 永不匹配）
base_re=$(printf '%s' "$base" | sed 's/[.]/\\./g')
base_noslash_re=""
if [ "$base" != "/" ]; then
    base_noslash_re=$(printf '%s' "${base%/}" | sed 's/[.]/\\./g')
fi

# 写入 s6 环境目录（内容不带尾随换行）：
# with-contenv 启动的后续服务（svc-caddy）读取到规范化后的值，
# Caddy 在配置加载时展开 {$X} 占位符
#BASE_URL：应用实际挂载的路径前缀，首尾斜杠齐全的“干净”形态。用途：① 写入 <base href="..."> 替换值（告诉浏览器解析相对 URL 的基准）；② 301 重定向的目标地址。
#BASE_URL_RE：同一路径的“正则安全”形态——. 被转义为 \.，供 path_regexp 前缀剥除规则使用。注释：. 是唯一能穿过字符校验的正则元字符，不转义则 /it.tools/ 会误剥 /itXtools/ 的前缀。
#BASE_URL_NOSLASH_RE：去掉尾斜杠的正则形式，用于“补尾斜杠 301 重定向”——用户访问 /it-tools（无斜杠）时，浏览器无法正确解析相对 URL，需重定向到 /it-tools/。
printf '%s' "$base"            > /run/s6/container_environment/BASE_URL
printf '%s' "$base_re"         > /run/s6/container_environment/BASE_URL_RE
printf '%s' "$base_noslash_re" > /run/s6/container_environment/BASE_URL_NOSLASH_RE

echo "→访问路径=$base、正则形式=$base_re、无尾斜杠正则形式='$base_noslash_re'"

echo "3.修改文件夹权限"
chown -R http:http /www
chmod -R 755 /www
chown -R http:http /etc/caddy
chmod 644 /etc/caddy/Caddyfile

