#!/command/with-contenv bash
# 日志前缀配置
LOG_PREFIX="[MSSQL-INIT]"

MSSQL_BASE_DIR="/data/mssql"
MSSQL_INITDB_DIR="${MSSQL_BASE_DIR}/initdb"
MSSQL_LOCK_FILE="${MSSQL_INITDB_DIR}/.initialized"
MSSQL_IMPORT_SCRIPT="${MSSQL_INITDB_DIR}/import-initdb-file.sh"
MSSQL_BACKUP_DIR="${MSSQL_BASE_DIR}/backup"


echo "${LOG_PREFIX} 等待 SQL Server 完成所有数据库升级和恢复..."

server_ready=false
i=1
max_wait=450  # 最多等待 450 轮 × 2 秒 = 900 秒（15 分钟）

while [ ${i} -le ${max_wait} ]; do
  if sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d master -Q "SELECT 1;" -C >/dev/null 2>&1; then
    echo "${LOG_PREFIX} SQL Server 可连接，正在检查所有数据库是否均已 ONLINE..."

    # 检查是否有任何数据库（包括系统库和用户库）未处于 ONLINE 状态
    UNREADY_COUNT=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d master -h -1 -W -C -b \
      -Q "SET NOCOUNT ON;
          SELECT COUNT(*)
          FROM sys.databases
          WHERE state_desc != 'ONLINE';" \
      2>/dev/null | tr -d ' ')

    if [ "${UNREADY_COUNT}" = "0" ]; then
      echo "${LOG_PREFIX} 所有数据库均已 ONLINE，SQL Server 初始化完成。"
      server_ready=true
      break
    else
      echo "${LOG_PREFIX} 仍有 ${UNREADY_COUNT} 个数据库未就绪（非 ONLINE 状态）..."
    fi
  else
    echo "${LOG_PREFIX} 尚未能连接到 SQL Server。"
  fi

  if [ $((i % 30)) -eq 0 ]; then
    echo "${LOG_PREFIX} 已等待 $((i * 2)) 秒，SQL Server 仍在初始化中..."
  fi

  sleep 2
  i=$((i + 1))
done

if [ "${server_ready}" = false ]; then
  echo "${LOG_PREFIX} SQL Server 启动超时（超过 $((max_wait * 2)) 秒）！"
  echo "${LOG_PREFIX} 请检查 /var/opt/mssql/log/errorlog 中是否包含升级或恢复错误。"
  exit 1
fi


# 检查是否已初始化
if [ -f "${MSSQL_LOCK_FILE}" ]; then
  echo "${LOG_PREFIX} 检测到锁文件 ${MSSQL_LOCK_FILE}，跳过初始化。"
  exit 0
else
  # 1. 生成数据库导入脚本（仅在未初始化时）
  if [ ! -f "${MSSQL_IMPORT_SCRIPT}" ]; then
    echo "${LOG_PREFIX} 未找到导入脚本，正在生成：${MSSQL_IMPORT_SCRIPT}"
    cat > "${MSSQL_IMPORT_SCRIPT}" << 'EOF'
#!/command/with-contenv bash
# 数据库导入脚本，重命名数据库文件以 initdb. 开头
# 导入文件 "${1}" 到数据库 "${MSSQL_DB_NAME}"
# ${1}为导入文件路径
# 导入时，数据库名从环境变量 ${MSSQL_DB_NAME} 获取，密码从环境变量 ${MSSQL_SA_PASSWORD} 获取
# 必须使用使用 -C 参数：信任自签名证书（保留加密）
# 例：云中忆（yzy）系统可取消注释直接使用
#sqlcmd \
#  -S localhost \
#  -U sa \
#  -P "${MSSQL_SA_PASSWORD}" \
#  -Q "RESTORE DATABASE [${MSSQL_DB_NAME}]
#      FROM DISK = N'${1}'
#      WITH 
#        MOVE 'DB_Build_GZ_BTAXB' TO '/var/opt/mssql/data/${MSSQL_DB_NAME}.mdf',
#        MOVE 'DB_Build_GZ_BTAXB_log' TO '/var/opt/mssql/data/${MSSQL_DB_NAME}_log.ldf',
#        REPLACE,
#        STATS = 5" \
#  -C


