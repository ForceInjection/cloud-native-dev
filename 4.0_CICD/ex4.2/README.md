# Jenkins CI/CD 流水线项目

这是一个基于Jenkins的CI/CD流水线项目，用于自动化构建、测试和部署Spring Boot应用到Kubernetes集群。

---

## 1. 项目概述

本项目是一个Spring Boot应用，集成了Prometheus监控指标，通过Jenkins流水线实现自动化的DevOps流程。

### 1.1 技术栈

- **应用框架**: Spring Boot 2.1.13
- **构建工具**: Maven 3
- **容器化**: Docker
- **编排平台**: Kubernetes
- **CI/CD工具**: Jenkins
- **监控**: Prometheus + Actuator
- **镜像仓库**: Harbor

---

## 2. Jenkins 流水线说明

### 2.1 流水线架构

本项目采用统一的声明式Jenkins流水线架构，包含以下主要阶段：

1. **Master节点执行阶段**：代码克隆、镜像构建和推送
2. **Slave节点执行阶段**：Kubernetes部署和健康检查
3. **自动清理阶段**：镜像清理和资源回收

### 2.2 流水线阶段详解

#### 第一部分：Master节点流水线

**1. Clone Code (代码克隆)：**

- 执行节点：master
- 功能：从Gitee仓库克隆源代码
- Git仓库：`https://gitee.com/sundandan1/prometheus-test-demo.git`

**2. Maven Build (Maven构建)：**

- 执行环境：Docker容器 (`maven:3-alpine`)
- 功能：使用Maven编译打包应用
- 挂载卷：`/root/.m2:/root/.m2` (Maven本地仓库缓存)
- 构建命令：`mvn -B -DskipTests clean package`

**3. Image Build (镜像构建)：**

- 执行节点：master
- 功能：构建Docker镜像并打标签
- 镜像名称：`prometheus-test-demo:${BUILD_ID}`
- Harbor仓库标签：`172.22.83.19:30003/library/prometheus-test-demo:${BUILD_ID}`

**4. Push (镜像推送)：**

- 执行节点：master
- 功能：推送镜像到Harbor仓库
- Harbor地址：`172.22.83.19:30003`
- 认证方式：使用Jenkins凭据管理（harbor-credentials）
- 安全登录：采用stdin方式避免密码暴露
- 双标签推送：同时推送BUILD_NUMBER和latest标签

#### 第二部分：Kubernetes部署阶段

**5. Clone YAML (部署文件克隆)：**

- 执行节点：slave (jnlp-kubectl容器)
- 功能：使用checkout scm获取部署文件

**6. Config YAML (配置文件更新)：**

- 功能：使用sed命令替换YAML文件中的占位符
- 替换规则：
  - `{VERSION}` → `${BUILD_NUMBER}`
  - `{NAMESPACE}` → 参数化命名空间
  - `{MONITOR_NAMESPACE}` → 监控命名空间

**7. Deploy Application (应用部署)：**

- 功能：部署应用到Kubernetes集群
- 部署文件：`./jenkins/scripts/prometheus-test-demo.yaml`
- 命令：`kubectl apply -f ./jenkins/scripts/prometheus-test-demo.yaml`

**8. Deploy ServiceMonitor (监控配置部署)：**

- 功能：部署Prometheus ServiceMonitor配置
- 部署文件：`./jenkins/scripts/prometheus-test-serviceMonitor.yaml`
- 命令：`kubectl apply -f ./jenkins/scripts/prometheus-test-serviceMonitor.yaml`

**9. Health Check (健康检查)：**

- 功能：验证应用部署状态
- 检查方式：`kubectl wait --for=condition=ready`
- 超时设置：300秒
- 标签选择器：`app=prometheus-test-demo`

#### 第三部分：清理和通知阶段

**10. Image Cleanup (镜像清理)：**

- 执行时机：流水线完成后（无论成功或失败）
- 清理内容：
  - 构建的镜像标签
  - latest标签镜像
  - 未使用的Docker资源
- 清理命令：`docker rmi` 和 `docker system prune`

---

## 3. 项目文件结构

```bash
ex4.2/
├── Dockerfile                    # Docker镜像构建文件
├── Jenkinsfile                   # Jenkins流水线定义文件
├── README.md                     # 项目说明文档
├── pom.xml                       # Maven项目配置文件
├── src/                          # 源代码目录
│   ├── main/java/               # Java源代码
│   └── test/java/               # 测试代码
└── jenkins/scripts/              # Kubernetes部署文件
├── prometheus-test-demo.yaml          # 应用部署配置
└── prometheus-test-serviceMonitor.yaml # Prometheus监控配置
```

