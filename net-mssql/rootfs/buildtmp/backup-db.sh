#!/usr/bin/env bash

# 数据库备份脚本
# 用于定时备份MSSQL数据库

# 设置变量
MSSQL_BASE_DIR="/data/mssql"
MSSQL_BACKUP_DIR="${MSSQL_BASE_DIR}/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${MSSQL_BACKUP_DIR}/[cron]backup_${MSSQL_DB_NAME}_${TIMESTAMP}.bak"
LOG_PREFIX="[$(date +"%Y-%m-%d %H:%M:%S")]"

# 检查必要环境变量是否存在
if [ -z "${MSSQL_DB_NAME+x}" ]; then
    echo "${LOG_PREFIX} 错误: MSSQL_DB_NAME 未设置" >&2
    exit 1
fi

if [ -z "${MSSQL_SA_PASSWORD+x}" ]; then
    echo "${LOG_PREFIX} 错误: MSSQL_SA_PASSWORD 未设置" >&2
    exit 1
fi

CRON_RETAIN_RECENT_DAYS=${CRON_RETAIN_RECENT_DAYS:-60}
CRON_RETAIN_MONTHLY_MONTHS=${CRON_RETAIN_MONTHLY_MONTHS:-6}

if ! [[ "$CRON_RETAIN_RECENT_DAYS" =~ ^[0-9]+$ ]] || ! [[ "$CRON_RETAIN_MONTHLY_MONTHS" =~ ^[0-9]+$ ]]; then
    echo "${LOG_PREFIX} 错误: 保留策略必须为非负整数" >&2
    exit 1
fi

# ==============================
# 开始备份数据库
# ==============================

echo "${LOG_PREFIX} 开始备份数据库: ${MSSQL_DB_NAME}"

# 定义重试参数
MAX_RETRIES=3
RETRY_DELAY=600  # 10分钟（秒）

# 检查数据库是否存在
check_database_exists() {
    local db_exists=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -h -1 -W -b \
        -Q "SET NOCOUNT ON;
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM sys.databases WHERE name = N'${MSSQL_DB_NAME}'
            ) THEN 'EXISTS' ELSE 'NOT_EXISTS' END;" 2>/dev/null)
    
    if [ "$db_exists" != "EXISTS" ]; then
        echo "${LOG_PREFIX} 错误: 数据库 '${MSSQL_DB_NAME}' 不存在!"
        return 1
    fi
    return 0
}

# 兼容性检查：判断特定列是否存在
check_column_exists() {
    local table_name="$1"
    local column_name="$2"
    
    local column_exists=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -h -1 -W -b \
        -Q "SET NOCOUNT ON;
            SELECT CASE WHEN EXISTS (
                SELECT 1 FROM sys.columns 
                WHERE object_id = OBJECT_ID('$table_name') 
                AND name = '$column_name'
            ) THEN 'EXISTS' ELSE 'NOT_EXISTS' END;" 2>/dev/null)
    
    [ "$column_exists" = "EXISTS" ]
}

