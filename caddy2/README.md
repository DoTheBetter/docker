## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/caddy2"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_caddy2.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/caddy2"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fcaddy2-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/caddy2"><img alt="Static Badge" src="https://img.shields.io/badge/Docker_hub-dothebetter%2Fcaddy2-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/caddy2?label=Docker%20Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/caddy2?label=Docker%20Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/caddy2?label=Docker%20Pulls">
</p>

自用Caddy2 Alpine镜像，支持amd64;arm64v8;arm32v7系统。在Caddy官方builder镜像添加常用插件，集成Maxmind官方[GeoIP Update](https://dev.maxmind.com/geoip/updating-databases?lang=en)程序（需要注册Maxmind账号）。  

项目地址：https://github.com/DoTheBetter/docker/tree/master/caddy2

#### 官网地址

* https://caddyserver.com/ 
* https://github.com/caddyserver/caddy

####  插件列表

**各插件用法详见插件地址，镜像自带部分插件配置使用示例Caddyfile.default**

| 名称                           | 插件地址                                                | 说明                                                                                  |
|:---------------------------- |:--------------------------------------------------- | ----------------------------------------------------------------------------------- |
| caddy-docker-proxy/plugin/v2 | https://github.com/lucaslorentz/caddy-docker-proxy  | 该插件使 Caddy 能够通过标签用作 Docker 容器的反向代理，labels标签可与Caddyfile配置文件同时使用，Caddyfile配置文件修改后自动重载 |
| caddy-webdav                 | https://github.com/mholt/caddy-webdav               | 提供webdav服务                                                                          |
| caddy-maxmind-geolocation    | https://github.com/porech/caddy-maxmind-geolocation | 根据geoip数据库 IP 地理位置过滤请求                                                              |
| caddy-security               | https://github.com/greenpau/caddy-security          | 安全认证插件                                                                              |
| caddy-dns/cloudflare         | https://github.com/caddy-dns/cloudflare             | https证书签署dns认证                                                                      |
| caddy-dns/dnspod             | https://github.com/caddy-dns/dnspod                 | https证书签署dns认证                                                                      |
| caddy-dns/alidns             | https://github.com/caddy-dns/alidns                 | https证书签署dns认证                                                                      |
| caddy-dns/godaddy            | https://github.com/caddy-dns/godaddy                | https证书签署dns认证                                                                      |
| caddy-dns/googleclouddns     | https://github.com/caddy-dns/googleclouddns         | https证书签署dns认证                                                                      |
| caddy-dns/namecheap          | https://github.com/caddy-dns/namecheap              | https证书签署dns认证                                                                      |
| caddy-dns/namesilo           | https://github.com/caddy-dns/namesilo               | https证书签署dns认证                                                                      |

## 相关参数：

#### 环境变量
下面是可用于自定义安装的可用选项的完整列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|`TZ`|可选|`Asia/Shanghai`|设置时区|
|`GEOIPUPDATE_AUTO`|可选|`false`|自动更新geoip数据库开关，`true`为开启。|
|`GEOIPUPDATE_EDITION_IDS`|可选|`GeoLite2-Country`|geoip数据库类型：`GeoLite2-ASN`  `GeoLite2-City`  `GeoLite2-Country`。`GEOIPUPDATE_AUTO=true`时必须设置|
|`GEOIPUPDATE_ACCOUNT_ID`|可选|无|Maxmind帐户,`GEOIPUPDATE_AUTO=true`时必须设置|
|`GEOIPUPDATE_LICENSE_KEY`|可选|无|Maxmind API密钥,`GEOIPUPDATE_AUTO=true`时必须设置|
|`GEOIPUPDATE_FREQUENCY`|可选|`72`|geoip数据库更新间隔（小时），注意不能为***0***。|

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

> 本镜像在docker hub及ghcr.io同步推送，docker hub不能使用时可使用ghcr.io

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
	-e GEOIPUPDATE_EDITION_IDS=GeoLite2-Country \
	-e GEOIPUPDATE_ACCOUNT_ID=123456 \
	-e GEOIPUPDATE_LICENSE_KEY=123456 \
	-e GEOIPUPDATE_FREQUENCY=24 \
	-p 8080:80 \
	-p 4443:443 \
	-p 4443:443/udp \
	-v /var/run/docker.sock:/var/run/docker.sock:ro \
	-v /docker/caddy2/config:/config \
	-v /docker/caddy2/data:/data \
	dothebetter/caddy2:latest  #ghcr.io/dothebetter/caddy2:latest
```

#### docker-compose.yml

```yaml
version: '3'
services:
  caddy2:
    image: dothebetter/caddy2:latest  #image: ghcr.io/dothebetter/caddy2:latest
    container_name: caddy2
    restart: always
    networks:
      - web
    cap_add:
      - NET_ADMIN
    environment:
      - TZ=Asia/Shanghai
      - GEOIPUPDATE_AUTO=true
      - GEOIPUPDATE_EDITION_IDS=GeoLite2-Country
      - GEOIPUPDATE_ACCOUNT_ID=123456
      - GEOIPUPDATE_LICENSE_KEY=123456
      - GEOIPUPDATE_FREQUENCY=24
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