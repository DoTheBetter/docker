#!/command/with-contenv sh

echo "+ 正在运行初始化任务..."

echo "1. 设置系统时区"
# 设置时区 https://wiki.alpinelinux.org/wiki/Setting_the_timezone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
echo "→ 当前服务器时间: $(date "+%Y-%m-%d %H:%M:%S")"

echo "2. 首次启动时创建用户组"
# ========== 仅首次启动时创建 nut 用户/组（固定 UID/GID） ==========
if ! getent group nut >/dev/null; then
    addgroup -g "${NUT_GID:-1000}" nut
    echo "→ 创建 nut 用户组 (GID: ${NUT_GID:-1000})"
fi

if ! getent passwd nut >/dev/null; then
    adduser -D -H -u "${NUT_UID:-1000}" -G nut -s /sbin/nologin nut
    echo "→ 创建 nut 用户 (UID: ${NUT_UID:-1000})"
fi

# ========== 仅首次启动时创建 http 用户/组（系统自动分配） ==========
if ! getent group http >/dev/null; then
    addgroup http
    echo "→ 创建 http 用户组 (GID: $(getent group http | cut -d: -f3))"
fi

if ! getent passwd http >/dev/null; then
    adduser -D -H -G http -s /sbin/nologin http
    echo "→ 创建 http 用户 (UID: $(id -u http))"
fi

