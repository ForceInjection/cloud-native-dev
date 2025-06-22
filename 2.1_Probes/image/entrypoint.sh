#!/bin/sh
TIMESTAMP=$(date +%d-%m-%Y_%T)
DOCUMENT_ROOT=/usr/share/nginx/html

echo "${TIMESTAMP} - 容器已启动" 

# 检查是否设置了 START_DELAY 环境变量:
if [ "${START_DELAY}" != "" ]; then
  echo "${TIMESTAMP} - START_DELAY 设置为 ${START_DELAY} - 模拟慢启动容器，休眠 ${START_DELAY} 秒 ..."
  sleep ${START_DELAY}
else
  echo "${TIMESTAMP} - START_DELAY 未设置或设置为零 - 不进行休眠 ..."
fi

# 创建带有时间戳的 index.html 文件:
TIMESTAMP=$(date +%d-%m-%Y_%T)
MESSAGE="${TIMESTAMP} - Kubernetes 探针演示 - Web 服务已启动"
echo "${MESSAGE}"
echo "<h1>${MESSAGE}</h1>" > ${DOCUMENT_ROOT}/index.html

# 执行传入的 CMD 命令:
echo "${TIMESTAMP} - 正在执行: $@"
exec "$@"
