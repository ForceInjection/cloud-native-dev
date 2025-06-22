#!/bin/bash
# Linux 基础命令演示脚本
# 用于第二章：Linux 基础操作

echo "=== Linux 基础命令演示 ==="
echo

# 文件和目录操作
echo "1. 文件和目录操作"
echo "当前目录："
pwd
echo

echo "创建测试目录："
mkdir -p demo_dir/subdir
echo "目录创建完成"
echo

echo "列出目录内容："
ls -la
echo

echo "创建测试文件："
touch demo_dir/test1.txt demo_dir/test2.txt
echo "hello world" > demo_dir/test1.txt
echo "Linux is awesome" > demo_dir/test2.txt
echo "文件创建完成"
echo

# 文件查看命令
echo "2. 文件查看命令"
echo "使用 cat 查看文件："
cat demo_dir/test1.txt
echo

echo "使用 head 查看文件开头："
head -n 1 demo_dir/test2.txt
echo

echo "使用 tail 查看文件结尾："
tail -n 1 demo_dir/test2.txt
echo

# 文件搜索
echo "3. 文件搜索"
echo "使用 find 查找文件："
find demo_dir -name "*.txt"
echo

echo "使用 grep 搜索文本："
grep "world" demo_dir/test1.txt
echo

# 文件权限
echo "4. 文件权限"
echo "查看文件权限："
ls -l demo_dir/test1.txt
echo

echo "修改文件权限："
chmod 755 demo_dir/test1.txt
ls -l demo_dir/test1.txt
echo

# 清理
echo "5. 清理演示文件"
rm -rf demo_dir
echo "演示完成，文件已清理"