echo "3. nut 相关设置"
# 设置配置文件
# NUT 作为网络 UPS 工具，主要包含几个组件：驱动（upsdrvctl）、服务端（upsd）、监控端（upsmon）等。
# 在 netserver 模式下，应该是要运行 upsd 作为服务器，让其他客户端可以连接到这个服务器获取 UPS 的状态
# ups.conf 配置 UPS 设备，upsd.conf 配置服务器参数，upsd.users 设置用户权限，upsmon.conf 用于监控，nut.conf 设置运行模式等
mkdir -p /conf
cp -rf /nut/etc.bak/* /conf/

if [ ! -e /conf/nut.conf ]; then
    echo "→ 初始定义 NUT 运行模式为 netserver >> nut.conf"
    cat >/conf/nut.conf <<EOF
# 定义 NUT 运行模式
MODE=netserver
EOF
else
    echo "→ 文件存在，跳过 nut.conf 设置"
fi

if [ ! -e /conf/ups.conf ]; then
    echo "→ 初始配置连接的 UPS 设备，指定驱动和参数 >> ups.conf"
    cat >/conf/dummy-ups.dev <<EOF
# /conf/dummy-ups.dev
# 模拟 UPS 定义文件，测试用，正式使用可删除
# ================================================
# Network UPS Tools - Dummy UPS Device Configuration
# 全参数模拟文件，无真实硬件依赖
# ================================================
# ----------------------------
# 基础电源状态参数
# ----------------------------
input.voltage: 230       # 输入电压（伏特）
output.voltage: 230      # 输出电压（伏特）
battery.charge: 100      # 电池电量（0-100%）
battery.charge.low: 20   # 低电量警告阈值（%）
battery.runtime: 3600    # 剩余运行时间（秒）
ups.load: 30             # 当前负载百分比（%）

# ----------------------------
# UPS 状态与模式
# ----------------------------
ups.status: OL           # 状态：OL（在线）, OB（电池供电）
ups.temperature: 25.5    # 内部温度（摄氏度）
ups.realpower.nominal: 600  # 额定功率（瓦）

# ----------------------------
# 延迟与定时控制
# ----------------------------
ups.delay.start: 30      # 市电恢复后启动延迟（秒）
ups.delay.shutdown: 60    # 断电后关机延迟（秒）
ups.timer.shutdown: 300   # 关机倒计时（秒）

# ----------------------------
# 自检与维护参数
# ----------------------------
ups.test.interval: 604800  # 自检间隔（秒，默认7天）
ups.test.result: OK       # 自检结果：OK（正常）, NG（异常）
EOF
    cat >/conf/ups.conf <<EOF
# 配置连接的 UPS 设备，指定驱动和参数
# 可以通过 nut-scanner 命令扫描获得配置信息
# 用法见 https://networkupstools.org/docs/man/nut-scanner.html
# 威联通示例：名称 qnapups 不能改变
#[qnapups]
#        driver = "snmp-ups"
#        port = "192.168.0.99"
#        desc = "Smart-UPS 1500"
#        mibs = "apcc"
#        snmp_version = "v1"
#        community = "public"
#        pollfreq = "15"
#
# 群晖示例：名称 ups 不能改变
#[ups]
#        driver = "snmp-ups"
#        port = "192.168.0.99"
#        desc = "Smart-UPS 1500"
#        mibs = "apcc"
#        snmp_version = "v1"
#        community = "public"
#        pollfreq = "15"
#
# 测试用虚拟 ups
[virtualups]
    driver = dummy-ups
    port = /conf/dummy-ups.dev
    desc = "Virtual UPS for testing"

EOF
else
    echo "→ 文件存在，跳过 ups.conf 设置"
fi

if [ ! -e /conf/upsd.conf ]; then
    echo "→ 初始配置 upsd 监听的地址、端口和会话超时 >> upsd.conf"
    cat >/conf/upsd.conf <<EOF
# 配置 upsd 监听的地址、端口和会话超时
LISTEN 0.0.0.0 3493
MAXAGE 15
EOF
else
    echo "→ 文件存在，跳过 upsd.conf 设置"
fi

if [ ! -e /conf/upsd.users ]; then
    echo "→ 初始定义访问 NUT 服务的用户及其权限 >> upsd.users"
    cat >/conf/upsd.users <<EOF
# 定义访问 NUT 服务的用户及其权限
# 群晖：UPS 标识：ups、用户名：monuser、密码：secret
# 威联通：UPS 标识：qnapups、用户名：admin、密码：123456
[admin]
    password = 123456
    upsmon master
[monuser]
    password = secret
    upsmon master
EOF
else
    echo "→ 文件存在，跳过 upsd.users 设置"
fi

if [ ! -e /conf/upsmon.conf ]; then
    echo "→ 初始配置本地或远程 UPS 监控策略 >> upsmon.conf"
    cat >/conf/upsmon.conf <<EOF
# 配置本地或远程 UPS 监控策略
# MONITOR qnapups@localhost 1 admin 123456 master
MONITOR virtualups@localhost 1 admin 123456 master

# 定义关机命令，由于在容器中运行，改为记录关机事件
SHUTDOWNCMD "/usr/bin/logger -t upsd \"UPS shutdown event triggered\""

# 配置通知标志
NOTIFYFLAG ONLINE SYSLOG
NOTIFYFLAG ONBATT SYSLOG
NOTIFYFLAG LOWBATT SYSLOG
NOTIFYFLAG FSD SYSLOG
NOTIFYFLAG COMMOK SYSLOG
NOTIFYFLAG COMMBAD SYSLOG
NOTIFYFLAG SHUTDOWN SYSLOG
NOTIFYFLAG REPLBATT SYSLOG
NOTIFYFLAG NOCOMM SYSLOG
NOTIFYFLAG NOPARENT SYSLOG
NOTIFYFLAG READY_WITH_PID SYSLOG

# 配置通知命令
NOTIFYCMD "/usr/bin/logger -t upsd \"UPS notification: %i\""
EOF
else
    echo "→ 文件存在，跳过 upsmon.conf 设置"
fi

rm -rf /nut/etc
ln -sf /conf /nut/etc

echo "4. lighttpd 相关设置"
if [ "$WEB" = "true" ]; then
    if [ ! -e /conf/hosts.conf ]; then
        echo "→ 初始定义要监控的 UPS 设备及其描述，供 CGI 页面展示 >> hosts.conf"
        cat >/conf/hosts.conf <<EOF
# 定义要监控的 UPS 设备及其描述，供 CGI 页面（如 upsstats）展示
# 写法：MONITOR <UPS标识@nut server地址> "<描述>"
#MONITOR qnapups@localhost "QNAP"
#MONITOR ups@localhost "Synology"
MONITOR virtualups@localhost "Virtual UPS"
EOF
    else
        echo "→ 文件存在，跳过 hosts.conf 设置"
    fi

    if [ ! -e /conf/upsstats.html ]; then
        echo "→ 复制并重命名 upsstats.html.sample 为 upsstats.html"
        cp /conf/upsstats.html.sample /conf/upsstats.html
    else
        echo "→ 文件 upsstats.html 已存在，跳过复制操作"
    fi

    if [ ! -e /conf/upsstats-single.html ]; then
        echo "→ 复制并重命名 upsstats-single.html.sample 为 upsstats-single.html"
        cp /conf/upsstats-single.html.sample /conf/upsstats-single.html
    else
        echo "→ 文件 upsstats-single.html 已存在，跳过复制操作"
    fi
else
    echo "→ 未设置启动 lighttpd 服务"
fi

echo "5. 修复文件权限"
# nut
mkdir -p /var/run/nut
echo 0 > /var/run/nut/upsd.pid
chown -R nut:nut /var/run/nut
chmod -R 770 /var/run/nut

echo 0 > /run/upsmon.pid

chown -R nut:nut /conf
chmod 755 /conf
find /conf -type f ! -name "*.html" -exec chmod 640 {} +

# lighttpd
if [ "$WEB" = "true" ]; then
    chown -R http:http /nut/cgi-bin
    chmod -R 755 /nut/cgi-bin
    chown http:http /lighttpd.conf
    chmod 644 /lighttpd.conf
    find /conf -type f -name "*.html" -exec chmod 644 {} +
    chmod 644 /conf/hosts.conf
    
else
    echo "→ 未设置启动 lighttpd 服务"
fi