
FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETARCH
# 禁用 Go Modules
ENV GO111MODULE=off

WORKDIR /app

COPY main.go .

# 编译 Go 程序，并静态链接以减小二进制文件大小
RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -o hello .

# 第二阶段：从 scratch 开始构建最小化镜像
FROM scratch

COPY --from=builder /app/hello /hello

CMD ["/hello"]