# 镜像加速配置说明

## 概述

本 HPA 部署方案已针对国内网络环境进行优化，所有容器镜像均使用 DaoCloud 提供的镜像加速服务，显著提升镜像拉取速度和部署成功率。

## 使用的镜像加速源

根据 [DaoCloud 镜像加速服务](https://github.com/DaoCloud/public-image-mirror) 的最佳实践，本方案使用以下镜像配置：

### 1. Nginx 应用镜像

- **原始镜像**: `nginx:1.21`
- **加速镜像**: `docker.m.daocloud.io/library/nginx:1.21`
- **使用文件**:
  - `hpa-example.yaml`
  - `hpa-custom-metrics-example.yaml`

### 2. Metrics Server 镜像

- **原始镜像**: `registry.k8s.io/metrics-server/metrics-server:v0.6.4`
- **加速镜像**: `k8s.m.daocloud.io/metrics-server/metrics-server:v0.6.4`
- **使用文件**: `metrics-server.yaml`

## 镜像加速优势

### 1. 网络性能提升

- **下载速度**: 相比官方源，下载速度提升 5-10 倍
- **连接稳定性**: 减少网络超时和连接失败
- **部署成功率**: 显著提高容器镜像拉取成功率

### 2. 本地化优化

- **CDN 加速**: 利用国内 CDN 节点就近访问
- **缓存机制**: 热门镜像预缓存，首次拉取即可享受加速
- **实时同步**: 与官方源保持实时同步，确保镜像版本一致性

## 配置验证

### 验证镜像配置

```bash
# 检查 Metrics Server 镜像
kubectl get deployment metrics-server -n kube-system -o jsonpath='{.spec.template.spec.containers[0].image}'

# 检查示例应用镜像
kubectl get deployment nginx-hpa-demo -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### 验证镜像拉取速度

```bash
# 测试镜像拉取时间
time docker pull docker.m.daocloud.io/library/nginx:1.21
```

## 自定义镜像配置

如果您需要在其他部署中使用镜像加速，可以参考以下映射规则：

### 常用镜像源映射

| 原始镜像源 | DaoCloud 加速源 | 示例 |
|-----------|----------------|------|
| `docker.io` | `docker.m.daocloud.io` | `nginx:1.21` → `docker.m.daocloud.io/library/nginx:1.21` |
| `registry.k8s.io` | `k8s.m.daocloud.io` | `registry.k8s.io/metrics-server/metrics-server:v0.6.4` → `k8s.m.daocloud.io/metrics-server/metrics-server:v0.6.4` |
| `gcr.io` | `gcr.m.daocloud.io` | `gcr.io/project/image:tag` → `gcr.m.daocloud.io/project/image:tag` |
| `quay.io` | `quay.m.daocloud.io` | `quay.io/project/image:tag` → `quay.m.daocloud.io/project/image:tag` |

### 推荐使用方式

1. **添加前缀方式**（推荐）：在原镜像前添加 `m.daocloud.io/`
2. **直接替换方式**：使用对应的加速域名替换原域名

## 注意事项

1. **镜像一致性**: 所有加速镜像的 SHA256 哈希值与官方源保持一致
2. **缓存延迟**: 新发布的镜像可能存在 1 小时的同步延迟
3. **使用建议**: 建议在凌晨时段（北京时间 01-07 点）进行大量镜像拉取操作
4. **版本标签**: 推荐使用明确的版本号标签，避免使用 `latest` 标签

## 故障排除

### 镜像拉取失败

```bash
# 检查镜像是否存在
docker pull docker.m.daocloud.io/library/nginx:1.21

# 如果加速源失败，可以回退到官方源
docker pull nginx:1.21
```

### 网络连接问题

```bash
# 测试网络连通性
curl -I https://docker.m.daocloud.io/v2/

# 检查 DNS 解析
nslookup docker.m.daocloud.io
```

## 相关资源

- [DaoCloud 镜像加速服务](https://github.com/DaoCloud/public-image-mirror)
- [DaoCloud Helm Charts 加速](https://github.com/DaoCloud/public-helm-charts-mirror)
- [DaoCloud 二进制文件加速](https://github.com/DaoCloud/public-binary-files-mirror)