EOF
    echo "${LOG_PREFIX} 导入脚本已生成。"
  fi
  chmod +x "${MSSQL_IMPORT_SCRIPT}"
  chown mssql:mssql "${MSSQL_IMPORT_SCRIPT}"

  # 步骤2: 创建目标数据库（如不存在）
  echo "${LOG_PREFIX} 创建数据库 [${MSSQL_DB_NAME}]（如不存在）……"
 
  DB_CREATE_MSG="${LOG_PREFIX} 数据库 [${MSSQL_DB_NAME}] 创建成功。"
  DB_EXISTS_MSG="${LOG_PREFIX} 数据库 [${MSSQL_DB_NAME}] 已存在。"
  
  sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "
  IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'${MSSQL_DB_NAME}')
  BEGIN
      CREATE DATABASE [${MSSQL_DB_NAME}];
      RAISERROR('${DB_CREATE_MSG}', 0, 1) WITH NOWAIT;
  END
  ELSE
  BEGIN
      RAISERROR('${DB_EXISTS_MSG}', 0, 1) WITH NOWAIT;
  END
  "

  if [ $? -ne 0 ]; then
    echo "${LOG_PREFIX} 创建数据库命令执行失败！"
    exit 1
  fi

  #echo "${LOG_PREFIX} 预热数据库 [${MSSQL_DB_NAME}]..."
  sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d "${MSSQL_DB_NAME}" -C -Q "SELECT 1;" >/dev/null 2>&1

  # === 优化：更准确等待数据库完全就绪 ===
  echo "${LOG_PREFIX} 等待数据库 [${MSSQL_DB_NAME}] 完全初始化完成..."
  db_ready=false
  wait_count=0
  max_db_wait=120  # 增加最大等待时间
  
  while [ ${wait_count} -lt ${max_db_wait} ]; do
    # Step 1: 检查数据库是否存在并且状态为 ONLINE
    DB_CHECK=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d "master" -C -h -1 -W \
      -Q "SET NOCOUNT ON;
          SELECT CASE 
              WHEN EXISTS (
                  SELECT 1 FROM sys.databases 
                  WHERE name = N'${MSSQL_DB_NAME}' 
                    AND state_desc = 'ONLINE'
              ) THEN 'EXISTS_ONLINE'
              ELSE 'NOT_READY'
          END;" 2>/dev/null | tr -d ' \r\n')
  
    if [ "$DB_CHECK" = "EXISTS_ONLINE" ]; then
      # Step 2: 验证数据库是否可以正常连接和查询
      # 增加更全面的查询测试
      CONNECTION_TEST=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d "${MSSQL_DB_NAME}" -C \
        -Q "SET NOCOUNT ON; 
            SELECT DB_NAME() AS db_name, 
                   COUNT(*) AS system_tables_count
            FROM sys.tables 
            WHERE schema_id = 4;" -h -1 -W 2>/dev/null | head -n 1 | tr -d ' \r\n')
      
      # 验证系统表可以正常查询
      if [ $? -eq 0 ] && [ -n "$CONNECTION_TEST" ]; then
        echo "${LOG_PREFIX} 数据库 [${MSSQL_DB_NAME}] 已完全就绪（连接测试通过）。"
        db_ready=true
        break
      fi
    fi
  
    # 每10秒输出一次进度信息
    if [ $((wait_count % 5)) -eq 0 ] && [ ${wait_count} -gt 0 ]; then
      echo "${LOG_PREFIX} 等待数据库就绪中...（${wait_count}/120秒）"
    fi
  
    sleep 2
    wait_count=$((wait_count + 1))
  done
  
  if [ "${db_ready}" = false ]; then
    echo "${LOG_PREFIX} 数据库 [${MSSQL_DB_NAME}] 长时间未就绪，请检查 SQL Server 日志。"
    # 显示数据库当前状态用于调试
    DEBUG_STATUS=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d "master" -C \
      -Q "SELECT name, state_desc, is_in_recovery, user_access_desc FROM sys.databases WHERE name = N'${MSSQL_DB_NAME}';" -h -1 -W 2>/dev/null)
    echo "${LOG_PREFIX} 数据库状态信息: ${DEBUG_STATUS}"
    exit 1
  fi
  # === 等待结束 ===

  # 步骤3: 查找 initdb.* 文件
  echo "${LOG_PREFIX} 扫描 ${MSSQL_INITDB_DIR} 下以 'initdb.' 开头的文件……"
  # 使用 POSIX 兼容方式列出文件（避免 mapfile，因非 bash）
  init_files=""
  for f in "${MSSQL_INITDB_DIR}"/initdb.*; do
    # 检查是否为有效文件（避免 glob 无匹配时返回字面值）
    if [ -f "$f" ] && [ "$f" != "${MSSQL_IMPORT_SCRIPT}" ] && [ "$f" != "${MSSQL_LOCK_FILE}" ]; then
      init_files="${init_files}${f}
