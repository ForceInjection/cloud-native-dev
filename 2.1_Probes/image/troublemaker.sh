#!/bin/sh
TIMESTAMP=$(date +%d-%m-%Y_%T)
READINESSCHECK_FILE=/shared/readinesscheck.txt
LIVENESSCHECK_FILE=/shared/livenesscheck.txt


function create_readinesscheck_file()
{
  while true; do 
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - 创建就绪检查文件前休眠 ${DURATION} 秒 ..."
    sleep ${DURATION}
    echo readinesscheck > ${READINESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - 已创建就绪检查文件: '${READINESSCHECK_FILE}'，休眠了 ${DURATION} 秒 ..."
    
  done
}

function delete_readinesscheck_file()
{
  while true; do
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - 删除就绪检查文件前休眠 ${DURATION} 秒 ..."
    sleep ${DURATION}
    rm ${READINESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - 已删除就绪检查文件: '${READINESSCHECK_FILE}'，休眠了 ${DURATION} 秒 ..."
  done
}

function create_livenesscheck_file()
{
  while true; do 
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - 创建存活检查文件前休眠 ${DURATION} 秒 ..."
    sleep ${DURATION}
    echo livenesscheck > ${LIVENESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - 已创建存活检查文件: '${LIVENESSCHECK_FILE}'，休眠了 ${DURATION} 秒 ..."
  done
}

function delete_livenesscheck_file()
{
  while true; do
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    DURATION=${RANDOM:1:2}
    echo "${TIMESTAMP} - 删除存活检查文件前休眠 ${DURATION} 秒 ..."
    sleep ${DURATION}
    rm ${LIVENESSCHECK_FILE}
    local TIMESTAMP=$(date +%d-%m-%Y_%T)
    echo "${TIMESTAMP} - 已删除存活检查文件: '${LIVENESSCHECK_FILE}'，休眠了 ${DURATION} 秒 ..."
  done
}

# 将 nginx 端口改为 8888
sed -i "s/80;/8888;/g" /etc/nginx/conf.d/default.conf

if [ "${ROLE}" == "TROUBLEMAKER" ]; then
  MESSAGE=" ${TIMESTAMP} - 容器已在故障制造者模式下启动 - 端口 8888"
  echo ${MESSAGE}
  echo "<h1>${MESSAGE}</h1>" > /usr/share/nginx/html/index.html
  
  # 在后台启动以下进程，
  # 让它们以随机延迟持续运行。
  
  echo "${TIMESTAMP} - 在后台启动创建就绪检查文件进程..."
  create_readinesscheck_file &

  echo "${TIMESTAMP} - 在后台启动删除就绪检查文件进程..."
  delete_readinesscheck_file &

  echo "${TIMESTAMP} - 在后台启动创建存活检查文件进程..."
  create_livenesscheck_file &

  echo "${TIMESTAMP} - 在后台启动删除存活检查文件进程..."
  delete_livenesscheck_file &


else

  MESSAGE="${TIMESTAMP} - 容器已在正常模式下启动 - 端口 8888"
  echo ${MESSAGE}
  echo "<h1>${MESSAGE}</h1>" > /usr/share/nginx/html/index.html

fi


# 执行传入的 CMD 命令。
echo "正在执行: $@"
exec "$@"
