
本章主要从cpu 、网络、硬盘、内存进行分析。

## <span id="1">一、cpu </span>
 **常用命令:top，strace，perf，vmstat**
 ### 1.top 
 可以实时动态地查看系统的整体运行情况,包括进程、cpu、内存。
 而ps静态一次性查看进程的信息。
 ~~~go
 [root@iz2zxxxx ~]# top
top - 22:38:46 up 362 days,  7:30,  2 users,  load average: 0.01, 0.02, 0.05
Tasks:  76 total,   1 running,  75 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.3 us,  0.3 sy,  0.0 ni, 99.0 id,  0.3 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem :  1883724 total,   138956 free,   508744 used,  1236024 buff/cache
KiB Swap:        0 total,        0 free,        0 used.   890668 avail Mem

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
    1 root      20   0  190900   3080   1768 S  0.0  0.2   2:45.44 systemd
    2 root      20   0       0      0      0 S  0.0  0.0   0:03.45 kthreadd
    3 root      20   0       0      0      0 S  0.0  0.0   1:33.38 ksoftirqd/0
    5 root       0 -20       0      0      0 S  0.0  0.0   0:00.00 kworker/0:0H
    7 root      rt   0       0      0      0 S  0.0  0.0   0:00.00 migration/0
    8 root      20   0       0      0      0 S  0.0  0.0   0:00.00 rcu_bh
    9 root      20   0       0      0      0 S
 ~~~
 
* 前五行是系统整体的统计信息。第一行是任务队列信息，第二行和第三行为进程和CPU的信息，最后两行为内存信息。下面对一些比较重要的参数进行说明。

* load average: 0.01, 0.02, 0.05。load average表示系统在过去1分钟5分钟15分钟的任务队列的平均长度。这个值越大就表示系统CPU越繁忙。

* Cpu(s):0.3%us(用户空间占用的cpu百分比)，0.3%sy(系统空间占用的cpu百分比)，0.0%ni(用户进程空间内改变过优先级的用户占用的cpu百分比)，90.0%id(空闲cpu的百分比)，0.3%wa(等待输入输出cpu的百分比)。

* Mem：890668 buffers(用作内核缓存的内存量)。

* Swap：磁盘交换区容量。

### 2.strace
可以跟踪到一个进程产生的系统调用，包含参数、返回值、执行消耗的时间。
* 常用
~~~
[root@iz2zxxxx opt]# strace -o out.txt -T -tt -e trace=all -p 13395
strace: Process 13395 attached

^Cstrace: Process 13395 detached
[root@iz2zxxxx opt]# ls
etcd  ghost  out.txt  
[root@iz2zxxxx opt]# vi out.txt
~~~

* 表示跟踪 13395 进程的所有系统调用，并统计系统调用的时间开销，以及调用起始时间(以可视化的时分秒格式显示)，最后将记录结果存入out.txt文件。

### 3.perf
是Linux的性能调优工具。perf工具的常用命令包括top，record，report等。

### 4.vmstat
一个很全面的性能分析工具，可以观察到系统的进程状态、内存使用、虚拟内存使用、磁盘的 IO、中断、上下问切换、CPU使用等。
~~~

[root@iz2zxxxx opt]# vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0      0 222832  60568 1097924    0    0     2     4    0    1  0  0 99  0  0
[root@iz2zxxxx opt]#
~~~
### ps
静态的一次性查看当前进程信息。最多用法：
* ps aux |grep mysql
* ps aux |grep nginx



## <span id="1">二、网络</span>
**常用命令:netstat、lsof命令**
### 1.netstat的常用方法：

* netstat -p | grep 19626：得到进程号19626的进程所打开的所有端口
* netstat -tpl：查看当前tcp监听端口, 需要显示监听的程序名。
* netstat -c 2：隔两秒执行一次netstat，持续输出
* netstat -an: 查看三次握手都有上面样的状态，listen  established  timewait
### 2.lsof
用于查看进程开打的文件，打开文件的进程，进程打开的端口(TCP、UDP)。在linux环境下，任何事物都以文件的形式存在，通过文件不仅仅可以访问常规数据，还可以访问网络连接和硬件。
安装 ```yum install -y lsof ```
* 查看文件谁在使用
~~~

[root@iz2zxxxx opt]# lsof ghost/
COMMAND  PID  USER   FD   TYPE DEVICE SIZE/OFF    NODE NAME
ghost   4565 ghost  cwd    DIR  253,1     4096 1071047 ghost
node    4573 ghost  cwd    DIR  253,1     4096 1071047 ghost
~~~
* 查看某用户打开的文件信息
~~~
[root@iz2zxxxx opt]# lsof -u ghost
COMMAND  PID  USER   FD      TYPE             DEVICE SIZE/OFF    NODE NAME
ghost   4565 ghost  cwd       DIR              253,1     4096 1071047 /opt/ghost
ghost   4565 ghost  rtd       DIR              253,1     4096       2 /
ghost   4565 ghost  txt       REG              253,1 29797392  677671 /usr/bin/node
ghost
~~~
### 3.tcpdump
可以将网络中传送的数据包完全截获下来提供分析。它支持针对网络层、协议、主机、网络或端口的过滤，并提供and、or、not等逻辑语句来帮助你去掉无用的信息。
安装 ```yum install -y tcpdump ```
常用：
* 抓取211.155 客户端与本机通信的数据表，只抓取 10个包
~~~
[root@iz2zxxxx ~]# tcpdump -c 10 net 211.155
~~~
* 抓取本机22端口 10个包
~~~
[root@iz2zxxxx ~]# tcpdump -c 10 -nn -i eth0 tcp dst port 22
~~~

### 4.tshark
使用tshark抓包分析http请求
安装 ``` yum  install  -y  wireshark```
~~~
1.安装yum  install  -y  tshark:提示没有该包，于是使用yum 搜索，发现了 wireshark里面包含tshark。
2.搜索yum whatprovides *tshark*

3.安装 yum  install  -y  wireshark

~~~

## <span id="1">三、磁盘</span>
**常用命令:iotop**
iotop命令是一个用来监视磁盘I/O使用状况,包括PID、用户、I/O、进程等相关信息。发现磁盘io很忙，通过iotop查看一下哪个进程在读写。
安装：```yum install -y iotop ```
常用：
* 只显示正在产生I/O的进程
~~~
[root@iz2zxxxx opt]# iotop -o
~~~
* 带单位
~~~
[root@iz2zxxxx opt]# iotop -k
~~~
## <span id="1">四、内存</span>
**常用命令:algrind**
### 1.algrind
检查程序运行时的内存泄漏问题.


### 2.free
free -h：查看内存使用情况，带单位。
~~~
[root@iz2zxxxx ~]# free
              total        used        free      shared  buff/cache   available
Mem:        1883724      496984      155364      234688     1231376      903612
Swap:             0           0           0
[root@iz2zxxxx ~]# free -h
              total        used        free      shared  buff/cache   available
Mem:           1.8G        486M        150M        229M        1.2G        881M
Swap:            0B          0B          0B
[root@iz2zxxxx ~]#
~~~
* total !=used+free,因为系统预留一部分内存给buff/cache
* 如果free 不够了，就需要考虑加内存了。
