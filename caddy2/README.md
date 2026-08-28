## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/caddy2"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_caddy2.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/caddy2"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fcaddy2-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/caddy2"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fcaddy2-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/caddy2?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/caddy2?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/caddy2?label=Docker%20Pulls">
</p>

自用Caddy2 Alpine镜像，支持amd64;arm64v8;arm32v7系统。在Caddy官方builder镜像添加常用插件，集成caddy-geo-ops插件实现GeoIP请求过滤与数据库统一管理（文件变更热重载+定时自动更新，配合P3TERX/GeoLite.mmdb镜像源无需注册账号）。  

项目地址：https://github.com/DoTheBetter/docker/tree/master/caddy2

#### 官网地址

* https://caddyserver.com/ 
* https://github.com/caddyserver/caddy

####  插件列表

**各插件用法详见插件地址，镜像自带部分插件配置使用示例Caddyfile.default**

| 名称                         | 插件地址                                            | 说明                                                         |
| :--------------------------- | :-------------------------------------------------- | ------------------------------------------------------------ |
| caddy-docker-proxy/plugin/v2 | https://github.com/lucaslorentz/caddy-docker-proxy  | 该插件使 Caddy 能够通过标签用作 Docker 容器的反向代理，labels标签可与Caddyfile配置文件同时使用，Caddyfile配置文件修改后自动重载 |
| caddy-webdav                 | https://github.com/mholt/caddy-webdav               | 提供webdav服务                                               |
| caddy-geo-ops                | https://github.com/ubiuser/caddy-geo-ops            | 根据geoip数据库过滤请求（国家/省份/ASN等），支持数据库文件变更热重载与`auto_update`定时更新，可通过`{geo.*}`占位符输出访客地理位置。使用示例详见Caddyfile.default |
| acmedns                      | https://github.com/caddy-dns/acmedns                | 一个简化的DNS服务器，配备RESTful HTTP API，提供一种简单的方式来自动化ACME DNS-01 challenges |
| caddy-dns/alidns             | https://github.com/caddy-dns/alidns                 | https证书签署dns认证                                         |
| caddy-dns/tencentcloud       | https://github.com/caddy-dns/tencentcloud           | https证书签署dns认证                                         |
| caddy-dns/huaweicloud        | https://github.com/caddy-dns/huaweicloud            | https证书签署dns认证                                         |
| caddy-dns/cloudflare         | https://github.com/caddy-dns/cloudflare             | https证书签署dns认证                                         |
| caddy-dns/godaddy            | https://github.com/caddy-dns/godaddy                | https证书签署dns认证                                         |
| caddy-dns/namecheap          | https://github.com/caddy-dns/namecheap              | https证书签署dns认证                                         |
| caddy-dns/namesilo           | https://github.com/caddy-dns/namesilo               | https证书签署dns认证                                         |


## 相关参数：

#### 环境变量
下面是可用于自定义安装的可用选项的完整列表。
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|`TZ`|可选|`Asia/Shanghai`|设置时区|
|`CADDY_DOCKER_LOG_LEVEL`|可选|`WARN`|caddy-docker-proxy 模块日志等级：`DEBUG`、`INFO`、`WARN`、`ERROR`|
|`GEOIPUPDATE_AUTO`|可选|`false`|GeoIP Update服务开关，`true`为开启：容器初始化阶段（Caddy启动前）自动初始下载数据库，未配置MaxMind凭证时按`GEOIPUPDATE_FREQUENCY`定时更新|
|`GEOIPUPDATE_EDITION_IDS`|可选|`GeoLite2-Country`|geoip数据库类型（多个用英文逗号分隔），可选值：`GeoLite2-Country`（国家）、`GeoLite2-City`（城市）、`GeoLite2-ASN`（ASN），对应Caddyfile占位符库名为`geolite2-country`/`geolite2-city`/`geolite2-asn`|
|`GEOIPUPDATE_DL_URL`|可选|`https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download`|geoip数据库下载地址，最终下载URL为`<GEOIPUPDATE_DL_URL>/<库名>.mmdb`；国内直连不畅时可替换为加速前缀，如`https://gh-proxy.com/https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download`|
|`GEOIPUPDATE_FREQUENCY`|可选|`72`|geoip数据库更新间隔（小时），注意不能为***0***。|
|`GEOIPUPDATE_ACCOUNT_ID`|可选|无|MaxMind账号ID，与`GEOIPUPDATE_LICENSE_KEY`同时配置并在Caddyfile中启用`auto_update`后，geoip数据库由caddy-geo-ops插件通过MaxMind官方协议自动更新（GeoIP Update服务完成数据库补齐后自动退出）|
|`GEOIPUPDATE_LICENSE_KEY`|可选|无|MaxMind许可证密钥，作用同上|