# 全面的数据库状态检查
check_database_status() {
    # 首先检查数据库是否存在
    if ! check_database_exists; then
        return 1
    fi

    # 构建兼容性查询
    local query="SET NOCOUNT ON;
        SELECT 
            d.name,
            d.state_desc,
            d.user_access_desc,
            d.is_read_only,
            DATABASEPROPERTYEX(d.name, 'Collation') as collation,
            DATABASEPROPERTYEX(d.name, 'Updateability') as updateability,
            DATABASEPROPERTYEX(d.name, 'Status') as status_property"

    # 动态添加兼容性列
    if check_column_exists "sys.databases" "is_in_recovery"; then
        query="$query, d.is_in_recovery"
    else
        query="$query, CAST(NULL AS BIT) as is_in_recovery"
    fi
    
    if check_column_exists "sys.databases" "recovery_model_desc"; then
        query="$query, d.recovery_model_desc"
    else
        query="$query, CAST(NULL AS NVARCHAR(60)) as recovery_model_desc"
    fi

    query="$query FROM sys.databases d WHERE d.name = N'${MSSQL_DB_NAME}';"

    # 执行查询获取数据库状态
    local db_status=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -h -1 -W -s "|" \
        -Q "$query" 2>/dev/null)
    
    if [ -z "$db_status" ] || [ "$db_status" = "name|state_desc|user_access_desc|is_read_only|collation|updateability|status_property|is_in_recovery|recovery_model_desc" ]; then
        echo "${LOG_PREFIX} 错误: 无法获取数据库 '${MSSQL_DB_NAME}' 的状态信息!"
        return 1
    fi

    # 解析状态信息
    local state_desc=$(echo "$db_status" | cut -d'|' -f2)
    local user_access=$(echo "$db_status" | cut -d'|' -f3)
    local is_read_only=$(echo "$db_status" | cut -d'|' -f4)
    local collation=$(echo "$db_status" | cut -d'|' -f5)
    local updateability=$(echo "$db_status" | cut -d'|' -f6)
    local status_property=$(echo "$db_status" | cut -d'|' -f7)
    local is_in_recovery=$(echo "$db_status" | cut -d'|' -f8 2>/dev/null)

    # 详细的备份前状态检查
    local error_messages=()

    # 1. 检查数据库状态
    if [ "$state_desc" != "ONLINE" ]; then
        error_messages+=("数据库状态为 '$state_desc'，需要为 'ONLINE'")
    fi

    # 2. 检查用户访问模式
    if [ "$user_access" != "MULTI_USER" ]; then
        error_messages+=("用户访问模式为 '$user_access'，需要为 'MULTI_USER'")
    fi

    # 3. 检查是否只读
    if [ "$is_read_only" = "1" ]; then
        error_messages+=("数据库处于只读模式")
    fi

    # 4. 检查可更新性
    if [ "$updateability" != "READ_WRITE" ]; then
        error_messages+=("数据库可更新性为 '$updateability'，需要为 'READ_WRITE'")
    fi

    # 5. 检查状态属性
    if [ "$status_property" != "ONLINE" ]; then
        error_messages+=("数据库状态属性为 '$status_property'，需要为 'ONLINE'")
    fi

    # 6. 检查是否在恢复中（如果列存在）
    if [ -n "$is_in_recovery" ] && [ "$is_in_recovery" = "1" ]; then
        error_messages+=("数据库正在恢复中")
    fi

    # 7. 检查元数据是否加载
    if [ -z "$collation" ] || [ "$collation" = "NULL" ]; then
        error_messages+=("数据库元数据未完全加载")
    fi

    # 如果有错误，输出详细信息
    if [ ${#error_messages[@]} -gt 0 ]; then
        echo "${LOG_PREFIX} 数据库 '${MSSQL_DB_NAME}' 状态检查失败:"
        printf "  - %s\n" "${error_messages[@]}"
        echo "${LOG_PREFIX} 详细状态信息:"
        echo "    State: $state_desc, User Access: $user_access, ReadOnly: $is_read_only"
        echo "    Updateability: $updateability, Status: $status_property, Collation: $collation"
        if [ -n "$is_in_recovery" ]; then
            echo "    In Recovery: $is_in_recovery"
        fi
        return 2
    fi

    # 最终验证：实际查询测试
    echo "${LOG_PREFIX} 执行最终查询验证..."
    if ! sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d "${MSSQL_DB_NAME}" -C -b \
        -Q "SET NOCOUNT ON; BEGIN TRY SELECT 1 AS test_result; END TRY BEGIN CATCH THROW; END CATCH;" >/dev/null 2>&1; then
        echo "${LOG_PREFIX} 错误: 数据库 '${MSSQL_DB_NAME}' 状态显示正常，但无法执行查询"
        return 3
    fi

    # 额外检查：是否有活动事务阻塞备份
    local active_transactions=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -h -1 -W -b \
        -Q "SET NOCOUNT ON;
            SELECT COUNT(*) 
            FROM sys.dm_tran_active_transactions at
            INNER JOIN sys.dm_tran_database_transactions dt ON at.transaction_id = dt.transaction_id
            WHERE dt.database_id = DB_ID('${MSSQL_DB_NAME}');" 2>/dev/null)
    
    if [ -n "$active_transactions" ] && [ "$active_transactions" -gt 100 ]; then
        echo "${LOG_PREFIX} 警告: 数据库中有 $active_transactions 个活动事务，可能会影响备份性能"
    fi

    echo "${LOG_PREFIX} 数据库状态检查通过"
    return 0
}

# 带重试机制的数据库状态检查
echo "${LOG_PREFIX} 检查数据库连接和状态..."
RETRY_COUNT=0
CHECK_RESULT=1

# 首先测试基本连接
if ! sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1;" >/dev/null 2>&1; then
    echo "${LOG_PREFIX} 错误: 无法连接到 SQL Server"
    exit 1
fi

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ $CHECK_RESULT -ne 0 ]; do
    if [ $RETRY_COUNT -gt 0 ]; then
        echo "${LOG_PREFIX} 等待 ${RETRY_DELAY} 秒后进行第 $((RETRY_COUNT + 1)) 次重试..."
        sleep $RETRY_DELAY
    fi
    
    check_database_status
    CHECK_RESULT=$?
    
    if [ $CHECK_RESULT -eq 0 ]; then
        echo "${LOG_PREFIX} 数据库检查通过，开始执行备份..."
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "${LOG_PREFIX} 第 ${RETRY_COUNT} 次检查失败，将重试..."
        else
            echo "${LOG_PREFIX} 已达到最大重试次数 ${MAX_RETRIES}，备份任务终止!"
            exit 1
        fi
    fi
