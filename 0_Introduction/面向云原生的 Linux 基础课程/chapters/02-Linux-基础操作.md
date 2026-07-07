# 第二章：Linux 基础操作

> **配套 Demo**：[`demos/basic_commands.sh`](../demos/basic_commands.sh)（基础命令）、[`demos/file_permissions.sh`](../demos/file_permissions.sh)（权限管理）

## 2.1 终端和 Shell

### 2.1.1 终端模拟器的使用

终端模拟器是图形界面下访问命令行的工具，它模拟了传统的文本终端。

**常见终端模拟器：**

- **GNOME Terminal**：Ubuntu 默认终端
- **Konsole**：KDE 桌面环境终端
- **iTerm2**：macOS 上功能强大的终端
- **Windows Terminal**：Windows 现代终端
- **Terminator**：支持分屏的终端

**终端基本操作：**

```bash
# 打开新标签页
Ctrl + Shift + T

# 关闭当前标签页
Ctrl + Shift + W

# 切换标签页
Ctrl + PageUp/PageDown

# 复制粘贴
Ctrl + Shift + C  # 复制
Ctrl + Shift + V  # 粘贴

# 清屏
Ctrl + L 或 clear 命令
```

### 2.1.2 Bash Shell 基础

Bash（Bourne Again Shell）是 Linux 系统中最常用的 Shell。

**Bash 特性：**

1. **命令历史**：记录之前执行的命令
2. **命令补全**：Tab 键自动补全
3. **别名支持**：为长命令创建短别名
4. **作业控制**：管理前台和后台进程
5. **脚本编程**：支持复杂的脚本逻辑

**环境变量：**

```bash
# 查看所有环境变量
env

# 查看特定变量
echo $HOME
echo $PATH
echo $USER

# 设置环境变量
export MY_VAR="Hello World"

# 查看 Shell 类型
echo $SHELL
```

### 2.1.3 命令行提示符解读

典型的 Bash 提示符格式：

```bash
username@hostname:current_directory$
```

**提示符组成部分：**

- **username**：当前用户名
- **hostname**：主机名
- **current_directory**：当前目录
  - `~` 表示用户主目录
  - `/` 表示根目录
- **$**：普通用户提示符
- **#**：root 用户提示符

**示例：**

```bash
# 普通用户
student@ubuntu:~/Documents$

# root 用户
root@ubuntu:/etc#

# 在根目录
student@ubuntu:/$
```

**自定义提示符：**

```bash
# 临时修改
PS1="[\u@\h \W]\$ "

# 永久修改（添加到 ~/.bashrc）
echo 'PS1="[\u@\h \W]\$ "' >> ~/.bashrc
source ~/.bashrc
```

### 2.1.4 快捷键和命令历史

**常用快捷键：**

```bash
# 光标移动
Ctrl + A    # 移动到行首
Ctrl + E    # 移动到行尾
Ctrl + F    # 向前移动一个字符
Ctrl + B    # 向后移动一个字符
Alt + F     # 向前移动一个单词
Alt + B     # 向后移动一个单词

# 文本编辑
Ctrl + U    # 删除光标到行首的内容
Ctrl + K    # 删除光标到行尾的内容
Ctrl + W    # 删除光标前的单词
Ctrl + Y    # 粘贴之前删除的内容

# 进程控制
Ctrl + C    # 终止当前进程
Ctrl + Z    # 暂停当前进程
Ctrl + D    # 发送 EOF 或退出
```

**命令历史管理：**

```bash
# 查看命令历史
history

# 执行历史命令
!!          # 执行上一条命令
!n          # 执行第 n 条历史命令
!string     # 执行最近以 string 开头的命令

# 搜索历史命令
Ctrl + R    # 反向搜索
Ctrl + S    # 正向搜索

# 历史命令配置
echo $HISTSIZE      # 内存中保存的历史命令数
echo $HISTFILESIZE  # 文件中保存的历史命令数

# 清除历史
history -c  # 清除当前会话历史
> ~/.bash_history  # 清除历史文件
```

## 2.2 文件系统导航

### 2.2.1 Linux 目录结构