"
    fi
  done

  # 转换为数组或行列表（POSIX 方式）
  if [ -z "$(echo "${init_files}" | tr -d ' \t\n')" ]; then
    echo "${LOG_PREFIX} 未发现任何 initdb.* 初始化文件，无法完成数据库初始化。"
    exit 1
  fi

  # 计算文件数量（用于日志）
  file_count=$(echo "${init_files}" | grep -v '^$' | wc -l)

  # 步骤4: 备份当前数据库
  echo "${LOG_PREFIX} 找到 ${file_count} 个 initdb.* 文件，开始备份数据库 [${MSSQL_DB_NAME}]..."

  # 先确认可备份（保留原逻辑）
  BACKUP_READY=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -h -1 -W -C \
    -Q "SET NOCOUNT ON; SELECT 'OK' FROM sys.databases WHERE name = N'${MSSQL_DB_NAME}' AND state = 0 AND user_access = 0;" 2>/dev/null)
  if [ "$BACKUP_READY" != "OK" ]; then
    echo "${LOG_PREFIX} 数据库当前不可备份（状态异常或被占用）"
    exit 1
  fi

  BACKUP_FILE="${MSSQL_BACKUP_DIR}/[update]backup_${MSSQL_DB_NAME}_$(date +%Y%m%d_%H%M%S).bak"
  
  # 执行备份（添加 -b 以正确捕获错误）
  sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -b -Q "
      SET LOCK_TIMEOUT 30000;
      BACKUP DATABASE [${MSSQL_DB_NAME}]
      TO DISK = N'${BACKUP_FILE}'
      WITH
          FORMAT,
          INIT,
          COMPRESSION,
          CHECKSUM,
          STATS = 10,
          COPY_ONLY;
  "

  if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} 数据库备份成功：${BACKUP_FILE}"
  else
    echo "${LOG_PREFIX} 警告：数据库备份失败，但将继续处理文件"
  fi

  # 步骤5: 逐个导入文件
  echo "${init_files}" | while IFS= read -r f; do
    [ -z "$f" ] && continue
    basename_f=$(basename "$f")
    echo "${LOG_PREFIX} 处理文件: ${basename_f}"

    # 执行导入
    "${MSSQL_IMPORT_SCRIPT}" "$f"
    import_status=$?
    if [ $import_status -ne 0 ]; then
      echo "${LOG_PREFIX} 初始化失败：${basename_f} 导入出错，容器将退出。"
      exit 1
    fi

    # 验证恢复后状态
    POST_STATE=$(sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -h -1 -W -C \
      -Q "SET NOCOUNT ON; SELECT state_desc FROM sys.databases WHERE name = N'${MSSQL_DB_NAME}';" 2>/dev/null)
    if [ "$POST_STATE" != "ONLINE" ]; then
      echo "${LOG_PREFIX} 恢复后数据库状态异常：${POST_STATE}"
      exit 1
    else
      echo "${LOG_PREFIX} 恢复后数据库 [${MSSQL_DB_NAME}] 状态正常：ONLINE"
    fi

    # 删除已处理文件
    echo "${LOG_PREFIX} 导入成功，正在删除文件：${basename_f}"
    rm -f "$f"
  done

  # 步骤6: 删除导入脚本
  if [ -f "${MSSQL_IMPORT_SCRIPT}" ]; then
    echo "${LOG_PREFIX} 清理导入脚本：${MSSQL_IMPORT_SCRIPT}"
    rm -f "${MSSQL_IMPORT_SCRIPT}"
  fi

  # 步骤7: 创建锁文件，标记完成
  echo "${LOG_PREFIX} 创建初始化完成标记：${MSSQL_LOCK_FILE}"
  touch "${MSSQL_LOCK_FILE}"
  chown mssql:mssql "${MSSQL_LOCK_FILE}"

  if [ -f "${MSSQL_LOCK_FILE}" ]; then
    echo "${LOG_PREFIX} SQL Server 数据库初始化成功完成！"
  else
    echo "${LOG_PREFIX} 无法创建锁文件，初始化可能未完成。"
    exit 1
  fi
fi