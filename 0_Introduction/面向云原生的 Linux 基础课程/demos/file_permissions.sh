#!/bin/bash
# 文件权限演示脚本
# 用于第三章：文件系统和权限管理

echo "=== 文件权限演示 ==="
echo

# 创建测试文件
echo "创建测试文件..."
touch permission_test.txt
echo "This is a test file for permission demonstration" > permission_test.txt
echo

# 显示当前权限
echo "1. 查看文件权限"
ls -l permission_test.txt
echo

# 数字权限演示
echo "2. 数字权限演示"
echo "设置权限为 644 (rw-r--r--)"
chmod 644 permission_test.txt
ls -l permission_test.txt
echo

echo "设置权限为 755 (rwxr-xr-x)"
chmod 755 permission_test.txt
ls -l permission_test.txt
echo

echo "设置权限为 600 (rw-------)"
chmod 600 permission_test.txt
ls -l permission_test.txt
echo

# 符号权限演示
echo "3. 符号权限演示"
echo "给所有者添加执行权限 (u+x)"
chmod u+x permission_test.txt
ls -l permission_test.txt
echo

echo "给组用户添加读写权限 (g+rw)"
chmod g+rw permission_test.txt
ls -l permission_test.txt
echo

echo "移除其他用户的所有权限 (o-rwx)"
chmod o-rwx permission_test.txt
ls -l permission_test.txt
echo

# 目录权限演示
echo "4. 目录权限演示"
mkdir test_dir
echo "目录默认权限："
ls -ld test_dir
echo

echo "设置目录权限为 755"
chmod 755 test_dir
ls -ld test_dir
echo

# 所有权演示（需要适当的权限）
echo "5. 文件所有权"
echo "当前文件所有者："
ls -l permission_test.txt | awk '{print $3, $4}'
echo

# 特殊权限演示
echo "6. 特殊权限演示"
echo "设置粘滞位 (sticky bit)"
chmod +t test_dir
ls -ld test_dir
echo

# umask 演示
echo "7. umask 演示"
echo "当前 umask 值："
umask
echo

echo "创建新文件查看默认权限："
touch new_file.txt
ls -l new_file.txt
echo

# 清理
echo "8. 清理演示文件"
rm -f permission_test.txt new_file.txt
rmdir test_dir
echo "演示完成，文件已清理"