> **注意**：geoip数据库由[caddy-geo-ops](https://github.com/ubiuser/caddy-geo-ops)插件统一管理（文件变更热重载，配置示例详见Caddyfile.default）。开启`GEOIPUPDATE_AUTO=true`后，首次启动若 `/data/GeoIP` 目录为空，会在容器初始化阶段（Caddy启动前）自动从[P3TERX/GeoLite.mmdb](https://github.com/P3TERX/GeoLite.mmdb)镜像源下载GeoLite2免费初始库（无需注册账号），确保Caddy加载geoip数据库时库已就位（下载失败不阻塞启动，由GeoIP Update服务按周期重试补齐）：
> - **未配置MaxMind凭证**：由GeoIP Update服务按`GEOIPUPDATE_FREQUENCY`定时从镜像源更新；
> - **配置了 `GEOIPUPDATE_ACCOUNT_ID`/`GEOIPUPDATE_LICENSE_KEY`**（MaxMind免费账号注册地址：https://www.maxmind.com/en/geolite2/signup ）：在Caddyfile中启用`auto_update`及凭证配置后，由插件通过MaxMind官方协议自动更新（GeoIP Update服务完成数据库补齐后自动退出）。

#### 开放的端口

|范围|描述|
| :----: | :----: |
|`80`|http端口|
|`443`|https端口|
|`443/udp`|QUIC/HTTP3协议端口|
|`2019`|Caddy2 API端口 ***（可选）***|

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。  

|目录|描述|
| :----: | :----: |
|`/config`|配置文件目录|
|`/data`|TLS 证书、私钥、GeoIP数据和其他必要信息存储目录|
|`/var/run/docker.sock`|宿主机Docker守护进程默认监听的Unix域套接字(Unix domain socket)|

## 部署方法：

> 本镜像在 docker hub，ghcr.io 及 aliyuncs同步推送，docker hub 不能使用时可使用其他仓库

#### Docker Run

```bash
docker network create web
docker run -d \
	--net web \
	--name caddy2 \
	--restart always \
	--cap-add NET_ADMIN \
	-e TZ=Asia/Shanghai \
	-e GEOIPUPDATE_AUTO=true \
	-p 8080:80 \
	-p 4443:443 \
	-p 4443:443/udp \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	-v /docker/caddy2/config:/config \
	-v /docker/caddy2/data:/data \
	dothebetter/caddy2:latest
	#ghcr.io/dothebetter/caddy2:latest
	#registry.cn-hangzhou.aliyuncs.com/dothebetter/caddy2:latest
```

#### docker-compose.yml

```yaml
version: '3'
services:
  caddy2:
    image: dothebetter/caddy2:latest
    #ghcr.io/dothebetter/caddy2:latest
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/caddy2:latest
    container_name: caddy2
    restart: always
    networks:
      - web
    cap_add:
      - NET_ADMIN
    environment:
      - TZ=Asia/Shanghai
      - GEOIPUPDATE_AUTO=true
    ports:
      - "8080:80"
      - "4443:443"
      - "4443:443/udp"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /docker/caddy2/config:/config
      - /docker/caddy2/data:/data

networks:
  web:
    external: true
```
## 更新日志：
详见 **[CHANGELOG.md](./CHANGELOG.md)**