Linux 采用树形目录结构，所有文件和目录都从根目录（/）开始。这种统一的文件系统层次结构（FHS - Filesystem Hierarchy Standard）确保了不同Linux发行版之间的一致性。

#### 标准目录结构总览

```text
/
├── bin/          # 基本命令二进制文件（Essential user command binaries）
├── boot/         # 启动文件（Static files of the boot loader）
├── dev/          # 设备文件（Device files）
├── etc/          # 系统配置文件（Host-specific system configuration）
├── home/         # 用户主目录（User home directories）
├── lib/          # 共享库文件（Essential shared libraries and kernel modules）
├── lib64/        # 64位共享库文件
├── media/        # 可移动媒体挂载点（Mount point for removable media）
├── mnt/          # 临时挂载点（Mount point for temporarily mounted filesystems）
├── opt/          # 可选软件包（Add-on application software packages）
├── proc/         # 进程和系统信息（Kernel and process information virtual filesystem）
├── root/         # root 用户主目录（Home directory for the root user）
├── run/          # 运行时数据（Data relevant to running processes）
├── sbin/         # 系统管理命令（Essential system binaries）
├── srv/          # 服务数据（Data for services provided by this system）
├── sys/          # 系统文件系统（Kernel and system information virtual filesystem）
├── tmp/          # 临时文件（Temporary files）
├── usr/          # 用户程序（Secondary hierarchy）
└── var/          # 变量数据（Variable data）
```

#### 重要目录详解

##### 1. **/etc** - 系统配置文件目录

这是系统的"控制中心"，包含所有系统级配置文件。

```bash
# 用户和权限管理
/etc/passwd     # 用户账户信息
/etc/shadow     # 用户密码哈希（需要root权限查看）
/etc/group      # 用户组信息
/etc/sudoers    # sudo权限配置

# 网络配置
/etc/hosts      # 主机名解析
/etc/resolv.conf # DNS配置
/etc/network/   # 网络接口配置（Debian/Ubuntu）
/etc/sysconfig/network-scripts/ # 网络配置（RHEL/CentOS）

# 系统服务
/etc/systemd/   # systemd服务配置
/etc/init.d/    # 传统init脚本
/etc/crontab    # 系统级定时任务

# 文件系统
/etc/fstab      # 文件系统挂载配置
/etc/mtab       # 当前挂载的文件系统

# 应用程序配置
/etc/ssh/       # SSH服务配置
/etc/nginx/     # Nginx配置
/etc/docker/    # Docker配置
```

##### 2. **/var** - 变量数据目录

存储经常变化的数据，如日志、缓存、数据库等。

```bash
# 日志文件
/var/log/       # 系统日志目录
/var/log/syslog # 系统日志（Ubuntu/Debian）
/var/log/messages # 系统消息（RHEL/CentOS）
/var/log/auth.log # 认证日志
/var/log/nginx/ # Nginx日志

# 应用程序数据
/var/lib/       # 应用程序状态数据
/var/lib/docker/ # Docker数据
/var/lib/mysql/ # MySQL数据库文件
/var/lib/postgresql/ # PostgreSQL数据

# Web服务
/var/www/       # Web服务器文档根目录
/var/www/html/  # 默认网站目录

# 缓存和临时数据
/var/cache/     # 应用程序缓存
/var/tmp/       # 临时文件（重启后保留）
/var/spool/     # 队列数据（邮件、打印等）
```

##### 3. **/usr** - 用户程序目录

包含大部分用户程序和数据，是系统的"软件仓库"。

```bash
# 可执行文件
/usr/bin/       # 用户命令（如ls、cp、vim）
/usr/sbin/      # 系统管理命令（如systemctl、iptables）
/usr/local/bin/ # 本地安装的程序

# 库文件
/usr/lib/       # 共享库文件
/usr/lib64/     # 64位库文件
/usr/local/lib/ # 本地安装的库

# 文档和资源
/usr/share/     # 共享数据（文档、图标、字体等）
/usr/share/doc/ # 软件文档
/usr/share/man/ # 手册页

# 源代码和头文件
/usr/src/       # 源代码
/usr/include/   # C/C++头文件

# 本地安装
/usr/local/     # 本地编译安装的软件
```

