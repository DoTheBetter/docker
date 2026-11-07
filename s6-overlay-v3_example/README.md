# s6-overlay v3 示例

一个基于 Alpine Linux 的 s6-overlay v3 最小示例镜像，演示如何按官方推荐方式声明和管理多服务。

- 官方仓库：<https://github.com/just-containers/s6-overlay>
- 基础镜像：`alpine:3.24`
- s6-overlay 版本：`3.2.3.2`

## 项目结构

```
s6-overlay-v3_example/
├── Dockerfile              # 按官方说明安装 s6-overlay v3（noarch + arch 双包）
├── README.md               # 本说明文件
└── rootfs/
    └── etc/
        └── s6-overlay/
            ├── s6-rc.d/              # 服务定义目录
            │   ├── init/             # 初始化 oneshot
            │   ├── app1/             # 示例长驻服务 1
            │   └── app2/             # 示例长驻服务 2
            └── user-bundles.d/
                └── user/
                    └── contents.d/    # 服务启动声明（空标记文件）
                        ├── init       # 将 init 加入启动集
                        ├── app1       # 将 app1 加入启动集
                        └── app2       # 将 app2 加入启动集
```

## 服务声明方式（s6-overlay v3）

### 1. 服务定义

每个服务在 `/etc/s6-overlay/s6-rc.d/` 下对应一个目录：

```
/etc/s6-overlay/s6-rc.d/<服务名>/
├── type                 # 服务类型：longrun（长驻服务）或 oneshot（一次性任务）
├── run                  # 启动脚本（longrun 必需）
├── up                   # 启动脚本（oneshot 必需，格式为 execline 脚本）
├── finish               # 退出脚本（可选）
├── down                 # 标记文件：存在则默认不启动（可选）
└── dependencies.d/      # 依赖声明目录
    └── <被依赖服务名>    # 空文件，表示启动本服务前先启动该服务
```

本示例中 `app1`、`app2` 均为 longrun，且通过 `dependencies.d/init` 依赖 `init` oneshot，
保证初始化完成后再启动业务服务。

> **依赖声明怎么写**：在 `dependencies.d/` 下创建与被依赖服务（或 bundle）同名的
> **空文件**即可。v3 服务通常应依赖 `base`（官方 README 示例的推荐写法，
> 如 `dependencies.d/base`），它保证系统基础服务就绪后本服务才启动；
> 需要等待初始化逻辑时再叠加对自定义 oneshot 的依赖（如本示例的 `init`）。

### 2. user bundle（服务启动声明）

服务定义完成后，还必须将其加入 **user bundle** 才会在容器启动时运行：
在 `/etc/s6-overlay/user-bundles.d/user/contents.d/` 下创建与服务同名的**空文件**。

### 3. 启动链说明

官方内置 `top` bundle 的成员为 `base`、`legacy-services`、`user`、`user2`：

| 成员 | 说明 |
| ----------------- | ------------------------------------------------------------ |
| `base` | **v3 内置基础 bundle**：包含 `fix-attrs`（属主/权限修复）、`legacy-cont-init`（初始化脚本兼容层）。这两个 oneshot 是 v2 兼容机制，仅当存在 `/etc/fix-attrs.d`、`/etc/cont-init.d` 时才起作用，纯 v3 写法下为空操作；但依赖 `base` 是官方推荐的写法，可保证基础服务就绪后用户服务才启动 |
| `legacy-services` | v2 兼容层：仅当存在 `/etc/services.d` 旧式服务目录时才起作用，纯 v3 写法下为空操作 |
| `user` | **默认 user bundle，即 v3 的服务入口**：`/etc/s6-overlay/user-bundles.d/user/` 中声明的服务（本示例的 `init`、`app1`、`app2` 都在这里） |
| `user2` | 可选的第二个 user bundle（`/etc/s6-overlay/user-bundles.d/user2/`），可用于将服务分组 |

容器启动时 stage 2 执行 `s6-rc -u change top`，按依赖顺序拉起全部成员，因此 `user-bundles.d/user/contents.d/` 中声明的服务会自动启动。

### 4. 完整目录结构（仅用户自行创建/维护的部分）

以下为需要在 Dockerfile 中通过 `COPY rootfs /` 提供的全部内容。
其余部分（`/init`、`/command/`、`/package/`、`user-bundles.d/*/type` 等）均由官方安装包自带，无需在仓库中提供：

```
/etc/
└── s6-overlay/
    ├── s6-rc.d/                          # 服务定义目录（每个服务一个目录）
    │   ├── init/                         # 初始化 oneshot 示例
    │   │   ├── type                      # oneshot
    │   │   ├── up                        # oneshot 启动脚本（execline 格式，本示例仅含说明注释）
    │   │   └── dependencies.d/
    │   │       └── base                  # 依赖 base 服务
    │   ├── app1/                         # 示例长驻服务
    │   │   ├── type                      # longrun
    │   │   ├── run                       # 启动脚本
    │   │   ├── finish                    # 退出脚本
    │   │   └── dependencies.d/
    │   │       └── init                  # 依赖 init oneshot
    │   └── app2/                         # 示例长驻服务
    │       ├── type                      # longrun
    │       ├── run                       # 启动脚本
    │       ├── finish                    # 退出脚本
    │       └── dependencies.d/
    │           └── init                  # 依赖 init oneshot
    └── user-bundles.d/
        └── user/
            └── contents.d/               # 放置与服务同名的空文件，服务才会启动
                ├── init                  # 空文件：将 init 加入启动集
                ├── app1                  # 空文件：将 app1 加入启动集
                └── app2                  # 空文件：将 app2 加入启动集
```

## Dockerfile 安装说明

按照官方说明，v3 的发布包为 `tar.xz` 格式，需要同时安装两个包：

1. `s6-overlay-noarch.tar.xz`：overlay 脚本（所有架构都需要）
2. `s6-overlay-${arch}.tar.xz`：s6 生态静态编译的二进制文件

解压需保留文件权限（`tar -C / -Jxpf`），并需先安装 `xz`：

```dockerfile
ARG S6_OVERLAY_VERSION=3.2.3.2
ARG S6_OVERLAY_BASE_URL=https://github.com/just-containers/s6-overlay/releases/download
ARG S6_ARCH=x86_64

ADD ${S6_OVERLAY_BASE_URL}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD ${S6_OVERLAY_BASE_URL}/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz /tmp

COPY rootfs /

RUN apk add --no-cache xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz \
    && rm -rf /tmp/*

ENTRYPOINT [ "/init" ]
```

### 多架构构建

通过 `--build-arg S6_ARCH=...` 指定架构，对应关系见官方文档
[Which architecture to use depending on your TARGETARCH](https://github.com/just-containers/s6-overlay#which-architecture-to-use-depending-on-your-targetarch)：

| TARGETARCH | S6_ARCH |
| ---------- | ------- |
| amd64      | x86_64  |
| arm64      | aarch64 |
| arm/v7     | arm     |
| arm/v6     | armhf   |
| 386        | i686    |

```bash
# 示例：构建 arm64 镜像
docker build --build-arg S6_ARCH=aarch64 -t s6-v3-demo:arm64 .
```

## 参考

- [s6-overlay 官方 README](https://github.com/just-containers/s6-overlay#table-of-contents)
- [s6-rc 服务目录规范](https://skarnet.org/software/s6-rc/s6-rc-compile.html)
