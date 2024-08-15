# 关于（About）
This repository contains support files to create a very small and simple Docker container image, which can be used to demonstrate how Kubernetes probes work. This container image can be used as a simple container running NGINX web server on port 80, and the same can be used to run in "troublemaker" mode, as side-car, which tries to disrupt the readiness probes being run in the main container.


此存储库包含支持文件，用于创建一个非常小且简单的 Docker 容器映像，可用于演示 Kubernetes 探测器的工作原理。此容器映像可用作在端口 80 上运行 NGINX Web 服务器的简单容器，并且可用作 side-car 以 **“麻烦制造者”** 模式运行，试图破坏在主容器中运行的就绪探测器。

* 就绪探针：The readiness probe is assumed to be "GET /readinesscheck.txt" .
* 存活探针：The livenesss probe is assumed to be "GET /livenesscheck.txt" .
* 启动探针：The startup probe is assumed to be "GET /startupcheck.txt" .

此存储库中包含 PDF 格式的 PPT（A [related presentation](Introduction-to-Kubernetes-Probes.pdf) in the PDF format is included in this repository）。

# 如何使用镜像（How to use this image）：

If you run this image without any ENV variables, it will simply start a NGINX web-server on port 80, with a simple/custom/one-liner web page. If you set `START_DELAY` to some number of seconds, the container simply starts the web service *after* those number of seconds have passed. This is to mimic a slow starting container, such as Apache Tomcat, Atlassian Jira/Confluence, etc.

如果在没有任何 ENV 变量的情况下运行此映像，它将仅在端口 80 上启动 NGINX Web 服务器，并带有简单/自定义/一行网页。如果您将 `START_DELAY` 设置为某个秒数，则容器只会在这些秒数过去后启动 Web 服务。这是为了模拟启动缓慢的容器，例如 Apache Tomcat、Atlassian Jira/Confluence 等。

You can then use "readiness probes" in the related kubernetes deployment file to check if the container is considered ready for service.

然后，我们可以在相关的 kubernetes 部署文件中使用“就绪探测”来检查容器是否已准备好提供服务。

This container image can also run in a "TROUBLEMAKER" role. In that role, it keeps messing up with the readiness and liveness probes; the effects of which can then be observed for learning purpose. The image runs in this "TROUBLEMAKER" role, when a environment variable name "ROLE" is set to "TROUBLEMAKER". You will need to set the kubernetes `command` to `["/troublemaker.sh"]` and set the kubernetes `args` to  `["nginx", "-g", "daemon off;"]`.、

此容器映像还可以在 “TROUBLEMAKER” 角色中运行。在该角色中，它不断干扰就绪探测和活跃探测；然后可以观察其影响以进行学习。当环境变量名称 “ROLE” 设置为 “TROUBLEMAKER” 时，映像将在此“TROUBLEMAKER”角色中运行。您需要将 kubernetes `command` 设置为 `["/troublemaker.sh"]`，并将 kubernetes `args` 设置为 `["nginx", "-g", "daemon off;"]`。

**记住（Remember）：**
* `ENTRYPOINT` in Docker = `command` in kubernetes
* `CMD` in Docker = `args` in kubernetes 
* 如果您提供了 `command`（例如设置为 `/some-entrypoint.sh`），那么您还需要提供 `args`。
因为，出于某些愚蠢的原因，当手动指定 kubernetes `command` 时，`Dockerfile` 中定义的 `CMD` 会被忽略（If you provide a `command` (e.g. set to `/some-entrypoint.sh`), then you also need to provide `args`.
    As, for some silly reason the `CMD`  defined in the `Dockerfile` is ignored,
    when kubernetes `command` is specified manually）。

For TROUBLEMAKER to be able to mess with the readiness probe, it needs to randomly delete and create the `/readinesscheck.txt` file. It does that by running two shell processes, which fire up at random intervals. One of them creates the `/readinesscheck.txt` file, and the other deletes the file at another random interval.

为了让 TROUBLEMAKER 能够干扰就绪探测，它需要随机删除和创建 `/readinesscheck.txt` 文件。它通过运行两个 shell 进程来实现这一点，这两个进程会以随机间隔启动。其中一个创建 `/readinesscheck.txt` 文件，另一个则以另一个随机间隔删除该文件。

For TROUBLEMAKER to be able to mess with the liveness probe, it needs to randomly delete and create the `/livenesscheck.txt` file. It does that by running two shell processes, which fire up at random intervals. One of them creates the `/livenesscheck.txt` file, and the other deletes the file at another random interval.

为了使 TROUBLEMAKER 能够干扰活动性探测，它需要随机删除和创建 `/livenesscheck.txt` 文件。它通过运行两个 shell 进程来实现这一点，这两个进程以随机间隔启动。其中一个创建 `/livenesscheck.txt` 文件，另一个以另一个随机间隔删除该文件。

To be able to do these, the `DocumentRoot` directory of the main web container is mounted as a shared volume between the main container and the side-car. On the main container, it is mounted at the `/usr/share/nginx/html` mount-point. However, on the TROUBLEMAKER side-car, it is mounted on `/shared`. The troublemaker container knows that the `readinesscheck.txt` file is found/accessible as `/shared/readinesscheck.txt`, and the `livenesscheck.txt` file is found/accessible as `/shared/livenesscheck.txt`.

为了能够执行这些操作，主 Web 容器的 `DocumentRoot` 目录被安装为主容器和 side-car 之间的共享卷。在主容器上，它安装在 `/usr/share/nginx/html` 挂载点。然而，在 TROUBLEMAKER side-car 上，它安装在 `/shared` 上。troublemaker 容器知道 `readinesscheck.txt` 文件作为 `/shared/readinesscheck.txt` 找到/可访问，并且 `livenesscheck.txt` 文件作为 `/shared/livenesscheck.txt` 找到/可访问。

You can of-course run this in plain docker, or docker-compose, for very basic testing. However, the real behavior is observed in Kubernetes, and for that, some `deployment-*.yaml` files are provided.

当然，您可以在普通的 docker 或 docker-compose 中运行它，以进行非常基本的测试。但是，实际行为是在 Kubernetes 中观察到的，为此，提供了一些 `deployment-*.yaml` 文件。

**注意：**就绪性和活跃性探测可能完全不同。我选择两者都是 HTTP，因为它们更容易在实际中看到/更容易研究。
