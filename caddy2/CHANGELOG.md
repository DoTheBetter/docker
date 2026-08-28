# 更新日志
## 2026年8月28日 更新
更新镜像版本：dothebetter/caddy2:2.11.4-20260828
1. geoip插件由caddy-maxmind-geolocation切换为caddy-geo-ops，数据源为P3TERX/GeoLite.mmdb镜像源（无需账号）
2. 移除Maxmind官方GeoIP Update程序，内置下载服务改为curl实现；添加GEOIPUPDATE_DL_URL环境变量（默认P3TERX/GeoLite.mmdb镜像源，支持自定义镜像源或国内加速前缀）
3. 下载服务逻辑：数据库初始下载移至容器初始化阶段（Caddy启动前执行，确保geo_ops加载时库已就位，下载失败不阻塞启动）；库不全时快速补齐（60秒重试间隔、仅下载缺失库）；未配置MaxMind凭证时按GEOIPUPDATE_FREQUENCY定时从镜像源更新；配置凭证且库齐全后服务自动退出，定时更新由caddy-geo-ops插件auto_update通过MaxMind官方协议接管
4. 移除caddy-security插件
5. Caddyfile.default更新geo-ops插件全局配置及过滤、占位符输出、反代传参使用示例

## 2026年6月13日 更新
更新镜像版本：dothebetter/caddy2:2.11.4-20260613
1. 更新基础镜像 alpine:3.24
2. 更新 Caddy 版本 v2.11.4
3. 更新 MaxMind GeoIP Update 程序至 v7.1.1
4. 更新 s6-overlay 版本 v3.2.3.0，使用s6-overlay-v3构架
5. 添加Caddyfile插件github.com/caddy-dns/acmedns

## 2025年1月9日 更新
更新镜像版本：dothebetter/caddy2:2.9.1
1. 更新Caddyfile版本v2.9.1
2. 更新MaxMind的GeoIP Update程序版本 v7.1.0

## 2025年1月1日 更新
更新镜像版本：dothebetter/caddy2:2.9.0
1. 更新Caddyfile版本v2.9.0

## 2024年11月1日 更新
更新镜像版本：dothebetter/caddy2:2.8.4
1. 基础镜像单独构建：ghcr.io/dothebetter/baseimage_caddy2:latest
2. 添加Caddyfile插件github.com/greenpau/caddy-git

## 2024年10月5日 更新
更新镜像版本：dothebetter/caddy2:2.8.4
1. 更新基础镜像alpine:3.20
2. 更新Caddyfile版本v2.8.4
3. 更新MaxMind的GeoIP Update程序版本v7.0.1

## 2024年3月17日 更新
1. 更新基础镜像alpine:3.19
2. 更新Caddyfile版本v2.7.6
3. 更新MaxMind的GeoIP Update程序版本v6.1.0

## 2022年3月27日 更新
1. 基础镜像alpine:3.15
2. 集成MaxMind的GeoIP Update程序https://dev.maxmind.com/geoip/updating-databases?lang=en
3. Caddyfile默认配置文件修改
