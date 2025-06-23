# Docker 安装脚本使用说明

本目录包含了用于在 Ubuntu 系统上安装 Docker 的自动化脚本，支持根据网络环境自动选择合适的镜像源。

## 1. 文件说明

- `install_docker.sh` - Docker 自动安装脚本
- `minikube_start.sh` - Minikube 启动脚本
- `README.md` - 本说明文档

## 2 install_docker.sh 功能特性

### 2.1 自动网络环境检测

脚本会自动检测当前运行环境，并选择最优的镜像源：

- **阿里云内网环境**：自动使用 `mirrors.cloud.aliyuncs.com`
- **外网环境**：自动使用 `mirrors.aliyun.com`

### 2.2 检测原理

脚本通过访问阿里云元数据服务 `http://100.100.100.200/latest/meta-data/` 来判断是否运行在阿里云 ECS 实例上：

```bash
if curl -s --connect-timeout 3 http://100.100.100.200/latest/meta-data/ > /dev/null 2>&1; then
    # 阿里云内网环境
    DOCKER_MIRROR="mirrors.cloud.aliyuncs.com"
else
    # 外网环境
    DOCKER_MIRROR="mirrors.aliyun.com"
fi
```

### 2.3 镜像源对比

| 环境 | 镜像源 | 优势 | 适用场景 |
|------|--------|------|----------|
| 阿里云内网 | `mirrors.cloud.aliyuncs.com` | 内网访问速度快，无流量费用 | 阿里云 ECS 实例 |
| 外网 | `mirrors.aliyun.com` | 公网可访问，稳定性好 | 本地开发环境、其他云服务商 |

## 3 使用方法

### 3.1 赋予执行权限

```bash
chmod +x install_docker.sh
```

### 3.2 运行安装脚本

```bash
./install_docker.sh
```

### 3.3 验证安装

脚本执行完成后，会自动运行 `docker version` 命令验证安装结果。

## 4 安装内容

脚本会自动完成以下操作：

1. **更新系统软件包**
2. **安装基础依赖**：ca-certificates、curl、gnupg、lsb-release
3. **网络环境检测**：自动选择合适的镜像源
4. **添加 Docker GPG 密钥**
5. **添加 Docker 软件源**
6. **安装 Docker 组件**：
   - docker-ce
   - docker-ce-cli
   - containerd.io
   - docker-buildx-plugin
7. **配置镜像加速器**：使用 DaoCloud 镜像加速
8. **启动 Docker 服务**

## 5 配置的镜像加速器

脚本会自动配置 Docker 镜像加速器，提高镜像拉取速度：

```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io/"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
```

## 6 系统要求

- **操作系统**：Ubuntu 18.04+
- **架构**：x86_64/amd64
- **权限**：需要 sudo 权限
- **网络**：需要互联网连接

## 7 故障排除

### 7.1 网络连接问题

如果遇到网络连接问题，可以手动指定镜像源：

```bash
# 手动设置为内网镜像源
export DOCKER_MIRROR="mirrors.cloud.aliyuncs.com"

# 手动设置为外网镜像源
export DOCKER_MIRROR="mirrors.aliyun.com"
```

### 7.2 权限问题

确保当前用户具有 sudo 权限，或者使用 root 用户执行脚本。

### 7.3 GPG 密钥问题

如果 GPG 密钥添加失败，可以尝试清理后重新运行：

```bash
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo rm -f /etc/apt/sources.list.d/docker.list
./install_docker.sh
```

## 8 注意事项

1. 脚本会自动检测并选择最优镜像源，无需手动干预
2. 在阿里云 ECS 上运行时，建议使用内网镜像源以获得更好的性能
3. 脚本执行过程中需要网络连接，请确保网络畅通
4. 安装完成后，建议重新登录或执行 `newgrp docker` 以使用户组变更生效

## 9 相关文档

- [Docker 官方文档](https://docs.docker.com/)
- [阿里云容器镜像服务](https://cr.console.aliyun.com/)
- [DaoCloud 镜像加速器](https://www.daocloud.io/mirror)