done

# 执行备份
# 备份选项说明：
#    FORMAT,          -- 覆盖媒体头，创建新备份集（避免追加到旧备份）
#    INIT,            -- 覆盖现有备份文件（与 FORMAT 配合使用）
#    COMPRESSION,     -- 启用备份压缩（节省空间和 I/O，SQL Server 2008+ 企业版/2016+ 开发者/标准版支持）
#    CHECKSUM,        -- 在备份时计算校验和，用于后续 RESTORE VERIFYONLY 检测损坏
#    STATS = 10;      -- 每完成 10% 显示进度（便于监控）
sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -b -Q "
    BACKUP DATABASE [${MSSQL_DB_NAME}]
    TO DISK = N'${BACKUP_FILE}'
    WITH
        FORMAT,
        INIT,
        COMPRESSION,
        CHECKSUM,
        STATS = 10;
"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_FILE}" 2>/dev/null | cut -f1)
    echo "${LOG_PREFIX} 数据库备份成功: ${BACKUP_FILE} (大小: ${BACKUP_SIZE})"
    
    # 验证备份文件
    echo "${LOG_PREFIX} 验证备份文件..."
    if sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -b -Q "RESTORE VERIFYONLY FROM DISK = N'${BACKUP_FILE}';" >/dev/null 2>&1; then
        echo "${LOG_PREFIX} 备份文件验证成功"
    else
        echo "${LOG_PREFIX} 警告: 备份文件验证失败，但备份已完成"
    fi
else
    echo "${LOG_PREFIX} 数据库备份失败!"
    if [ -f "${BACKUP_FILE}" ]; then
        rm -f "${BACKUP_FILE}"
        echo "${LOG_PREFIX} 已删除失败的备份文件: ${BACKUP_FILE}"
    fi
    exit 1
fi

# 清理 SQL Server 旧备份：保留最近 N 天全量 + 之前 M 个月每月最新一份
# 依赖环境变量：MSSQL_BACKUP_DIR, MSSQL_DB_NAME, LOG_PREFIX

# 若两者均为0，则跳过清理
if [ "$CRON_RETAIN_RECENT_DAYS" -eq 0 ] && [ "$CRON_RETAIN_MONTHLY_MONTHS" -eq 0 ]; then
    echo "${LOG_PREFIX} 保留策略均为0，跳过备份清理。"
