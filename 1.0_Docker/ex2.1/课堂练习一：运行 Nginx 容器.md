# 课堂练习一：运行 Nginx 容器

## 学习目标

通过本练习，您将学会：

- 从 `Docker Hub` 拉取 `Nginx` 镜像
- 运行 `Nginx` 容器并进行端口映射
- 使用数据卷挂载本地文件到容器
- 理解容器的前台和后台运行模式

## 介绍

`Nginx` 是一种开源 `Web` 服务器，用于为静态或动态网站提供服务、反向代理、负载平衡以及其他 `HTTP` 和代理服务器功能。它是为处理大量并发连接而构建的，是一种流行的网络服务器，用于托管互联网上一些最大和最高流量的网站。

`Docker` 是一种流行的开源容器化工具，用于为软件应用程序提供可移植且一致的运行时环境，同时比传统服务器或虚拟机消耗更少的资源。`Docker` 使用容器、在操作系统级别运行并共享系统资源（例如内核和文件系统）的隔离用户空间环境。

通过容器化 `Nginx`，可以减少一些系统管理开销。例如，我们不必通过包管理器管理 `Nginx` 或从源代码构建它。`Docker` 容器允许发布新版本的 `Nginx` 时替换整个容器。这样，我们就可以在不中断服务的情况下更新 `Nginx` 版本。

在本教程中，我们将学习如何通过使用 `Docker` 容器配置 `Nginx` 来提供静态网页的网站。

---

## 第 1 步 — 从 Docker Hub 下载 Nginx

