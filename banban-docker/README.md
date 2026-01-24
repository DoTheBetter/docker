## 简介：
<p align="center">
<a target="_blank" href="https://github.com/DoTheBetter/docker/tree/master/banban-docker"><img alt="Static Badge" src="https://img.shields.io/badge/Github-DoTheBetter%2Fdocker-brightgreen"></a>
<img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/DoTheBetter/docker?label=GitHub%20repo%20size">
<img alt="GitHub Actions Workflow Status" src="https://img.shields.io/github/actions/workflow/status/DoTheBetter/docker/DockerBuild_banban-docker.yml?label=GitHub%20Actions%20Workflow%20Status">
<br>
<a target="_blank" href="https://github.com/DoTheBetter/docker/pkgs/container/banban-docker"><img alt="Static Badge" src="https://img.shields.io/badge/ghcr.io-dothebetter%2Fbanban--docker-brightgreen"></a>
<a target="_blank" href="https://hub.docker.com/r/dothebetter/banban-docker"><img alt="Static Badge" src="https://img.shields.io/badge/docker.io-dothebetter%2Fbanban--docker-brightgreen"></a>
<img alt="Docker Image Version" src="https://img.shields.io/docker/v/dothebetter/banban-docker?label=Image%20Version">
<img alt="Docker Image Size" src="https://img.shields.io/docker/image-size/dothebetter/banban-docker?label=Image%20Size">
<img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dothebetter/banban-docker?label=Docker%20Pulls">
</p>


自用斑斑低代码系统 Docker 镜像，基于 Debian Stable Slim 构建，仅支持 amd64 架构。使用非root用户运行，集成 S6-overlay 进程管理框架，提供完整的系统初始化和权限管理功能。

项目地址：https://github.com/DoTheBetter/docker/tree/master/banban-docker

#### 官网地址

- https://www.banban.work

## 相关参数：

#### 环境变量
下面是可用于自定义安装的可用选项的完整列表。

| 变量名 | 是否必须 | 默认值 | 说明 |
| :---: | :---: | :---: | :--- |
| `TZ` | 可选 | `Asia/Shanghai` | 设置系统时区 |
| `UID` | 可选 | `1000` | banban-user 用户的 UID |
| `GID` | 可选 | `1000` | banbanuser-group 用户组的 GID |

#### 开放的端口

| 范围 | 描述 |
| :---: | :--- |
| 无固定端口 | 应用端口由 `/app` 目录下配置文件`config.jsonc`决定 |

#### 数据卷

下面的目录用于配置，并且可以映射为持久存储。

| 目录 | 描述 |
| :---: | :--- |
| `/app` | 斑斑低代码系统主程序目录，包含应用程序和配置文件。将从官方下载的无桌面版压缩包解压放在该文件夹内。 |
| `/root/.config` | 用于存储数据文件。目前官方程序固定使用`/root`目录储存数据。 |

## 部署方法：

> 本镜像在 docker hub，ghcr.io 及 阿里云同步推送，docker hub 不能使用时可使用其他仓库

#### Docker Run

```bash
docker run -d \
	--name banban \
	--restart always \
	-e TZ=Asia/Shanghai \
	-e UID=1000 \
	-e GID=1000 \
	-p 16666:16666 \
	-v /path/to/app:/app \
	-v /path/to/data:/root/.config \
	dothebetter/banban-docker:latest
    #ghcr.io/dothebetter/banban-docker:latest
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/banban-docker:latest
```

#### docker-compose.yml

```yaml
version: '3'

services:
  banban:
    image: dothebetter/banban-docker:latest
    #ghcr.io/dothebetter/banban-docker:latest
    #registry.cn-hangzhou.aliyuncs.com/dothebetter/banban-docker:latest
    container_name: banban
    restart: always
    environment:
      - TZ=Asia/Shanghai
      - UID=1000
      - GID=1000
    ports:
      - 16666:16666
    volumes:
      - /path/to/app:/app
      - /path/to/data:/root/.config
```

#### 注意事项

1. **文件权限**：确保挂载的目录对 UID 1000 和 GID 1000 有读写权限
2. **首次启动**：首次启动时会自动创建必要的目录并修复权限
3. **时区配置**：如需使用其他时区，请设置正确的 TZ 值，如 `UTC`、`America/New_York` 等
4. **UID/GID 修改**：如果宿主机的 UID/GID 与默认值冲突，可以自定义 `UID` 和 `GID` 环境变量

## 更新日志：

详见 **[CHANGELOG.md](./CHANGELOG.md)**