---

## 4. 应用配置

### 4.1 Kubernetes部署配置

- **命名空间**: default
- **副本数**: 1
- **服务类型**: NodePort
- **应用端口**: 8998
- **镜像**: 172.22.83.19:30003/library/prometheus-test-demo:{VERSION}

### 4.2 Prometheus监控配置

- **监控路径**: `/actuator/prometheus`
- **监控端口**: 8998
- **采集间隔**: 30秒
- **ServiceMonitor命名空间**: monitor

---

## 5. 使用方法

### 5.1 前置条件

1. Jenkins服务器已配置master和slave节点
2. Docker环境已安装
3. Kubernetes集群可访问
4. Harbor镜像仓库可访问
5. 已配置kubectl访问权限

### 5.2 运行流水线

1. 在Jenkins中创建新的Pipeline项目
2. 配置Pipeline脚本来源为SCM
3. 指定Git仓库和Jenkinsfile路径
4. 触发构建

### 5.3 访问应用

构建完成后，可以通过以下方式访问：

- **应用访问**: 通过Kubernetes NodePort服务访问
- **监控指标**: <http://localhost:8998/actuator/prometheus>
- **健康检查**: <http://localhost:8998/actuator/health>

---

## 6. 监控集成

本项目集成了Spring Boot Actuator和Micrometer，支持Prometheus监控：

- 自动暴露应用指标
- 支持自定义业务指标
- 通过ServiceMonitor自动发现和采集

---

## 7. 安全和最佳实践

### 7.1 安全改进

1. **凭据管理**: 使用Jenkins凭据存储替代硬编码密码
2. **安全登录**: Docker登录采用stdin方式避免密码在进程列表中暴露
3. **权限最小化**: 确保Jenkins节点只有必要的权限
4. **网络隔离**: 合理配置网络策略和防火墙规则

### 7.2 资源管理

1. **镜像清理**: 自动清理构建镜像避免磁盘空间不足
2. **资源监控**: 监控Maven构建过程中的内存和CPU使用
3. **并发控制**: 合理设置并发构建数量

### 7.3 运维注意事项

1. **网络配置**: 确保Jenkins节点能够访问Git仓库、Harbor仓库和Kubernetes集群
2. **权限配置**: 确保Jenkins有足够权限执行Docker和kubectl命令
3. **版本管理**: BUILD_NUMBER作为镜像版本标签，确保唯一性
4. **参数化部署**: 支持不同命名空间的灵活部署
5. **健康检查**: 自动验证部署状态，及时发现问题

---

## 8. 故障排查

### 8.1 构建阶段问题

- **代码克隆失败**: 检查Git仓库访问权限和网络连接
- **Maven构建失败**: 验证依赖配置和settings.xml
- **Docker构建失败**: 检查Dockerfile语法和基础镜像可用性

### 8.2 推送阶段问题

- **Harbor登录失败**: 验证凭据配置和网络连接
- **镜像推送失败**: 检查Harbor存储空间和权限设置
- **网络超时**: 调整网络配置和超时设置

### 8.3 部署阶段问题

- **kubectl连接失败**: 验证Kubernetes集群配置和认证
- **YAML应用失败**: 检查资源配置和命名空间权限
- **ServiceMonitor部署失败**: 确认Prometheus Operator安装状态
- **健康检查超时**: 检查Pod启动日志和资源限制

### 8.4 清理阶段问题

- **镜像清理失败**: 检查Docker daemon状态和权限
- **磁盘空间不足**: 手动清理或增加存储空间

---

## 9. 流水线优化建议

### 9.1 性能优化

1. **并行构建**: 考虑将测试和构建阶段并行化
2. **缓存策略**: 优化Maven和Docker层缓存
3. **资源分配**: 根据负载调整节点资源配置

### 9.2 可靠性提升

1. **重试机制**: 为网络相关操作添加重试逻辑
2. **回滚策略**: 实现自动回滚机制
3. **监控告警**: 集成流水线状态监控和告警

### 9.3 扩展功能

1. **多环境支持**: 扩展支持开发、测试、生产环境
2. **自动化测试**: 集成单元测试和集成测试
3. **代码质量检查**: 集成SonarQube等代码质量工具