`Docker` 维护着一个名为 [Docker Hub](https://hub.docker.com/) 的站点，这是一个 Docker 文件的公共镜像仓库，其中包括官方和用户提交的镜像。`Docker` 的官方镜像可用于快速开发应用程序，不必构建自己的镜像。这些镜像由 `Docker` 社区维护，通常是为最常见的用例设计的。

可以通过运行以下命令从具有默认 `Nginx` 配置的预构建 `Docker` 映像下载 `Nginx`：

```bash
docker pull nginx
```

这将下载 nginx 镜像。Docker 会缓存这些，所以当运行容器时，我们就不需要每次都下载镜像。现在我们可以启动 Nginx 容器，使其作为 Web 服务器可公开访问。要启动 Nginx 容器，请运行以下命令：

```bash
docker run --name docker-nginx -p 8080:80 nginx
```

**命令参数说明：**

- `run` - 创建新容器的命令
- `--name` - 指定容器名称的标志。如果为空，将分配一个生成的名称，如 `nostalgic_hopper`
- `-p` - 端口映射，格式为 `local-machine-port:internal-container-port`。这里将容器的 80 端口映射到主机的 8080 端口
- `nginx` - 镜像名称，没有 tag 时默认使用 `latest` 标签

在浏览器中，输入服务器的 IP 地址就可以显示 Nginx 的默认登录页面：

默认 IP 地址是 `127.0.0.1:8080` 或者 `localhost:8080`

另请注意，在终端中，当我们向服务器发出请求时，Nginx 的日志正在更新。这是因为我们正在以交互方式运行容器。

在终端中，输入 `CTRL+C` 以停止容器运行。此时我们无法再查看着陆页。我们可以使用以下命令验证容器状态：

```bash
docker ps -a
```

```bash
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
05012ab02ca1        nginx               "nginx -g 'daemon off"   57 seconds ago      Exited (0) 47 seconds ago                       docker-nginx
```

以上输出显示 Docker 容器已退出。我们可以使用如下命令删除现有的 docker-nginx 容器：

```bash
docker rm -vf docker-nginx
```

在下一步中，我们将容器与 `terminal` 分离，使其独立运行。

---

## 第 2 步 — 在 Daemon 模式下运行

使用以下命令创建一个新的 `Daemon` 模式的 `Nginx` 容器：

```bash
docker run -d --name docker-nginx -p 8080:80 nginx
```

输出如下：

```bash
b91f3ce26553f3ffc8115d2a8a3ad2706142e73d56dc279095f673580986257
```

通过使用 `-d` 标志，在后台运行此容器。通过 `docker ps` 命令可以查看运行的容器信息。

```bash
docker ps
```

```bash
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                 NAMES
b91f3ce26553   nginx     "/docker-entrypoint.…"   56 seconds ago   Up 54 seconds   0.0.0.0:8080->80/tcp, :::8080->80/tcp   docker-nginx
```

在 `STATUS` 列中显示了 `Up About a minute`，而不是 `Exited (0) X 分钟前`。另请注意，端口映射也是输出的一部分。

在浏览器中输入服务器的 IP 地址以再次访问默认的 Nginx 登录页面。这次它在后台运行，因为指定了 `-d` 标志，它告诉 `Docker` 在 `daemon` 模式下运行这个容器。

通过运行以下命令停止容器：

```bash
docker stop docker-nginx
```

现在容器已停止，通过运行以下命令将其删除：

```bash
docker rm docker-nginx
```

---

## 第 3 步 — 构建网页使之在 Nginx 上提供服务

在此步骤中，我们创建一个自定义页面，通过挂载的方式通过 `Nginx` 容器对外提供服务。

确保你在 `ex2.1` 目录中，然后编辑 `index.html` 文件：

```bash
# 确保在正确的目录
cd 1.0_Docker/ex2.1
vim index.html
```

> 点击 `i` 进入编辑模式，编辑内容，然后点击 `esc` 键退出编辑模式，输入 `:wq`，保存并退出

增加如下内容：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>我的第一个 Docker 网站</title>
</head>
<body>
    <h1>🐳 Hello Docker!</h1>
    <p>这个页面由 Nginx 容器提供服务</p>
    <p>恭喜你成功运行了第一个 Docker 容器！</p>
</body>
</html>
```

## 第 4 步 — 将容器链接到本地文件系统

在此步骤中，我们将 `Nginx` 链接到容器，以便可以通过端口：8080 公开访问它，并将其连接到服务器上的网站内容。

`Docker` 允许将目录从本地文件系统链接到容器中。

我们可以将文件作为 `Dockerfile` 的一部分复制到容器中，或者事后将它们复制（`docker cp`）到容器中，但这两种方法都无法动态更新网站内容。通过使用 `Docker` 的数据卷功能，可以在服务器的文件系统和容器的文件系统之间创建符号链接。可以编辑现有的网页文件并将新的文件添加到目录中。使用符号链接，容器将可以访问这些文件。

`Nginx` 容器默认设置为在 `/usr/share/nginx/html` 查找索引页。在新 `Docker` 容器中，我们需要授予它访问该位置文件的权限。

为此，请使用 `-v` 标志将当前目录映射到容器内的 `/usr/share/nginx/html` 目录，命令如下：

```bash
docker run --name docker-nginx -p 8080:80 -d -v $(pwd):/usr/share/nginx/html nginx
```

**命令参数说明：**

- `-v` - 开启数据卷挂载功能
- `$(pwd)` - 当前目录路径（冒号左侧）
- `/usr/share/nginx/html` - 容器内的目录路径（冒号右侧）
- `-p 8080:80` - 将容器的80端口映射到主机的8080端口
- `-d` - 后台运行模式（daemon）

我们可以将更多内容添加到当前目录中，它将添加到网站中。例如，如果修改 HTML 文件并刷新浏览器，它会相应更新。我们也可以通过这种方式使用 HTML 文件构建整个站点。例如，如果添加了一个 `about.html` 页面，我们可以通过 `http://your_server_ip/about.html` 访问它，而无需与容器交互。

---

## 基础命令

### 查看容器状态

```bash
# 查看正在运行的容器
docker ps

# 查看所有容器（包括已停止的）
docker ps -a
```

### 停止和删除容器

```bash
# 停止容器
docker stop docker-nginx

# 删除容器
docker rm docker-nginx
```

---

## 注意事项

1. **端口冲突**：确保主机的 8080 端口没有被其他服务占用
2. **权限问题**：在某些系统上可能需要使用 `sudo` 运行 Docker 命令
3. **防火墙设置**：确保防火墙允许 8080 端口的访问
4. **文件权限**：确保挂载的目录具有正确的读写权限

---

## 小结

通过本练习，你已经学会了：

✅ 从 Docker Hub 拉取 Nginx 镜像  
✅ 运行 Nginx 容器并进行端口映射  
✅ 使用数据卷挂载本地文件到容器  
✅ 理解容器的前台和后台运行模式  
✅ 使用基础的 Docker 命令管理容器  

恭喜你完成了第一个 Docker 容器练习！现在你可以继续学习更多 Docker 的高级功能。

---
