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

本项目的Jenkins流水线分为两个主要部分：

1. **Master节点执行阶段**：代码克隆、镜像构建和推送
2. **Slave节点执行阶段**：Kubernetes部署

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
- 认证信息：username=admin, password=Harbor12345

#### 第二部分：Slave节点流水线

**5. Clone YAML (部署文件克隆)：**

- 执行节点：slave
- 功能：克隆包含Kubernetes部署文件的代码仓库

**6. Config YAML (配置文件更新)：**

- 功能：使用sed命令替换YAML文件中的版本占位符
- 替换规则：将`{VERSION}`替换为`${BUILD_ID}`

**7. Deploy YAML (应用部署)：**

- 功能：部署应用到Kubernetes集群
- 部署文件：`./jenkins/scripts/prometheus-test-demo.yaml`
- 命令：`kubectl apply -f ./jenkins/scripts/prometheus-test-demo.yaml`

**8. Deploy ServiceMonitor YAML (监控配置部署)：**

- 功能：部署Prometheus ServiceMonitor配置
- 部署文件：`./jenkins/scripts/prometheus-test-serviceMonitor.yaml`
- 命令：`kubectl apply -f ./jenkins/scripts/prometheus-test-serviceMonitor.yaml`

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

## 7. 注意事项

1. **网络配置**: 确保Jenkins节点能够访问Git仓库、Harbor仓库和Kubernetes集群
2. **权限配置**: 确保Jenkins有足够权限执行Docker和kubectl命令
3. **资源限制**: 注意Maven构建过程中的内存使用
4. **版本管理**: BUILD_ID会作为镜像版本标签，确保唯一性
5. **安全考虑**: 生产环境中应使用更安全的认证方式替代明文密码

---

## 8. 故障排查

- **构建失败**: 检查Maven依赖和网络连接
- **镜像推送失败**: 验证Harbor仓库连接和认证信息
- **部署失败**: 检查Kubernetes集群状态和kubectl配置
- **监控不可用**: 验证ServiceMonitor配置和Prometheus operator状态
