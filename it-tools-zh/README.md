## 简介：

<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/it-tools-zh"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_it-tools-zh.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/it-tools-zh"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fit--tools--zh-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/it-tools-zh"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fit--tools--zh-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/it-tools-zh?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/it-tools-zh?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/it-tools-zh?label=Docker%20Pulls">
</p>

自用的IT Tools中文自翻译版，基于Alpine，支持多种架构，包括amd64、arm64v8和arm32v7。

采用的IT Tools代码仓库为`sharevb/it-tools`，该仓库比it-tools官方仓库`CorentinTh/it-tools`更新更及时，工具更多。

项目地址：https://github.com/DoTheBetter/docker/tree/master/it-tools-zh

#### 官网地址

- https://github.com/sharevb/it-tools

## 相关参数：

#### 环境变量

下面是可用于自定义安装的可用选项的完整列表。  
|变量名|是否必须|默认值|说明|
| :------: | :--------: | :------: | :----: |
|`TZ`|可选|`Asia/Shanghai`|设置时区|

#### 开放的端口

|  范围  |     描述     |
| :----: | :----------: |
| `8080` | web 服务端口 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。

| 文件或目录 | 描述 |
| :--------: | :--: |
|     -      |  -   |

## 部署方法：

> 本镜像在 docker hub，ghcr.io 及 aliyuncs同步推送，docker hub 不能使用时可使用其他仓库

#### Docker Run

```bash
docker run -d \
    --name it-tools-zh \
    --restart always \
    -e TZ=Asia/Shanghai \
    -p 8080:8080 \
    dothebetter/it-tools-zh:latest
    #ghcr.io/dothebetter/it-tools-zh:latest
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/it-tools-zh:latest
```

#### docker-compose.yml

```yaml
services:
    it-tools-zh:
        image: dothebetter/it-tools-zh:latest
        #ghcr.io/dothebetter/it-tools-zh:latest
        #registry.cn-hangzhou.aliyuncs.com/dothebetter/it-tools-zh:latest
        container_name: it-tools-zh
        restart: always
        environment:
            - TZ=Asia/Shanghai
        ports:
            - 8080:8080
```

## 更新日志：

详见 **[CHANGELOG.md](./CHANGELOG.md)**
