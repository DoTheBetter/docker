#!/command/with-contenv bash

echo "+正在运行初始化任务..."

# -----------------------------------------------------------------------------
# 环境变量检查
# -----------------------------------------------------------------------------
echo "0.检查必需的环境变量..."

# 定义必需的环境变量列表
REQUIRED_ENV_VARS=(
    "WEB_URLS"
    "MSSQL_SA_PASSWORD"
    "MSSQL_DB_NAME"
    "DOTNET_INDEX_NAME"
)

# 检查每个必需的环境变量
MISSING_VARS=()
for var in "${REQUIRED_ENV_VARS[@]}"; do
    # 显示每个变量的值
    #echo "$var: ${!var}"
    if [[ -z "${!var}" ]]; then
        MISSING_VARS+=("$var")
    fi
done

# 如果有缺失的环境变量，显示错误信息并退出
if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    echo "错误：以下必需的环境变量未设置："
    for var in "${MISSING_VARS[@]}"; do
        echo "  - $var"
    done
    echo "请设置这些环境变量后重新启动容器。"
    echo "容器启动失败，退出..."
    exit 1
fi

echo "所有必需的环境变量已正确设置。"

# -----------------------------------------------------------------------------
# 系统时区配置
# -----------------------------------------------------------------------------
echo "1. 设置系统时区"
echo "${TZ}" > /etc/timezone
ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# -----------------------------------------------------------------------------
# MSSQL 配置
# -----------------------------------------------------------------------------
echo "2. 设置 MSSQL 相关..."
# MSSQL 目录结构
MSSQL_BASE_DIR="/data/mssql"
MSSQL_INITDB_DIR="${MSSQL_BASE_DIR}/initdb"
MSSQL_BACKUP_DIR="${MSSQL_BASE_DIR}/backup"

# 需要检查和创建的相关目录
MSSQL_REQUIRED_DIRS=(
    "${MSSQL_INITDB_DIR}"
    "${MSSQL_BACKUP_DIR}"
)
# 确保所有必需的MSSQL目录存在
for dir in "${MSSQL_REQUIRED_DIRS[@]}"; do
    if [[ ! -d "${dir}" ]]; then
        mkdir -p "${dir}"
    fi
done
chown -R mssql:mssql "${MSSQL_BASE_DIR}"

# 检查目标是否已经是正确的符号链接
MSSQL_DEFAULT_DIR="/var/opt/mssql"
if [ -L "${MSSQL_DEFAULT_DIR}" ]; then
    # 是符号链接，检查指向是否正确
    if [ "$(readlink "${MSSQL_DEFAULT_DIR}")" = "${MSSQL_BASE_DIR}" ]; then
        echo "${MSSQL_DEFAULT_DIR} 已正确链接到 ${MSSQL_BASE_DIR}，无需操作。"
    else
        echo "${MSSQL_DEFAULT_DIR} 是一个符号链接，但指向 $(readlink "${MSSQL_DEFAULT_DIR}")，而非 ${MSSQL_BASE_DIR}。正在重新创建……"
        rm -f "${MSSQL_DEFAULT_DIR}"
        ln -sf "${MSSQL_BASE_DIR}" "${MSSQL_DEFAULT_DIR}"
        echo "符号链接已更新：${MSSQL_DEFAULT_DIR} → ${MSSQL_BASE_DIR}"
    fi
elif [ -d "${MSSQL_DEFAULT_DIR}" ]; then
    # 是普通目录
    if [ -n "$(ls -A "${MSSQL_DEFAULT_DIR}" 2>/dev/null)" ]; then
        # 目录非空，备份后替换（谨慎操作）
        BACKUP="${MSSQL_DEFAULT_DIR}.bak-$(date +%s)"
        echo "${MSSQL_DEFAULT_DIR} 是一个非空目录，为避免数据丢失，正在备份为 ${BACKUP}……"
        mv "${MSSQL_DEFAULT_DIR}" "${BACKUP}"
        ln -sf "${MSSQL_BASE_DIR}" "${MSSQL_DEFAULT_DIR}"
        echo "已创建符号链接：${MSSQL_DEFAULT_DIR} → ${MSSQL_BASE_DIR}（原始内容已备份）"
    else
        # 目录为空，安全删除并创建链接
        rmdir "${MSSQL_DEFAULT_DIR}"
        ln -sf "${MSSQL_BASE_DIR}" "${MSSQL_DEFAULT_DIR}"
        echo "已创建符号链接：${MSSQL_DEFAULT_DIR} → ${MSSQL_BASE_DIR}"
    fi
