## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/rsync"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_rsync.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/rsync"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Frsync-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/rsync"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Frsync-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/rsync?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/rsync?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/rsync?label=Docker%20Pulls">
</p>

自用rsync备份镜像，基础系统为alpine，支持amd64;arm64v8;arm32v7系统。  镜像中ssh、cron、rsync、lsyncd可自由组合使用以分别实现server/client模式。 

项目地址：https://github.com/DoTheBetter/docker/tree/master/rsync

#### 官网地址

* rsync官方文档：https://github.com/RsyncProject/rsync
* lsyncd官方文档：https://lsyncd.github.io/lsyncd/

#### 用法

1. 作为**源端，为server模式**，可以选用组合模式：`lsyncd`、`lsyncd+ssh`或者`rsync`、`rsync+cron`、`rsync+cron+ssh`
2. 作为**同步或复制发起端，为client模式**，不需要开启守护进程，可以选用组合模式：`cron`或者`cron+ssh`

#### 其他说明
1. root账户使用`passwd=$(tr -dc 'A-Za-z0-9!@#$%^&*()' < /dev/urandom | head -c32)`在每次启动容器时自动生成32位随机密码。
2. 禁止root账户使用密码登录，只允许使用密钥认证登录。
3. 禁止其他账户使用密码进行身份验证登录。
4. ssh模式生成密钥类型为ed25519。
5. 启用`cron`计划任务时，每隔1分钟检测`/conf/crontabs`规则变化并在变化时重启`crond`。
6. 要改变默认端口，使用`--port=8081`指定rsync 端口(默认873)，使用`-e "ssh -p 2022"`指定SSH端口(默认22)。

## 相关参数：

#### 环境变量
下面是可用于自定义安装的可用选项的完整列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|   `TZ`   |   可选   | `Asia/Shanghai` |                        设置时区                        |
|  `SSH`   |   可选   |     `false`     |        ssh服务启用开关，`true`为开，`false`为关        |
|  `CRON`  |   可选   |     `false`     |     cron计划任务启用开关，`true`为开，`false`为关      |
| `RSYNC`  |   可选   |     `false`     | rsync daemon守护进程启用开关，`true`为开，`false`为关  |
| `LSYNCD` |   可选   |     `false`     | lysncd daemon守护进程启用开关，`true`为开，`false`为关 |

#### 开放的端口

|范围|描述|
| :----: | :----: |
| `22`  |  ssh端口   |
| `873` | rsync 端口 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。  

|目录|描述|
| :----: | :----: |
|  `/conf`  | 各服务的配置文件夹 |
| `/backup` |     备份文件夹     |

## 部署方法：

> 本镜像在docker hub及ghcr.io同步推送，docker hub不能使用时可使用ghcr.io

### 1. 在源端使用时

#### Docker Run
  ```bash
  docker run -d \
  	--name rsync \
  	--restart always \
  	-e SSH=true \
  	-e RSYNC=true \
  	-p 8872:22 \
  	-p 8873:873 \
  	-v /docker/rsync:/conf \
  	-v /backup:/backup \
  	dothebetter/rsync:latest  #ghcr.io/dothebetter/rsync:latest
  ```
#### docker-compose.yml
```yml
version: '3'
services:
  rsync:
    image: dothebetter/rsync:latest  #ghcr.io/dothebetter/rsync:latest
    container_name: rsync
    restart: always
    environment:
      - SSH=true
      - RSYNC=true
    ports:
        - "8872:22"
        - "8873:873" #可选
    volumes:
        - /docker/rsync:/conf
        - /backup:/backup
```

### 2. 在复制端使用时：只拉取时可以不映射端口

#### Docker Run
  ```bash
  docker run -d \
  	--name rsync \
  	--restart always \
  	-e SSH=true \
  	-e CRON=true \
  	-v /docker/rsync:/conf \
  	-v /backup:/backup \
  	dothebetter/rsync:latest  #ghcr.io/dothebetter/rsync:latest
  ```
#### docker-compose.yml
```yml
version: '3'
services:
  rsync:
    image: dothebetter/rsync:latest  #ghcr.io/dothebetter/rsync:latest
    container_name: rsync
    restart: always
    environment:
      - SSH=true
      - CRON=true
    volumes:
        - /docker/rsync:/conf
        - /backup:/backup
```
## 更新日志：
详见 **[CHANGELOG.md](./CHANGELOG.md)**