#### 特殊的虚拟文件系统

这些目录不存储真实文件，而是内核提供的虚拟接口，用于访问系统信息。

##### 4. **/proc** - 进程和内核信息虚拟文件系统

`/proc` 是一个特殊的虚拟文件系统，提供了访问内核数据结构的接口。

**系统信息文件：**

```bash
# CPU和硬件信息
/proc/cpuinfo   # CPU详细信息（型号、频率、核心数等）
/proc/meminfo   # 内存使用详情
/proc/version   # 内核版本信息
/proc/uptime    # 系统运行时间
/proc/loadavg   # 系统负载平均值

# 文件系统信息
/proc/filesystems # 支持的文件系统类型
/proc/mounts    # 当前挂载的文件系统
/proc/partitions # 磁盘分区信息

# 网络信息
/proc/net/      # 网络统计信息目录
/proc/net/dev   # 网络接口统计
/proc/net/tcp   # TCP连接信息
/proc/net/udp   # UDP连接信息

# 系统配置
/proc/sys/      # 内核参数配置目录
/proc/sys/kernel/ # 内核参数
/proc/sys/net/  # 网络参数
/proc/sys/vm/   # 虚拟内存参数
```

**进程信息目录：**

每个运行的进程在 `/proc` 下都有一个以进程ID命名的目录：

```bash
/proc/[pid]/    # 进程ID目录
/proc/[pid]/cmdline  # 进程启动命令行
/proc/[pid]/environ  # 进程环境变量
/proc/[pid]/exe      # 进程可执行文件链接
/proc/[pid]/fd/      # 进程打开的文件描述符
/proc/[pid]/maps     # 进程内存映射
/proc/[pid]/stat     # 进程状态信息
/proc/[pid]/status   # 进程详细状态

# 特殊进程目录
/proc/self/     # 指向当前进程的符号链接
/proc/thread-self/ # 指向当前线程的符号链接
```

**实用示例：**

```bash
# 查看CPU信息
cat /proc/cpuinfo | grep "model name" | head -1

# 查看内存使用情况
cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"

# 查看系统负载
cat /proc/loadavg

# 查看特定进程信息
ps aux | grep nginx  # 先找到nginx进程ID
cat /proc/[nginx_pid]/cmdline  # 查看启动命令
ls -l /proc/[nginx_pid]/fd/    # 查看打开的文件

# 修改内核参数（需要root权限）
echo 1 > /proc/sys/net/ipv4/ip_forward  # 启用IP转发
```

##### 5. **/sys** - 系统设备和内核信息文件系统

`/sys` 提供了设备驱动程序和内核子系统的信息接口。

```bash
# 设备信息
/sys/class/     # 设备类别目录
/sys/class/net/ # 网络设备
/sys/class/block/ # 块设备（硬盘等）
/sys/class/input/ # 输入设备

# 总线信息
/sys/bus/       # 系统总线
/sys/bus/pci/   # PCI总线设备
/sys/bus/usb/   # USB总线设备

# 设备树
/sys/devices/   # 设备层次结构

# 内核模块
/sys/module/    # 已加载的内核模块

# 文件系统
/sys/fs/        # 文件系统相关信息
/sys/fs/cgroup/ # cgroup控制组（容器技术基础）
```

**实用示例：**

```bash
# 查看网络接口
ls /sys/class/net/
cat /sys/class/net/eth0/address  # 查看MAC地址
cat /sys/class/net/eth0/speed    # 查看网卡速度

# 查看块设备
ls /sys/class/block/
cat /sys/class/block/sda/size    # 查看磁盘大小

# 查看CPU信息
ls /sys/devices/system/cpu/
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# cgroup信息（容器相关）
ls /sys/fs/cgroup/
cat /sys/fs/cgroup/memory/memory.limit_in_bytes
```

##### 6. **/dev** - 设备文件目录

`/dev` 包含设备文件，这些文件代表系统中的硬件设备。