else
    # 计算总保留天数上限
    TOTAL_RETENTION_DAYS=$(( CRON_RETAIN_RECENT_DAYS + CRON_RETAIN_MONTHLY_MONTHS * 31 + 1 ))

    echo "${LOG_PREFIX} 开始执行备份清理策略："
    echo "${LOG_PREFIX}   - 保留最近 ${CRON_RETAIN_RECENT_DAYS} 天内所有备份"
    echo "${LOG_PREFIX}   - 之前 ${CRON_RETAIN_MONTHLY_MONTHS} 个月内，每月保留最新1份"
    echo "${LOG_PREFIX}   - 超过约 ${TOTAL_RETENTION_DAYS} 天的备份将被彻底删除"

    TO_DELETE_LIST=$(mktemp)

    # 1. 删除超出总保留窗口的备份（> TOTAL_RETENTION_DAYS 天）
    # 关键修改：转义[和] + 用安全的文件名匹配
    find "${MSSQL_BACKUP_DIR}" -name '\[cron\]backup_*_*.bak' -type f -mtime +${TOTAL_RETENTION_DAYS} >> "$TO_DELETE_LIST"

    # 2. 处理月度保留（关键：用时间戳格式精准定位，不依赖数据库名）
    if [ "${CRON_RETAIN_MONTHLY_MONTHS}" -gt 0 ]; then
        find "${MSSQL_BACKUP_DIR}" -name '\[cron\]backup_*_*.bak' -type f \
            -mtime +${CRON_RETAIN_RECENT_DAYS} -mtime -${TOTAL_RETENTION_DAYS} 2>/dev/null | while read -r file; do

            basename=$(basename "$file")
            # 重点：用时间戳格式匹配（最后8+6位数字）
            if [[ $basename =~ _([0-9]{8})_([0-9]{6})\.bak$ ]]; then
                yyyymmdd="${BASH_REMATCH[1]}"
                hhmmss="${BASH_REMATCH[2]}"
                yyyymm="${yyyymmdd:0:6}"
                full_ts="${yyyymmdd}${hhmmss}"
                echo "${yyyymm}|${full_ts}|$file"
            else
                echo "${LOG_PREFIX} 警告：跳过无效时间戳文件: $file" >&2
            fi
        done | sort -t'|' -k1,1 -k2,2nr | awk -F'|' '
            BEGIN { prev_month = "" }
            {
                if ($1 != prev_month) {
                    prev_month = $1
                } else {
                    print $3  # 同月后续文件标记删除
                }
            }' >> "$TO_DELETE_LIST"
    fi

    # 去重并排序
    sort -u "$TO_DELETE_LIST" -o "$TO_DELETE_LIST"

    # 执行删除
    delete_count=$(wc -l < "$TO_DELETE_LIST" | tr -d ' ')
    if [ "$delete_count" -gt 0 ]; then
        echo "${LOG_PREFIX} 即将删除 ${delete_count} 个旧备份文件："
        while IFS= read -r f; do
            echo "  - $f"
        done < "$TO_DELETE_LIST"

        echo "${LOG_PREFIX} 正在删除旧备份..."
        while IFS= read -r file; do
            [ -f "$file" ] && rm -f "$file"
        done < "$TO_DELETE_LIST"
        echo "${LOG_PREFIX} 旧备份清理完成。"
    else
        echo "${LOG_PREFIX} 没有需要删除的旧备份。"
    fi

    rm -f "$TO_DELETE_LIST"
fi


# 统计 [cron] 和 [update] 两类备份文件数量
BACKUP_COUNT=$(find "${MSSQL_BACKUP_DIR}" -type f \( \
    -name "\[cron\]backup_${MSSQL_DB_NAME}_*.bak" -o \
    -name "\[update\]backup_${MSSQL_DB_NAME}_*.bak" \
\) 2>/dev/null | wc -l)
echo "${LOG_PREFIX} 备份任务完成，当前共有 ${BACKUP_COUNT} 个备份文件"