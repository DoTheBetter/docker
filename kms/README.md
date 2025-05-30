## 简介：

<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/kms"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_kms.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/kms"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fkms-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/kms"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fkms-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/kms?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/kms?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/kms?label=Docker%20Pulls">
</p>
自用的KMS激活镜像，基于Alpine，支持多种架构，包括amd64、arm64v8和arm32v7。

KMS 服务默认通过命令行`vlmcsd -i /vlmcsd/config/vlmcsd.ini -D -e`来启动，便于后期根据需要修改。**注意：命令行参数优先**。

同时，该服务还提供了基于 Web 的说明界面，方便参考操作。

项目地址：https://github.com/DoTheBetter/docker/tree/master/kms

#### 官网地址

- https://github.com/Wind4/vlmcsd

## 相关参数：

#### 环境变量

下面是可用于自定义安装的可用选项的完整列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|`TZ`|可选|`Asia/Shanghai`|设置时区|
|`UID`|可选|`1000`|设置kms运行用户ID|
|`GID`|可选|`1000`|设置kms运行用户组ID|
|`VLKMCSD_OPTS`|可选|`-i /vlmcsd/config/vlmcsd.ini -D -e`|vlmcsd 启动参数<br />`-D`：前台运行<br />`-e`：将所有日志记录显示到屏幕|
|`WEB`|可选|`true`|web 服务启用开关，`true`：启用，`false`：禁用|

#### 开放的端口

|  范围  |      描述       |
| :----: | :-------------: |
| `8080` |  web 服务端口   |
| `1688` | vlmcsd 服务端口 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。

|    文件或目录    |                    描述                    |
| :--------------: | :----------------------------------------: |
| `/vlmcsd/config` |            vlmcsd 配置文件目录             |
|  `/vlmcsd/www`   | web 服务启动目录，可自行映射以修改显示内容 |

## 部署方法：

> 本镜像在 docker hub，ghcr.io 及 aliyuncs同步推送，docker hub 不能使用时可使用其他仓库

#### Docker Run

```bash
docker run -d \
    --name kms \
    --restart always \
    -e TZ=Asia/Shanghai \
    -e UID=1000 \
    -e GID=1000 \
    -e VLKMCSD_OPTS=-i /vlmcsd/config/vlmcsd.ini -D -e \
    -e WEB=true \
    -p 8080:8080 \
    -p 1688:1688 \
    -v /docker/vlmcsd:/vlmcsd/config \
    dothebetter/kms:latest
    #ghcr.io/dothebetter/kms:latest
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/kms:latest
```

#### docker-compose.yml

```yaml
version: "3"
services:
  kms:
    image: dothebetter/kms:latest
    #ghcr.io/dothebetter/kms:latest
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/kms:latest
    container_name: kms
    restart: always
    environment:
      - TZ=Asia/Shanghai
      - UID=1000
      - GID=1000
      - VLKMCSD_OPTS=-i /vlmcsd/config/vlmcsd.ini -D -e
      - WEB=true
    ports:
      - "8080:8080"
      - "1688:1688"
    volumes:
      - /docker/vlmcsd:/vlmcsd/config
```

## 更新日志：

详见 **[CHANGELOG.md](./CHANGELOG.md)**
