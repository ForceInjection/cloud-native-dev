# 第一阶段：构建阶段
FROM maven:3.8.7-eclipse-temurin-8 AS builder

# 设置工作目录
WORKDIR /usr/src/mymaven

# 复制pom.xml和源代码
COPY pom.xml .
COPY src ./src

# 构建项目
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -Dmaven.test.skip clean package

# 第二阶段：运行阶段
FROM eclipse-temurin:8u372-b07-jre-centos7

# 设置工作目录
WORKDIR /app

# 从构建阶段复制构建结果
COPY --from=builder /usr/src/mymaven/target/admin-service.jar ./admin-service.jar
COPY runboot.sh .

# 设置执行权限
RUN chmod a+x runboot.sh

# 暴露端口
EXPOSE 10000

# 启动命令
CMD ["sh", "-c", "/app/runboot.sh"]