```bash
# 块设备（存储设备）
/dev/sda        # 第一个SATA硬盘
/dev/sda1       # 第一个SATA硬盘的第一个分区
/dev/nvme0n1    # NVMe SSD
/dev/loop0      # 回环设备

# 字符设备
/dev/tty        # 控制终端
/dev/tty1       # 第一个虚拟终端
/dev/pts/0      # 伪终端
/dev/random     # 随机数生成器
/dev/urandom    # 伪随机数生成器

# 特殊设备
/dev/null       # 空设备（数据黑洞）
/dev/zero       # 零设备（产生无限的零字节）
/dev/full       # 满设备（总是返回磁盘已满错误）

# 网络设备（某些系统）
/dev/net/tun    # TUN/TAP网络设备
```

**实用示例：**

```bash
# 查看块设备
lsblk           # 列出所有块设备
fdisk -l        # 查看磁盘分区

# 使用特殊设备
echo "test" > /dev/null     # 丢弃输出
dd if=/dev/zero of=test.img bs=1M count=10  # 创建10MB的空文件
dd if=/dev/urandom of=random.dat bs=1K count=1  # 生成1KB随机数据

# 查看终端设备
tty             # 显示当前终端设备
who             # 显示登录用户和终端
```

#### 其他重要目录

##### 7. **/run** - 运行时数据

存储系统启动后的运行时信息，重启后会清空。

```bash
/run/           # 运行时数据根目录
/run/lock/      # 锁文件
/run/user/      # 用户运行时目录
/run/systemd/   # systemd运行时数据
/run/docker.sock # Docker守护进程套接字
```

##### 8. **/tmp** - 临时文件

存储临时文件，系统重启时通常会清空。

```bash
# 临时文件示例
/tmp/           # 临时文件目录
/tmp/.X11-unix/ # X11套接字文件
/tmp/systemd-private-* # systemd私有临时目录
```

#### 目录结构的重要性

**对于云原生开发的意义：**

1. **容器镜像构建**：理解目录结构有助于优化Docker镜像
2. **配置管理**：知道配置文件位置便于容器化应用
3. **日志收集**：了解日志位置便于日志聚合
4. **监控指标**：`/proc` 和 `/sys` 是监控系统的重要数据源
5. **安全考虑**：理解敏感目录有助于容器安全配置

**最佳实践：**

```bash
# 容器中常用的目录挂载
docker run -v /var/log:/var/log app:latest        # 日志持久化
docker run -v /etc/config:/etc/app app:latest     # 配置文件挂载
docker run -v /data:/var/lib/app app:latest       # 数据持久化

# 监控容器资源使用
cat /sys/fs/cgroup/memory/docker/[container_id]/memory.usage_in_bytes
cat /sys/fs/cgroup/cpu/docker/[container_id]/cpuacct.usage
```

### 2.2.2 绝对路径与相对路径

**绝对路径：**

- 从根目录（/）开始的完整路径
- 始终以 `/` 开头
- 不依赖当前位置

```bash
# 绝对路径示例
/home/student/Documents/file.txt
/etc/passwd
/usr/bin/python3
```

**相对路径：**

- 相对于当前目录的路径
- 不以 `/` 开头
- 使用特殊符号：
  - `.` 表示当前目录
  - `..` 表示上级目录
  - `~` 表示用户主目录

```bash
# 相对路径示例
./file.txt          # 当前目录下的文件
../parent_dir/      # 上级目录下的子目录
../../file.txt      # 上两级目录下的文件
~/Documents/        # 用户主目录下的 Documents
```

### 2.2.3 基础导航命令

**pwd - 显示当前目录**：

```bash
# 显示当前工作目录
pwd
# 输出：/home/student/Documents

# 显示物理路径（解析符号链接）
pwd -P
```

**cd - 切换目录**：

```bash
# 切换到指定目录
cd /etc
cd ~/Documents
cd ../parent_dir

# 特殊用法
cd          # 回到用户主目录
cd ~        # 回到用户主目录
cd -        # 回到上一个目录
cd ..       # 回到上级目录
cd /        # 回到根目录
```

**ls - 列出目录内容**：

