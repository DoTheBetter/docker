## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/nut-netserver"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_nut-netserver.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/nut-netserver"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fnut--netserver-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/nut-netserver"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fnut--netserver-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/nut-netserver?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/nut-netserver?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/nut-netserver?label=Docker%20Pulls">
</p>
自用NUT(Network UPS Tools)镜像，默认使用netserver模式，自带lighttpd支持nut-cgi显示web界面，集成驱动：serial、usb、snmp、neon、modbus、avahi。基础系统为alpine，支持amd64;arm64v8;arm32v7系统。

1. 在群晖NAS中使用时的设置方法
    + UPS 标识：ups、用户名：monuser、密码：secret
2. 在威联通NAS中使用时设置方法
    + UPS 标识：qnapups、用户名：admin、密码：123456  

项目地址：https://github.com/DoTheBetter/docker/tree/master/nut-netserver

#### 官网地址

* [Network UPS Tools](https://networkupstools.org/)
* [GitHub - networkupstools/nut](https://github.com/networkupstools/nut)

## 相关参数：

#### 环境变量
下面是可用于自定义的完整选项列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|   `TZ`   |   可选   | `Asia/Shanghai` |                        设置时区                        |
| `NUT_UID` |   可选   |     `1000`     |        `nut`用户的uid        |
|  `NUT_GID`  |   可选   |     `1000`     | `nut`用户的gid |
| `UPSDRVCTL_OPTS` |   可选   |     `-FF`     | `upsdrvctl`（驱动控制器）的启动参数，多参数用空格分开，如`-D -FF`，可在容器内使用`upsdrvctl -h`查看全部参数 |
| `UPSD_OPTS` |   可选   |     `-FF`     | `upsd`（服务端）的启动参数，可在容器内使用`upsd -h`查看全部参数 |
| `UPSMON_OPTS` | 可选 | `-F` | `upsmon`（监控客户端）的启动参数，可在容器内使用`upsmon -h`查看全部参数 |
| `WEB` | 可选 | `true` | web 服务启用开关，`true`为开启，其余为关闭 |

##### **核心参数推荐**

###### **1. `upsdrvctl`（驱动控制器）**

- **前台运行**：使用 `-FF`（保留 PID 文件并前台运行，避免容器退出）
- **降权用户**：`-u nut`（本镜像已使用nut用户运行）
- **调试模式**：`-D`（输出日志到容器 STDOUT）

###### **2. `upsd`（服务端）**

- **前台运行**：使用 `-FF`（保留 PID 文件并前台运行，避免容器退出）
- **降权用户**：`-u nut`（本镜像已使用nut用户运行）
- **调试模式**：`-D`（输出日志到容器 STDOUT）
- **IPv4/IPv6 绑定**：`-4` 或 `-6`（明确网络协议）

###### **3. `upsmon`（监控客户端）**

- **前台运行**：使用 `-F`（前台运行，避免容器退出）
- **降权用户**：`-u nut`（本镜像已使用nut用户运行）
- **调试模式**：`-D`（输出日志到容器 STDOUT）
- **IPv4/IPv6 绑定**：`-4` 或 `-6`（明确网络协议）

#### 开放的端口

|范围|描述|
| :----: | :----: |
| `8080` | web 服务端口 |
| `3493` | nut 通信端口 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。  

|目录|描述|
| :----: | :----: |
|  `/conf`  | 配置文件夹 |

## 部署方法：

> 本镜像在docker hub及ghcr.io同步推送，docker hub不能使用时可使用ghcr.io

#### Docker Run
  ```bash
  docker run -d \
      --name nut-netserver \
      --restart=always \
      --privileged=true \
      -p 3493:3493 \
      -p 8080:8080 \
      -v /docker/nut:/conf \
      -e TZ=Asia/Shanghai \
      -e NUT_UID=1000 \
      -e NUT_GID=1000 \
      -e UPSDRVCTL_OPTS=-FF \
      -e UPSD_OPTS=-FF \
      -e UPSMON_OPTS=-F \
      -e WEB=true \
      dothebetter/nut-netserver:latest
      #ghcr.io/dothebetter/nut-netserver:latest
      #registry.cn-hangzhou.aliyuncs.com/dothebetter/nut-netserver:latest
  ```
#### docker-compose.yml
```yml
version: '3'
services:
  nut-netserver:
    image: dothebetter/nut-netserver:latest
    #image: ghcr.io/dothebetter/nut-netserver:latest
    #image: registry.cn-hangzhou.aliyuncs.com/dothebetter/nut-netserver:latest
    container_name: nut-netserver
    restart: always
    privileged: true #特权模式，使用usb设备连接时使用
    environment:
      - TZ=Asia/Shanghai
      - NUT_UID=1000
      - NUT_GID=1000
      - UPSDRVCTL_OPTS=-FF
      - UPSD_OPTS=-FF
      - UPSMON_OPTS=-F
      - WEB=true
    ports:
      - "3493:3493"
      - "8080:8080"
    volumes:
      - /docker/nut:/conf
```
## 更新日志：
详见 **[CHANGELOG.md](./CHANGELOG.md)**

