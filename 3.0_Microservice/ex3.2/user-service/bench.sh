#!/bin/bash

# 设置请求的 URL 和请求头
url="http://127.0.0.1:32572/user?id=1"
header="Accept: application/json"

# 定义请求函数
make_request() {
    local id=$1
    
    # 记录开始时间
    start_time=$(date +%s.%N)
    
    # 发起请求并捕获完整输出
    result=$(curl -H "$header" "$url" -s -w " HTTP_CODE:%{http_code}" 2>&1)
    
    # 记录结束时间
    end_time=$(date +%s.%N)
    
    # 计算请求时间
    elapsed_time=$(echo "$end_time - $start_time" | bc)
    
    # 输出完整返回和时间
    echo "$id: $result, 请求时间: ${elapsed_time}s"
}

# 执行循环
for ((i=1; i<=30; i++)); do
    make_request "$i" &   # 第一个请求放入后台
    make_request "$((i + 1))" & # 第二个请求放入后台
    
    wait  # 等待两个请求完成
    i=$((i + 1))  # 跳过下一个已处理的请求
done
