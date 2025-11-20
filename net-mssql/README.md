## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/net-mssql"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_net-mssql.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/net-mssql"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fnet--mssql-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/net-mssql"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fnet--mssql-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/net-mssql?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/net-mssql?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/net-mssql?label=Docker%20Pulls">
</p>

基于x64位Ubuntu 22.04的企业级容器化通用解决方案，集成了Microsoft SQL Server 2022、ASP.NET Core 6.0 Runtime、Redis缓存和自动化定时任务管理。使用s6-overlay进行服务生命周期管理，支持自动数据库备份、配置文件生成和服务状态监控。

项目地址：https://github.com/DoTheBetter/docker/tree/master/net-mssql

#### 官网地址

* ASP.NET Core 官方安装文档：https://learn.microsoft.com/zh-cn/dotnet/core/install/linux-scripted-manual#manual-install
* SQL Server 2022官方安装文档：https://learn.microsoft.com/zh-cn/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-linux-ver16&tabs=ubuntu2204%2C2025ubuntu2204%2Codbc-ubuntu-2204

#### 核心技术栈

- **基础镜像**: Ubuntu 22.04 LTS
- **数据库**: Microsoft SQL Server 2022
- **运行环境**: ASP.NET Core 6.0 Runtime
- **缓存服务**: Redis
- **任务调度**: Cron
- **服务管理**: s6-overlay
- **字体支持**: Adobe 思源字体 (Source Han Sans)

#### 主要特性

