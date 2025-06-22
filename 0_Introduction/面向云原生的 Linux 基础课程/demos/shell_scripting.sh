#!/bin/bash
# Shell 脚本编程演示
# 用于第七章：Shell 脚本编程

echo "=== Shell 脚本编程演示 ==="
echo

# 变量演示
echo "1. 变量演示"
NAME="Linux"
VERSION=5.4
echo "系统名称: $NAME"
echo "版本号: $VERSION"
echo "完整信息: ${NAME} ${VERSION}"
echo

# 命令行参数
echo "2. 命令行参数演示"
echo "脚本名称: $0"
echo "参数个数: $#"
echo "所有参数: $@"
if [ $# -gt 0 ]; then
    echo "第一个参数: $1"
else
    echo "没有提供参数"
fi
echo

# 条件判断
echo "3. 条件判断演示"
NUMBER=10
if [ $NUMBER -gt 5 ]; then
    echo "$NUMBER 大于 5"
elif [ $NUMBER -eq 5 ]; then
    echo "$NUMBER 等于 5"
else
    echo "$NUMBER 小于 5"
fi
echo

# 字符串比较
STRING="hello"
if [ "$STRING" = "hello" ]; then
    echo "字符串匹配成功"
fi
echo

# 文件测试
echo "4. 文件测试演示"
TEST_FILE="/tmp/test_file.txt"
echo "测试内容" > $TEST_FILE

if [ -f $TEST_FILE ]; then
    echo "文件 $TEST_FILE 存在"
    echo "文件大小: $(wc -c < $TEST_FILE) 字节"
fi

if [ -r $TEST_FILE ]; then
    echo "文件可读"
fi

if [ -w $TEST_FILE ]; then
    echo "文件可写"
fi
echo

# 循环演示
echo "5. 循环演示"
echo "for 循环 - 数字序列:"
for i in {1..5}; do
    echo "数字: $i"
done
echo

echo "for 循环 - 文件列表:"
for file in *.sh; do
    if [ -f "$file" ]; then
        echo "脚本文件: $file"
    fi
done
echo

echo "while 循环:"
COUNTER=1
while [ $COUNTER -le 3 ]; do
    echo "计数器: $COUNTER"
    COUNTER=$((COUNTER + 1))
done
echo

# 数组演示
echo "6. 数组演示"
FRUITS=("apple" "banana" "orange")
echo "所有水果: ${FRUITS[@]}"
echo "第一个水果: ${FRUITS[0]}"
echo "数组长度: ${#FRUITS[@]}"
echo

echo "遍历数组:"
for fruit in "${FRUITS[@]}"; do
    echo "水果: $fruit"
done
echo

# 函数演示
echo "7. 函数演示"

# 简单函数
greet() {
    echo "Hello, $1!"
}

# 带返回值的函数
addition() {
    local num1=$1
    local num2=$2
    local result=$((num1 + num2))
    echo $result
}

# 调用函数
greet "World"
RESULT=$(addition 5 3)
echo "5 + 3 = $RESULT"
echo

# 错误处理
echo "8. 错误处理演示"

# 检查命令执行状态
ls /nonexistent 2>/dev/null
if [ $? -ne 0 ]; then
    echo "命令执行失败"
fi

# 使用 set -e 进行错误处理
echo "错误处理最佳实践:"
echo "- 使用 set -e 在错误时退出"
echo "- 检查 \$? 获取命令退出状态"
echo "- 使用 trap 处理信号"
echo

# 字符串处理
echo "9. 字符串处理演示"
TEXT="Hello World Linux"
echo "原始字符串: $TEXT"
echo "字符串长度: ${#TEXT}"
echo "子字符串 (0-5): ${TEXT:0:5}"
echo "替换 World 为 Beautiful: ${TEXT/World/Beautiful}"
echo "转换为大写: ${TEXT^^}"
echo "转换为小写: ${TEXT,,}"
echo

# 输入输出重定向
echo "10. 输入输出重定向演示"
echo "写入文件:"
echo "这是测试内容" > /tmp/output.txt
echo "追加到文件:"
echo "这是追加内容" >> /tmp/output.txt
echo "读取文件内容:"
cat /tmp/output.txt
echo

# 管道演示
echo "11. 管道演示"
echo "使用管道处理数据:"
echo -e "apple\nbanana\norange\napple" | sort | uniq -c
echo

# 清理临时文件
rm -f $TEST_FILE /tmp/output.txt

echo "Shell 脚本编程演示完成！"
echo "提示：运行时可以传递参数测试命令行参数功能"
echo "例如：./shell_scripting.sh arg1 arg2 arg3"