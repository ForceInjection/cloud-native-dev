# 第七章：Shell 脚本编程

## 7.1 Shell 脚本基础

### 7.1.1 脚本文件创建和执行

**什么是 Shell 脚本**：

Shell 脚本是包含一系列命令的文本文件，可以自动化执行重复性任务。

```bash
# Shell 脚本的优势：
# 1. 自动化重复任务
# 2. 批量处理文件
# 3. 系统管理和监控
# 4. 简化复杂操作
# 5. 提高工作效率

# 常用的 Shell 类型：
# - bash (Bourne Again Shell) - 最常用
# - sh (Bourne Shell) - 传统 Shell
# - zsh (Z Shell) - 功能丰富
# - fish (Friendly Interactive Shell) - 用户友好
# - dash (Debian Almquist Shell) - 轻量级
```

**创建第一个脚本**：

请参考 `demos/shell_scripting.sh` 脚本中的基础脚本创建部分。

**Shebang（#!）的作用**：

请参考 `demos/shell_scripting.sh` 脚本中的 Shebang 说明和示例。

### 7.1.2 变量定义和使用

**变量基础**：

请参考 `demos/shell_scripting.sh` 脚本中的变量定义和使用部分。

**变量类型和作用域**：

请参考 `demos/shell_scripting.sh` 脚本中的变量类型和作用域部分。

**字符串操作**：

请参考 `demos/shell_scripting.sh` 脚本中的字符串操作部分。

### 7.1.3 命令行参数处理

**基本参数处理**：

请参考 `demos/shell_scripting.sh` 脚本中的命令行参数处理部分。

**高级参数处理**：

请参考 `demos/shell_scripting.sh` 脚本中的高级参数处理部分。

## 7.2 控制结构

### 7.2.1 条件判断：if-then-else

**基本条件判断**：

```bash
#!/usr/bin/env bash

# 基本 if 语句
age=18

if [ $age -ge 18 ]; then
    echo "你已经成年了"
fi

# if-else 语句
score=85

if [ $score -ge 90 ]; then
    echo "优秀"
else
    echo "良好"
fi

# if-elif-else 语句
if [ $score -ge 90 ]; then
    echo "优秀（90-100）"
elif [ $score -ge 80 ]; then
    echo "良好（80-89）"
elif [ $score -ge 70 ]; then
    echo "中等（70-79）"
elif [ $score -ge 60 ]; then
    echo "及格（60-69）"
else
    echo "不及格（<60）"
fi
```

**测试条件详解**：

```bash
#!/usr/bin/env bash

# 数值比较
num1=10
num2=20

if [ $num1 -eq $num2 ]; then echo "相等"; fi          # 等于
if [ $num1 -ne $num2 ]; then echo "不等于"; fi        # 不等于
if [ $num1 -lt $num2 ]; then echo "小于"; fi          # 小于
if [ $num1 -le $num2 ]; then echo "小于等于"; fi      # 小于等于
if [ $num1 -gt $num2 ]; then echo "大于"; fi          # 大于
if [ $num1 -ge $num2 ]; then echo "大于等于"; fi      # 大于等于

# 字符串比较
str1="hello"
str2="world"

if [ "$str1" = "$str2" ]; then echo "字符串相等"; fi
if [ "$str1" != "$str2" ]; then echo "字符串不等"; fi
if [ "$str1" \< "$str2" ]; then echo "字符串1小于字符串2"; fi
if [ -z "$str1" ]; then echo "字符串为空"; fi
if [ -n "$str1" ]; then echo "字符串非空"; fi

# 文件测试
file="/etc/passwd"

if [ -e "$file" ]; then echo "文件存在"; fi
if [ -f "$file" ]; then echo "是普通文件"; fi
if [ -d "$file" ]; then echo "是目录"; fi
if [ -r "$file" ]; then echo "文件可读"; fi
if [ -w "$file" ]; then echo "文件可写"; fi
if [ -x "$file" ]; then echo "文件可执行"; fi
if [ -s "$file" ]; then echo "文件非空"; fi

# 逻辑运算
if [ $num1 -lt $num2 ] && [ $num1 -gt 0 ]; then
    echo "num1 在 0 和 num2 之间"
fi

if [ $num1 -eq 0 ] || [ $num2 -eq 0 ]; then
    echo "至少有一个数为0"
fi

if ! [ $num1 -eq $num2 ]; then
    echo "两个数不相等"
fi
```

**现代测试语法**：

请参考 `demos/shell_scripting.sh` 脚本中的现代测试语法部分。

### 循环结构：for、while

**for 循环**：

for 循环用于遍历列表或序列中的每一项。

```bash
#!/usr/bin/env bash

# 遍历列表
for name in Alice Bob Charlie; do
    echo "Hello, $name!"
done

# 遍历数字范围
for i in {1..5}; do
    echo "第 $i 次迭代"
done

# 遍历文件
for file in *.txt; do
    echo "处理文件: $file"
    wc -l "$file"
done

# C 风格 for 循环
for ((i = 0; i < 5; i++)); do
    echo "i = $i"
done
```

**while 循环**：

while 循环在条件为真时反复执行。

```bash
#!/usr/bin/env bash

# 计数器
count=1
while [ $count -le 5 ]; do
    echo "计数: $count"
    ((count++))
done

# 逐行读取文件
while IFS= read -r line; do
    echo "行内容: $line"
done < /etc/hosts

# 无限循环（Ctrl+C 终止）
while true; do
    echo "$(date): 系统正常"
    sleep 10
done
```

请参考 `demos/shell_scripting.sh` 脚本中的循环控制部分。

### 7.2.2 函数定义和调用

函数将一段可复用的命令封装为命名单元。

```bash
#!/usr/bin/env bash

# 基本函数定义和调用
greet() {
    echo "Hello, $1!"
}

greet "World"     # 输出: Hello, World!
greet "Linux"     # 输出: Hello, Linux!

# 带返回值的函数
is_even() {
    if (( $1 % 2 == 0 )); then
        return 0    # 成功（偶数）
    else
        return 1    # 失败（奇数）
    fi
}

if is_even 42; then
    echo "42 是偶数"
fi

# 函数输出捕获
get_date() {
    date "+%Y-%m-%d %H:%M:%S"
}
now=$(get_date)
echo "当前时间: $now"
```

### 7.2.3 错误处理和退出状态

每个命令执行后都会设置 `$?`——0 表示成功，非 0 表示失败。

```bash
#!/usr/bin/env bash

# 检查命令是否成功
if grep "root" /etc/passwd > /dev/null; then
    echo "找到 root 用户"
else
    echo "错误: 未找到 root 用户" >&2
    exit 1
fi

# set -e: 任何命令失败立即退出
# set -u: 使用未定义变量时退出
set -eu

# 典型的安全脚本开头
#!/usr/bin/env bash
set -euo pipefail  # 严格模式：遇错退出 + 未定义变量报错 + 管道失败检测
```

## 7.3 实用脚本示例

### 7.3.1 系统监控脚本

请参考 `demos/system_monitor.sh` 脚本，该脚本提供了完整的系统资源监控功能。

### 7.3.2 日志分析脚本

请参考 `demos/log_analyzer.sh` 脚本，该脚本提供了完整的 Web 服务器日志分析功能。

### 7.3.3 自动化部署脚本

请参考 `demos/auto_deploy.sh` 脚本，该脚本提供了完整的自动化部署功能，包括 Git 拉取、构建、部署和回滚。

---