else
    # ${MSSQL_DEFAULT_DIR} 不存在或为普通文件
    if [ -e "${MSSQL_DEFAULT_DIR}" ]; then
        # 是普通文件（非目录、非链接）
        echo "${MSSQL_DEFAULT_DIR} 存在但不是目录或链接，正在删除……"
        rm -f "${MSSQL_DEFAULT_DIR}"
    fi
    # 创建符号链接
    ln -sf "${MSSQL_BASE_DIR}" "${MSSQL_DEFAULT_DIR}"
    echo "已创建符号链接：${MSSQL_DEFAULT_DIR} → ${MSSQL_BASE_DIR}"
fi

# -----------------------------------------------------------------------------
# Redis 配置
# -----------------------------------------------------------------------------
echo "3. 设置 Redis 相关..."

# Redis 目录结构
REDIS_BASE_DIR="/data/redis"

# 需要检查和创建的Redis目录
REDIS_REQUIRED_DIRS=(
    "${REDIS_BASE_DIR}"
)
# 确保所有必需的Redis目录存在
for dir in "${REDIS_REQUIRED_DIRS[@]}"; do
    if [[ ! -d "${dir}" ]]; then
        mkdir -p "${dir}"
    fi
done

# 检查redis.conf配置文件是否存在
if [[ ! -f "${REDIS_BASE_DIR}/redis.conf" ]]; then
    cp "/etc/redis/redis.conf" "${REDIS_BASE_DIR}/redis.conf"
    echo "Redis 配置文件已创建: ${REDIS_BASE_DIR}/redis.conf"
    
    # 生成随机 Redis 密码
    REDIS_PASSWORD=$(head -c 32 /dev/urandom | base64 | tr -d '=+/' | cut -c1-32)
    
    # 更新 Redis 配置
    set_redis_config() {
        local key="${1}"
        local value="${2}"
        local conf_file="${REDIS_BASE_DIR}/redis.conf"
        
        if grep -qE "^[[:space:]]*${key}[[:space:]]+" "${conf_file}"; then
            # 配置项已存在，根据值是否为 空来替换
            if [[ -z "${value}" ]]; then
                sed -i "s|^[[:space:]]*${key}[[:space:]]\+.*|${key} \"\"|g" "${conf_file}"
            else
                sed -i "s|^[[:space:]]*${key}[[:space:]]\+.*|${key} ${value}|g" "${conf_file}"
            fi
        else
            # 配置项不存在，根据值是否为 空来添加
            if [[ -z "${value}" ]]; then
                echo "${key} \"\"" >> "${conf_file}"
            else
                echo "${key} ${value}" >> "${conf_file}"
            fi
        fi
    }
    set_redis_config "dir" "${REDIS_BASE_DIR}"
    set_redis_config "pidfile" "${REDIS_BASE_DIR}/redis_6379.pid"
    set_redis_config "bind" "0.0.0.0"
    set_redis_config "port" "6379"
    set_redis_config "appendonly" "yes"
    set_redis_config "appendfilename" "appendonly.aof"
    set_redis_config "requirepass" "${REDIS_PASSWORD}"
    set_redis_config "daemonize" "no"
    set_redis_config "logfile" ""
    set_redis_config "loglevel" "notice"
else
    echo "Redis 已初始化，跳过初始化步骤"
fi

