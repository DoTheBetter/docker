ARG NET_MSSQL_VER=20251120


FROM ubuntu:22.04

ARG S6_VER=3.2.1.0
# https://dotnet.microsoft.com/zh-cn/download/dotnet/6.0
ARG DOTNET_ASPNETCORE_VERSION=6.0.36
ARG DOTNET_FILE=aspnetcore-runtime-${DOTNET_ASPNETCORE_VERSION}-linux-x64.tar.gz
ARG DOTNET_URL=https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/${DOTNET_ASPNETCORE_VERSION}/${DOTNET_FILE}
# 开源思源字体 https://github.com/adobe-fonts/source-han-sans/blob/master/README-CN.md
ARG FONT_URL=https://github.com/adobe-fonts/source-han-sans/raw/refs/heads/release/OTC/SourceHanSans-Medium.ttc

# 系统环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_VERBOSITY=1 \
    TZ=Asia/Shanghai \
    WEB_URLS= \
    ENABLE_CRON=true \
    CRON_SCHEDULE="2 0 */7 * *" \
    CRON_RETAIN_RECENT_DAYS=60 \
    CRON_RETAIN_MONTHLY_MONTHS=6
# .NET 环境变量
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=${PATH}:${DOTNET_ROOT}:${DOTNET_ROOT}/tools
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    COMPlus_EnableDiagnostics=0 \
    ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_PRINT_TELEMETRY_MESSAGE=false \
    DOTNET_INDEX_NAME=HLP_BusinessWebUI.dll \
    DOTNET_UID=1000 \
    DOTNET_GID=1000
# SQL Server 环境变量 https://learn.microsoft.com/zh-cn/sql/linux/sql-server-linux-configure-environment-variables?view=sql-server-linux-ver16
ENV ACCEPT_EULA=Y \
    MSSQL_SA_PASSWORD=YourStrong@Pass123 \
    MSSQL_PID=Developer \
    MSSQL_COLLATION=Chinese_PRC_CI_AS \
    MSSQL_DB_NAME=YZY \
    PATH=${PATH}:/opt/mssql/bin:/opt/mssql-tools18/bin

COPY --chmod=755 rootfs /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget curl xz-utils tzdata redis cron gettext-base \
        # 字体相关依赖，用于支持中文字体渲染
        fontconfig libfontconfig1 libfreetype6 \
        # .NET 依赖项
        ca-certificates libc6 libgcc-s1 libgssapi-krb5-2 libicu70 liblttng-ust1 libssl3 libstdc++6 zlib1g \
        # 用于支持 .NET 应用程序中的 GDI+ 功能和 Ghostscript 字体渲染
        libgdiplus ghostscript \
# 创建 .NET 运行用户组和用户
    && groupadd dotnetuser \
    && useradd -g dotnetuser -M -s /sbin/nologin dotnetuser \
# 安装s6-overlay
    && if [ "$(uname -m)" = "x86_64" ]; then s6_arch=x86_64; \
    elif [ "$(uname -m)" = "aarch64" ]; then s6_arch=aarch64; \
    elif [ "$(uname -m)" = "armv7l" ]; then s6_arch=arm; \
    fi \
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && wget -P /tmp https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${s6_arch}.tar.xz \
# 使用二进制文件安装 .NET 6 https://learn.microsoft.com/zh-cn/dotnet/core/install/linux-scripted-manual
    && wget -O /tmp/${DOTNET_FILE} ${DOTNET_URL} \
    && mkdir -p ${DOTNET_ROOT} \
    && tar -C ${DOTNET_ROOT} -zxpf /tmp/${DOTNET_FILE} \
    && dotnet --info \
# 安装 SQL Server 2022及命令行工具 https://learn.microsoft.com/zh-cn/sql/linux/quickstart-install-connect-ubuntu?view=sql-server-linux-ver16&tabs=ubuntu2204%2C2025ubuntu2204%2Codbc-ubuntu-2204
    && curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc \
    && curl https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list | tee /etc/apt/sources.list.d/mssql-server-2022.list \
    && curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends mssql-server mssql-tools18 unixodbc-dev \
# 安装开源思源字体
    && mkdir -p /usr/share/fonts/truetype/ \
    && wget -O /usr/share/fonts/truetype/SourceHanSans-Medium.ttc ${FONT_URL} \
    && fc-cache -fv \
    && fc-list | grep -i "Source Han Sans" \
# 清理系统缓存
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/tmp/* \
    && rm -rf /tmp/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/* \
    && rm -rf /usr/share/info/*

# 健康检查配置
HEALTHCHECK --interval=60s --timeout=30s --start-period=60s --retries=5 \
    CMD sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -d master -Q "SELECT 1;" -C

EXPOSE 8080
ENTRYPOINT [ "/init" ]