1. **数据库服务**: Microsoft SQL Server 2022
   - 支持多种版本：Developer/Express/Standard/Enterprise，其授权收费情况见[官方说明](https://www.microsoft.com/zh-cn/sql-server/sql-server-2022-pricing)
   - 自动初始化: 容器首次启动时自动创建数据库和执行初始化脚本
   - 智能状态检查: 全面检查数据库状态，确保备份和初始化操作的安全性
   - 自动备份: 支持定时备份和手动备份，备份文件自动命名和存储
   - 备份验证: 备份完成后自动验证备份文件完整性
   - 备份清理: 智能清理过期备份，保留策略可配置
   
2. **应用运行环境**: ASP.NET Core 6.0 Runtime
   - 无缝集成: 支持 .NET 6 应用程序无缝部署
   - 配置管理: 默认配置云中忆（yzy）系统，自动更新 appsettings.json 中的数据库连接和 Redis 配置
   - 权限管理: 支持自定义用户 UID/GID，确保文件权限正确
   - 字体支持: 集成 Adobe 思源字体，支持中文字体渲染
   
3. **缓存服务**: Redis
   - 自动配置: Redis 服务自动配置和启动
   - 安全设置: 自动生成随机密码，确保安全性
   - 持久化: 支持数据持久化存储

4. **任务调度**: Cron
   - 定时备份: 可配置的定时备份策略
   - 日志管理: 统一的日志格式和输出

## 一、使用说明【重要】

容器首次启动时会自动执行以下初始化步骤：
- 检查并创建必要的目录结构
- 配置SQL Server数据库目录符号链接
- 创建目标数据库（如果不存在）
- 执行初始化目录下`initdb.*` 开头的初始化文件（如果存在）
- 初始化Redis配置
- 设置应用程序目录权限

### 步骤1. **在首次初始化数据库时，需导入自定义数据库文件，请按以下步骤操作：**

  1. 将待导入的数据库文件重命名为以 `initdb.` 为前缀的名称（例如：`initdb.mydb.bak`）；
  2. 将该文件放入容器内的 `/data/mssql/initdb/` 目录中；
  3. 编辑该目录下自动生成的 `import-initdb-file.sh` 脚本，在其中添加相应的数据库导入命令。

  容器启动时会自动执行该脚本，完成数据导入。

  **注意**：在导入前，系统会自动对同名数据库进行备份，备份文件命名格式为：
   `[update]backup_<DBName>_<YYYYMMDD_HHMMSS>.bak`（例如：`[update]backup_mydb_20251119_143022.bak`）。

### 步骤2. **在`/data/app`目录放入.NET应用程序文件及相应配置文件**


## 二、数据库自动备份说明
- **自动备份**: 默认每7天执行一次备份（可通过CRON_SCHEDULE调整）
- **备份位置**: `/data/mssql/backup/`
- **命名规则**:  `[cron]backup_DBName_YYYYMMDD_HHMMSS.bak`
- **保留策略**: 
  - 近期备份：保留60天内的所有备份
  - 月度备份：保留6个月内的月度备份
## 三、相关参数：

#### 环境变量
下面是可用于自定义安装的可用选项的完整列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|   `TZ`   |   可选   | `Asia/Shanghai` |                        设置时区                        |
| `WEB_URLS` |   **必需**   |     无     |        Web页面访问地址，例: http://192.168.10.200:8083或https://www.123.com        |
| `MSSQL_SA_PASSWORD` |   **必需**   |     YourStrong@Pass123     | SQL Server管理员密码，密码必须为至少八个字符且包含以下四种字符中的三种：大写字母、小写字母、十进制数字、符号。 密码可最长为 128 个字符 |
| `MSSQL_DB_NAME` |   **必需**   |     YZY     | .NET应用程序**数据库名称** |
| `DOTNET_INDEX_NAME` |   **必需**   |     HLP_BusinessWebUI.dll     | .NET应用程序**启动文件** |
| `MSSQL_PID` |   可选   | `Developer` | SQL Server版本(Developer/Express/Standard/Enterprise) |
| `MSSQL_COLLATION` |   可选   | `Chinese_PRC_CI_AS` | 数据库排序规则 |
| `ENABLE_CRON` |   可选   | `true` | 启用定时任务备份，`true`为开，`false`为关 |
| `CRON_SCHEDULE` |   可选（**ENABLE_CRON=true**时必需）   | `2 0 */7 * *` | 备份任务时间表达式(每7天凌晨执行) |
| `CRON_RETAIN_RECENT_DAYS` |   可选（**ENABLE_CRON=true**时必需）   | `60` | 近期备份保留天数，单位：天 |
| `CRON_RETAIN_MONTHLY_MONTHS` | 可选（**ENABLE_CRON=true**时必需） | `6` | 月度备份保留月数，单位：月 |
| `DOTNET_UID` |   可选   | `1000` | .NET应用程序用户UID |
| `DOTNET_GID` |   可选   | `1000` | .NET应用程序用户GID |

#### 可开放的端口

|端口|协议|描述|
| :----: | :----: | :----: |
| `1433` | TCP | SQL Server默认端口 |
| `8080` | TCP | .NET应用程序端口 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。  

|目录|描述|权限要求|
| :----: | :----: | :----: |
|  `/data/mssql`  | SQL Server数据文件和备份存储 | mssql用户读写权限 |
| `/data/redis` | Redis持久化数据和配置文件 | redis用户读写权限 |
| `/data/app` | .NET应用程序文件和依赖 | dotnetuser用户读写权限 |

## 四、部署方法：

> 本镜像在 docker hub，ghcr.io 及 aliyuncs同步推送，docker hub 不能使用时可使用其他仓库

### 基本部署

#### Docker Run
  ```bash 	
  docker run -d \
    --name net-mssql \
    --restart on-failure:3 \
    --privileged \
    -e WEB_URLS=https://www.123.com:8080 \
    -e MSSQL_SA_PASSWORD=YourStrong@Pass123 \
    -e MSSQL_DB_NAME=YZY \
    -e DOTNET_INDEX_NAME=HLP_BusinessWebUI.dll \
    -e DOTNET_UID=1000 \
    -e DOTNET_GID=1000 \
    -e "CRON_SCHEDULE=2 0 */7 * *" \
    -p 8080:8080 \
    -v /docker/net-mssql:/data \
    dothebetter/net-mssql:20251120
    #ghcr.io/dothebetter/net-mssql:20251120
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/net-mssql:20251120
  ```

#### docker-compose.yml
```yml
version: '3'
services:
  net-mssql:
    image: dothebetter/net-mssql:20251120
    #ghcr.io/dothebetter/net-mssql:20251120
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/net-mssql:20251120
    container_name: net-mssql
    restart: on-failure:3
    privileged: true
    environment:
        - WEB_URLS=https://www.123.com:8080
        - MSSQL_SA_PASSWORD=YourStrong@Pass123
        - MSSQL_DB_NAME=YZY
        - DOTNET_INDEX_NAME=HLP_BusinessWebUI.dll
        - DOTNET_UID=1000
        - DOTNET_GID=1000
        - CRON_SCHEDULE=2 0 */7 * *
    ports:
        - 8080:8080
    volumes:
        - /docker/net-mssql:/data
```

### 高级配置示例

#### 生产环境配置
```yml
version: '3'
services:
  net-mssql:
    image: dothebetter/net-mssql:20251120
    container_name: net-mssql-prod
    restart: on-failure:3
    privileged: true
    environment:
        - TZ=Asia/Shanghai
        - WEB_URLS=https://www.123.com:8080
        - MSSQL_SA_PASSWORD=YourStrong@Pass123
        - MSSQL_DB_NAME=YZY
        - MSSQL_COLLATION=Chinese_PRC_CI_AS
        - MSSQL_PID=Express
        - DOTNET_INDEX_NAME=HLP_BusinessWebUI.dll
        - DOTNET_UID=1000
        - DOTNET_GID=1000
        - ENABLE_CRON=true
        - CRON_SCHEDULE=2 0 */7 * *  # 每周凌晨2点
        - CRON_RETAIN_RECENT_DAYS=90  # 保留近期备份90天
        - CRON_RETAIN_MONTHLY_MONTHS=12  # 保留月度备份12个月
    ports:
        - 1433:1433
        - 8080:8080
    volumes:
        - /docker/net-mssql:/data
```

## 五、更新日志：
详见 **[CHANGELOG.md](./CHANGELOG.md)**