chown -R redis:redis "${REDIS_BASE_DIR}"
chmod 700 "${REDIS_BASE_DIR}"
chmod 600 "${REDIS_BASE_DIR}/redis.conf"
# ------------------------------------------------------------------------------
# .NET 应用程序配置
# ------------------------------------------------------------------------------
echo "4. 设置 .NET 应用程序相关..."

# 应用程序目录结构
APP_BASE_DIR="/data/app"
# 需要检查和创建的应用程序目录
APP_REQUIRED_DIRS=(
    "${APP_BASE_DIR}"
)
# 确保所有必需的应用程序目录存在
for dir in "${APP_REQUIRED_DIRS[@]}"; do
    if [[ ! -d "${dir}" ]]; then
        mkdir -p "${dir}"
    fi
done

# 设置 dotnetuser 用户和用户组的 UID/GID
if [[ -n "${DOTNET_UID}" && -n "${DOTNET_GID}" ]]; then
    echo "检查 dotnetuser 用户 UID/GID 配置..."
    
    # 检查用户组GID是否需要修改
    CURRENT_GID=$(getent group dotnetuser | cut -d: -f3)
    if [[ "${CURRENT_GID}" != "${DOTNET_GID}" ]]; then
        echo "修改 dotnetuser 用户组 GID: ${CURRENT_GID} -> ${DOTNET_GID}"
        groupmod -g "${DOTNET_GID}" dotnetuser
    else
        echo "dotnetuser 用户组 GID 已正确设置: ${DOTNET_GID}"
    fi
    
    # 检查用户UID是否需要修改
    CURRENT_UID=$(id -u dotnetuser)
    if [[ "${CURRENT_UID}" != "${DOTNET_UID}" ]]; then
        echo "修改 dotnetuser 用户 UID: ${CURRENT_UID} -> ${DOTNET_UID}"
        usermod -u "${DOTNET_UID}" dotnetuser
    else
        echo "dotnetuser 用户 UID 已正确设置: ${DOTNET_UID}"
    fi
else
    echo "未设置 DOTNET_UID/DOTNET_GID 环境变量，使用默认用户配置"
fi

# appsettings.json 文件检查和替换
APP_CONFIG_FILE="${APP_BASE_DIR}/appsettings.json"
#appsettings.json 文件存在
if [[ -f "${APP_CONFIG_FILE}" ]]; then
    # 获取 Redis 密码
    get_redis_password() {
        local conf_file="${REDIS_BASE_DIR}/redis.conf"
        grep -v '^#' "${conf_file}" | \
        grep -i '^[[:space:]]*requirepass' | \
        awk '{print $2}' | \
        tr -d '\r\n' | head -n1
    }
    REDIS_PASSWORD=$(get_redis_password)
    
    # === 定义 Kestrel 新值:从 ASPNETCORE_URLS 提取端口，失败或为空时默认为 8080===
    APP_PORT="8080"  # 默认值
    if [ -n "${ASPNETCORE_URLS:-}" ]; then
        # 尝试提取第一个 http:// URL 的末尾数字作为端口
        extracted_port=$(echo "$ASPNETCORE_URLS" | grep -o 'http://[^;]*' | head -n1 | grep -o '[0-9]*$')
        if [ -n "$extracted_port" ]; then
            APP_PORT="$extracted_port"
        fi
    fi
    Kestrel_HTTP_URL="http://*:$(printf '%s' "$APP_PORT")"

    # === 定义 RedisInfo 新值 ===
    RedisInfo_CONNTEXT="127.0.0.1:6379,password=${REDIS_PASSWORD}"
    
    # === 定义 DBInfo 新值 ===
    DBInfo_CONNTEXT="Data Source=127.0.0.1,1433;Initial Catalog=${MSSQL_DB_NAME};Persist Security Info=True;User ID=sa;Password=${MSSQL_SA_PASSWORD};TrustServerCertificate=True;"
    DBInfo_ASSEMBLY="HLP_DAL_SQLServer"
    DBInfo_DBTYPE="SQLServer"
    DBInfo_DESC="MSSQL"

    # === 定义 SystemUrl 新值: 从 WEB_URLS 获取 SystemUrl===
    SystemUrl_VALUE="${WEB_URLS}"
    
    # === 转义函数：用于 sed 替换字符串中的 / & \ ===
    escape_sed() {
        printf '%s\n' "$1" | sed 's/[&/\]/\\&/g'
    }
    
    # === 执行替换 ===
    sed -i "
    # --- 更新 Kestrel HTTP 端点 ---
    /\"Kestrel\": *{/,/}/ {
        s|\"Url\": *\"http://\\*:[0-9]*\"|\"Url\": \"$(escape_sed "$Kestrel_HTTP_URL")\"|
    }
    
    # --- 更新 RedisInfo ---
    /\"RedisInfo\": *{/,/}/ {
        s|\"ConnText\": *\"[^\"]*\"|\"ConnText\": \"$(escape_sed "$RedisInfo_CONNTEXT")\"|
    }
    
    # --- 更新 DBInfo ---
    /\"DBInfo\": *{/,/}/ {
        s|\"ConnText\": *\"[^\"]*\"|\"ConnText\": \"$(escape_sed "$DBInfo_CONNTEXT")\"|
        s|\"AssemblyName\": *\"[^\"]*\"|\"AssemblyName\": \"$(escape_sed "$DBInfo_ASSEMBLY")\"|
        s|\"DBType\": *\"[^\"]*\"|\"DBType\": \"$(escape_sed "$DBInfo_DBTYPE")\"|
        s|\"Description\": *\"[^\"]*\"|\"Description\": \"$(escape_sed "$DBInfo_DESC")\"|
    }
    
    # --- 更新 SystemUrl（来自 WEB_URLS，默认 http://localhost:8083）---
    s|\"SystemUrl\": *\"[^\"]*\"|\"SystemUrl\": \"$(escape_sed "$SystemUrl_VALUE")\"|
    " "${APP_CONFIG_FILE}"
        