```bash
# 基本用法
ls                  # 列出当前目录内容
ls /etc             # 列出指定目录内容

# 常用选项
ls -l               # 详细信息（长格式）
ls -a               # 显示隐藏文件
ls -la              # 详细信息 + 隐藏文件
ls -lh              # 人类可读的文件大小
ls -lt              # 按修改时间排序
ls -lS              # 按文件大小排序
ls -lr              # 递归显示子目录

# 输出格式解读
# drwxr-xr-x 2 user group 4096 Jan 15 10:30 dirname
# ↑         ↑ ↑    ↑     ↑    ↑           ↑
# 权限      链接 用户 组   大小 修改时间    名称
```

### 2.2.4 文件和目录操作

**mkdir - 创建目录**：

```bash
# 创建单个目录
mkdir new_directory

# 创建多个目录
mkdir dir1 dir2 dir3

# 创建多级目录
mkdir -p parent/child/grandchild

# 设置权限
mkdir -m 755 secure_dir
```

**rmdir - 删除空目录**：

```bash
# 删除空目录
rmdir empty_directory

# 删除多级空目录
rmdir -p parent/child/grandchild
```

**rm - 删除文件和目录**：

```bash
# 删除文件
rm file.txt
rm file1.txt file2.txt

# 删除目录及其内容
rm -r directory/
rm -rf directory/    # 强制删除，不提示

# 交互式删除
rm -i file.txt       # 删除前确认

# 安全删除
rm -v file.txt       # 显示删除过程
```

**cp - 复制文件和目录**：

```bash
# 复制文件
cp source.txt destination.txt
cp source.txt /path/to/destination/

# 复制目录
cp -r source_dir/ destination_dir/

# 保持属性
cp -p file.txt backup.txt    # 保持时间戳和权限
cp -a source/ backup/        # 归档模式（保持所有属性）

# 交互式复制
cp -i source.txt dest.txt    # 覆盖前确认

# 更新复制
cp -u source.txt dest.txt    # 仅当源文件更新时才复制
```

**mv - 移动/重命名文件和目录**：

```bash
# 重命名文件
mv old_name.txt new_name.txt

# 移动文件
mv file.txt /path/to/destination/
mv file1.txt file2.txt /destination/

# 移动目录
mv source_dir/ /path/to/destination/

# 交互式移动
mv -i source.txt destination.txt

# 备份模式
mv -b source.txt destination.txt  # 覆盖时创建备份
```

**实践练习：**

```bash
# 练习 1：目录导航
cd ~
pwd
ls -la
cd /etc
ls -l | head -10
cd -

# 练习 2：创建目录结构
mkdir -p ~/practice/linux/basics
cd ~/practice/linux/basics
pwd

# 练习 3：文件操作
touch file1.txt file2.txt
ls -l
cp file1.txt file1_backup.txt
mv file2.txt renamed_file.txt
ls -l

# 练习 4：清理
cd ~
rm -rf ~/practice
```

## 2.3 文件权限和所有权

### 2.3.1 用户、组和其他用户权限

Linux 是多用户系统，每个文件和目录都有所有者和权限设置。

**权限类型：**

- **r (read)**：读权限
  - 文件：可以查看文件内容
  - 目录：可以列出目录内容
- **w (write)**：写权限
  - 文件：可以修改文件内容
  - 目录：可以在目录中创建、删除文件
- **x (execute)**：执行权限
  - 文件：可以执行文件（如脚本、程序）
  - 目录：可以进入目录

**权限对象：**

- **u (user)**：文件所有者
- **g (group)**：文件所属组
- **o (others)**：其他用户
- **a (all)**：所有用户

### 2.3.2 权限表示方法

**符号表示法：**

```bash
# ls -l 输出示例
-rw-r--r-- 1 user group 1024 Jan 15 10:30 file.txt
drwxr-xr-x 2 user group 4096 Jan 15 10:30 directory

# 权限位解读
# 第1位：文件类型
#   - : 普通文件
#   d : 目录
#   l : 符号链接
#   c : 字符设备
#   b : 块设备
#   p : 命名管道
#   s : 套接字

# 第2-4位：所有者权限 (user)
# 第5-7位：组权限 (group)
# 第8-10位：其他用户权限 (others)
```

**数字表示法：**

