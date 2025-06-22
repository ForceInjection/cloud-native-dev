#!/bin/bash
# 软件包管理演示脚本
# 用于第六章：软件包管理

echo "=== 软件包管理演示 ==="
echo

# 检测系统类型
if [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM="macOS"
    PKG_MANAGER="brew"
elif command -v apt &> /dev/null; then
    SYSTEM="Debian/Ubuntu"
    PKG_MANAGER="apt"
elif command -v yum &> /dev/null; then
    SYSTEM="RHEL/CentOS (YUM)"
    PKG_MANAGER="yum"
elif command -v dnf &> /dev/null; then
    SYSTEM="Fedora/RHEL (DNF)"
    PKG_MANAGER="dnf"
else
    SYSTEM="Unknown"
    PKG_MANAGER="unknown"
fi

echo "检测到的系统: $SYSTEM"
echo "包管理器: $PKG_MANAGER"
echo

# 根据系统类型演示不同的包管理命令
case $PKG_MANAGER in
    "brew")
        echo "1. Homebrew 包管理演示"
        echo "更新包列表:"
        echo "brew update"
        echo
        
        echo "搜索软件包:"
        echo "brew search wget"
        brew search wget 2>/dev/null | head -5 || echo "搜索失败"
        echo
        
        echo "查看已安装的包:"
        echo "brew list"
        brew list 2>/dev/null | head -10 || echo "列表获取失败"
        echo
        
        echo "查看包信息:"
        echo "brew info git"
        brew info git 2>/dev/null | head -10 || echo "信息获取失败"
        echo
        ;;
        
    "apt")
        echo "1. APT 包管理演示"
        echo "更新包列表:"
        echo "sudo apt update"
        echo
        
        echo "搜索软件包:"
        echo "apt search wget"
        echo
        
        echo "查看已安装的包:"
        echo "dpkg -l | head -10"
        echo
        
        echo "查看包信息:"
        echo "apt show git"
        echo
        
        echo "模拟安装 (不实际安装):"
        echo "apt install --dry-run curl"
        echo
        ;;
        
    "yum")
        echo "1. YUM 包管理演示"
        echo "搜索软件包:"
        echo "yum search wget"
        echo
        
        echo "查看已安装的包:"
        echo "yum list installed | head -10"
        echo
        
        echo "查看包信息:"
        echo "yum info git"
        echo
        ;;
        
    "dnf")
        echo "1. DNF 包管理演示"
        echo "搜索软件包:"
        echo "dnf search wget"
        echo
        
        echo "查看已安装的包:"
        echo "dnf list installed | head -10"
        echo
        
        echo "查看包信息:"
        echo "dnf info git"
        echo
        ;;
        
    *)
        echo "1. 未知的包管理系统"
        echo "请根据您的系统选择合适的包管理器"
        echo
        ;;
esac

# 通用的包管理概念演示
echo "2. 包管理通用概念"
echo "依赖关系示例:"
echo "- 应用程序依赖库文件"
echo "- 库文件依赖其他库"
echo "- 包管理器自动解决依赖"
echo

echo "软件仓库概念:"
echo "- 官方仓库：系统默认的软件源"
echo "- 第三方仓库：额外的软件源"
echo "- 本地仓库：本地缓存的包"
echo

# 源码编译演示
echo "3. 源码编译安装演示"
echo "典型的编译安装步骤:"
echo "1. 下载源码: wget/curl 下载"
echo "2. 解压: tar -xzf package.tar.gz"
echo "3. 配置: ./configure"
echo "4. 编译: make"
echo "5. 安装: make install"
echo

echo "编译环境检查:"
echo "检查编译工具:"
which gcc 2>/dev/null && echo "GCC: 已安装" || echo "GCC: 未安装"
which make 2>/dev/null && echo "Make: 已安装" || echo "Make: 未安装"
which git 2>/dev/null && echo "Git: 已安装" || echo "Git: 未安装"
echo

echo "4. 包管理最佳实践"
echo "- 定期更新系统和软件包"
echo "- 只从可信的软件源安装软件"
echo "- 在安装前查看包的依赖关系"
echo "- 保持系统的包管理器数据库最新"
echo "- 谨慎使用第三方仓库"
echo

echo "演示完成"