fi

# 设置应用程序目录权限
chown -R dotnetuser:dotnetuser "${APP_BASE_DIR}"
chmod -R 700 "${APP_BASE_DIR}"

# ------------------------------------------------------------------------------
# Cron 计划任务配置
# ------------------------------------------------------------------------------
echo "5. Cron 计划任务相关..."

if [[ "${ENABLE_CRON}" == "true" ]]; then
    echo "数据库定时备份任务已启用"
    
    # 检查 CRON_SCHEDULE 环境变量
    if [[ -z "${CRON_SCHEDULE:-}" ]]; then
        echo "错误：未设置 CRON_SCHEDULE 环境变量。" >&2
        echo "请设置 CRON_SCHEDULE（例如：\"0 2 * * *\"）。" >&2
        exit 1
    fi

    # 配置 cron 任务
    envsubst < /buildtmp/crontab.template > /etc/cron.d/db-backups-cron
    chmod 0644 /etc/cron.d/db-backups-cron
    crontab /etc/cron.d/db-backups-cron
    
    # 只导出需要的环境变量（按前缀过滤），导出时自动加单引号并使用 export，避免 glob expansion
    printenv | grep -E '^(PATH|LANG|LC_ALL|MSSQL_|CRON_)' | while IFS= read -r line; do
        [[ "$line" == *=* ]] || continue
        
        key="${line%%=*}"
        value="${line#*=}"
        
        # 判断是否为空值
        if [ -z "$value" ]; then
            # 输出 export KEY=''
            printf "export %s=''\n" "$key"
        else
            # 处理非空值（含转义）
            escaped_value="${value//\'/\'\\\'\'}"
            printf "export %s='%s'\n" "$key" "$escaped_value"
        fi
    done > /buildtmp/cron.env
    chmod 0600 /buildtmp/cron.env

    echo "计划调度时间：${CRON_SCHEDULE}，时区：${TZ}，当前时间：$(date)"

else
    echo "数据库定时备份任务已被禁用"
    if [ -f /buildtmp/cron.env ]; then
        rm -f /buildtmp/cron.env
    fi
    crontab -r 2>/dev/null || echo "没有要删除的计划任务"
fi