```bash
# 权限数值对应
r (read)    = 4
w (write)   = 2
x (execute) = 1

# 常见权限组合
0 = --- (无权限)
1 = --x (仅执行)
2 = -w- (仅写入)
3 = -wx (写入+执行)
4 = r-- (仅读取)
5 = r-x (读取+执行)
6 = rw- (读取+写入)
7 = rwx (全部权限)

# 三位数字权限
755 = rwxr-xr-x  # 所有者全权限，组和其他用户读取+执行
644 = rw-r--r--  # 所有者读写，组和其他用户只读
600 = rw-------  # 仅所有者读写
777 = rwxrwxrwx  # 所有人全权限（不安全）
```

### 2.3.3 chmod 命令

**符号模式：**

```bash
# 基本语法：chmod [who][operator][permissions] file

# 添加权限
chmod u+x file.txt        # 给所有者添加执行权限
chmod g+w file.txt        # 给组添加写权限
chmod o+r file.txt        # 给其他用户添加读权限
chmod a+x file.txt        # 给所有人添加执行权限

# 移除权限
chmod u-w file.txt        # 移除所有者写权限
chmod g-x file.txt        # 移除组执行权限
chmod o-r file.txt        # 移除其他用户读权限

# 设置权限
chmod u=rwx file.txt      # 设置所有者权限为 rwx
chmod g=r file.txt        # 设置组权限为只读
chmod o= file.txt         # 移除其他用户所有权限

# 组合操作
chmod u+x,g-w,o=r file.txt
```

**数字模式：**

```bash
# 设置文件权限
chmod 755 script.sh       # rwxr-xr-x
chmod 644 document.txt    # rw-r--r--
chmod 600 private.txt     # rw-------
chmod 777 shared.txt      # rwxrwxrwx

# 递归设置目录权限
chmod -R 755 /path/to/directory

# 仅设置目录权限
find /path -type d -exec chmod 755 {} \;

# 仅设置文件权限
find /path -type f -exec chmod 644 {} \;
```

### 2.3.4 chown 和 chgrp 命令

**chown - 更改文件所有者**：

```bash
# 更改所有者
chown newuser file.txt
chown newuser:newgroup file.txt

# 仅更改组
chown :newgroup file.txt

# 递归更改
chown -R user:group /path/to/directory

# 参考文件设置
chown --reference=ref_file target_file
```

**chgrp - 更改文件组**：

```bash
# 更改文件组
chgrp newgroup file.txt

# 递归更改
chgrp -R newgroup /path/to/directory

# 参考文件设置
chgrp --reference=ref_file target_file
```

### 2.3.5 特殊权限

**Sticky Bit（粘滞位）**：

```bash
# 设置 sticky bit（通常用于 /tmp）
chmod +t /path/to/directory
chmod 1755 /path/to/directory

# 效果：只有文件所有者才能删除自己的文件
# 显示：drwxrwxrwt（末尾的 t）
```

**SUID（Set User ID）**：

```bash
# 设置 SUID
chmod u+s /path/to/executable
chmod 4755 /path/to/executable

# 效果：执行时以文件所有者身份运行
# 显示：-rwsr-xr-x（所有者执行位显示为 s）
# 例子：/usr/bin/passwd
```

**SGID（Set Group ID）**：

```bash
# 对文件设置 SGID
chmod g+s /path/to/executable
chmod 2755 /path/to/executable

# 对目录设置 SGID
chmod g+s /path/to/directory
# 效果：目录中新建文件继承目录的组

# 显示：-rwxr-sr-x（组执行位显示为 s）
```

**实践练习：**

```bash
# 练习 1：基本权限操作
touch test_file.txt
ls -l test_file.txt
chmod 755 test_file.txt
ls -l test_file.txt

# 练习 2：符号模式
chmod u+x,g-w,o=r test_file.txt
ls -l test_file.txt

# 练习 3：查看权限
stat test_file.txt

# 练习 4：目录权限
mkdir test_dir
chmod 755 test_dir
ls -ld test_dir

# 练习 5：特殊权限演示
mkdir sticky_test
chmod +t sticky_test
ls -ld sticky_test

# 清理
rm -rf test_file.txt test_dir sticky_test
```

---
