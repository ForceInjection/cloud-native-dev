# 第一阶段：构建阶段
FROM maven:3.8.7-eclipse-temurin-8 AS builder

# 设置工作目录
WORKDIR /usr/src/mymaven

# 复制 Maven 配置文件
RUN mkdir -p /root/.m2
COPY settings.xml /root/.m2/settings.xml

# 复制pom.xml和源代码
COPY pom.xml .
COPY src ./src

# 构建项目
RUN mvn -B -DskipTests clean package

# 第二阶段：运行阶段
FROM eclipse-temurin:8u372-b07-jre-centos7

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

# 设置环境变量
ENV JAVA_OPTS ''

# 设置工作目录
WORKDIR /app

# 从构建阶段复制构建结果
COPY --from=builder /usr/src/mymaven/target/prometheus-test-demo-0.0.1-SNAPSHOT.jar ./prometheus-test-demo-0.0.1-SNAPSHOT.jar

# 启动命令
ENTRYPOINT ["sh", "-c", "set -e && java -XX:+PrintFlagsFinal \
                                           -XX:+HeapDumpOnOutOfMemoryError \
                                           -XX:HeapDumpPath=/heapdump/heapdump.hprof \
                                           -XX:+UnlockExperimentalVMOptions \
                                           -XX:+UseCGroupMemoryLimitForHeap \
                                           $JAVA_OPTS -jar prometheus-test-demo-0.0.1-SNAPSHOT.jar"]