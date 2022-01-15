# Feature Progress

For feature details, please refer to project report.

| Feature                                                      | Status      |
| ------------------------------------------------------------ | ----------- |
| Simulation Correct Output                                    | __Test OK__ |
| FPGA Correct Output                                          | __Test OK__ |
| Data Forwarding to avoid stall                               | __Test OK__ |
| ICache ( direct mapping)(128 entry)                          | __Test OK__ |
| DCache (Write through&&write allocate*) (32 entry direct mapping) | __Test OK__ |
| 32 entry **BTB** (branch target buffer )while every entry has 1 bit **BHT**(branch history table)* | __Test OK__ |
| Read Priority over Write on Miss*(dcache write buffer *maxmize the bus use rate using circular queue) | __Test OK__ |
| naive mmu                                                    |             |
| IF Prefetch                                                  |             |

***while the btb can branch in the pc stage instead of ex stage which save 3 cycle the bht gurantee the currectness**

***Write allocate: allocate new cache line in cache**

***write buffer is an optimizen of write through in the dcache**

***when the load occur we examine the wrie buffer to find if the data exist in the write buffer(using circular queue )**

# **Test on FPGA**

the best result at the frequence of 100HZ

![image-20211124112258239.png](https://s2.loli.net/2022/01/15/IjC7RtmonDJFLvi.png)

![image-20211122131743871.png](https://s2.loli.net/2022/01/15/cgJyTpz47x93nGd.png)



![image-20211124104214209.png](https://s2.loli.net/2022/01/15/u8fi23AvIFx9Yoe.png)

# Design details

- about write buffer

The motivation for  Write Buffer : The memory port on FPGA is completely different from RAM in modern computer, where the motivation for  Write Buffer comes from. Write Buffer dalays unimportant write behavior to gaps between reading.when the bus is spare it can be reused to store the data in the write buffer into the ram.

and when I design this unit I meet a  problem that trouble me a few days, that''s because when i first design the write buffer I simply use the sequeint array so when the load instruction want a data in the write buffer the write buffer may has two entry having the same data address but different data so I can't get the correct one.So in my design ,I use a method like circuit quene so I can get the latest data in the write bufferto guarantee correctness.

- about dcache

A direct mapping D-Cache with size of $32 \times 4$ bytes is implemented.

In my [pre_commit][https://github.com/yichuan520030910320/CPU_ACM_2021/commit/0d435f14a7e02868a939453481c9623ef4f2bcc6] I adopt a write back dcache the write policy is a mixture of write back and write through, and in detail, 4-byte store insructions use write back and other store instructions use write through. It is so arranged because of the large proportion of 4-byte store instructions, and the 4-byte block size due to limitation of units on FPGA.  

![image-20220115112714175.png](https://s2.loli.net/2022/01/15/Hw1avjKIYUW27ZN.png)

it can correctly run the simulation but due to the complex design the latency in the fpga is such big .So I uphold the principle

"**Small is fast, simple and neat, good design is a good trade-off**" in the Bible. I change the design into write through&&write allocate and make the dache It can always make the cache the same as ram.Just simple but effective.

- about BHT&BTB

the outline design of btb is the same as the below

![image-20211221203434740.png](https://s2.loli.net/2022/01/15/3FOokbN2dG1TKBc.png)

but it can't guarantee the correctness so I adopt one bit bht to check if the instruction jump 

| 33    | 32:15 | 14:2 | 1:0       |
| ----- | ----- | ---- | --------- |
| valid | addr  | tag  | predictor |

parameter BTB_BHT_LOG_SIZE  = 5,parameter BTB_BHT_SIZE =32

(note that in the addr is valid only the last 18 bit so the tag can be simplied into 13 bit (5 bit index))

and it has Significant effect speed up 

# My result on the simulation

add ichache

| 测试点      | first drsft | icache 128byte | icache 256byte | icache  512byte | icache 1024byte |
| ----------- | ----------- | -------------- | -------------- | --------------- | --------------- |
| array_test2 | 10483       | 7985           | 6455           | 6053            | 5021            |
| array_test1 | 10195       | 7479           | 6047           | 5747            | 4829            |
| lvalue2     | 293         | 273            | 273            | 273             | 273             |
| gcd         | 19259       | 11117          | 9037           | 7327            | 7167            |
| expr        | 130737      | 50269          | 44415          | 40319           | 40243           |



# LOG

11.3之前 完成了环境配置和文件夹创建

11.3简化id阶段 

11.3  简化了组合逻辑的复杂程度

对于shamt操作把他们转化为立即数 可以和下面对应的操作进行归一化处理

（注意 只有shamt的第五位是0的时候才是有效的 ）

关于阻塞赋值和非阻塞赋值的一些理解

11.4

无符号数就是原来的值

bltu bgeu就不用加unsigned

机械操作完成了ex阶段

- 关于符号位拓展

https://blog.csdn.net/wordwarwordwar/article/details/108039574

开始考虑mem if设计 以及stall

https://www.cnblogs.com/niuyourou/p/12075634.html

继续阅读这篇文章

1.写测试来pass ori指令

2.前传操作

3.停机指令

4.内存操作

11.12

注意自动tab补全可能会出现的问题

完成stall rdy_in branch ...ys说内存读写会出现这个周期发出读指令 等一个时钟周期 下下个时钟才能读到

处理Nope指令...插入空指令

11.13

memctrl要求判断处理的东西和之前的要处理的东西是否一致 

一条线的输出口可以接到两个不同的地方

加入nop指令 在branch的时候我们可以把它的信息传输到中间寄存器 然后中间寄存器传输nop指令给组合逻辑 想一下Branch运行的逻辑

branch的停止 我采用的是传输给中间寄存器信息 然后中间寄存器发出空的指令 而不是通过控制ctrl.v来实现

cpu和ram交互是在cpu里面

```
 	input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)
```

在cpu_top里面实例化了ram

接下来是写掉mem,memctrl ,if 然后整体仔细看一遍 防止小bug 逻辑分析清楚 时序分析

可以削寄存器 同样的一根输出的线接到不同的模块里面

**关于memctrl目前我的想法是谁先进去谁先占用总线 就是if不用让给mem之后可以调整 让mem优先级更高**

目前的措施是先到先得

补充lw特殊操作不能数据前传的阻塞

处理内存的结构冲突！

11.15

mem_ctrl注意一点 当同时发送请求的时候 我要先处理mem的请求 

if阶段不用判断pc是不是变成branch了，我直接更改pc寄存器 if阶段的pc输入也发生了变化 这个时候 memctrl读的地址也变化了计数器重新计数

完成了mem操作

要给load指令增加特判//todo

然后连线

11.16

开始debug争取早一些过掉simulation然后加上特性

学到的一些调试技巧

```
$display($time,"XXXXXXX %h /%b/%d",xxx);
对于一些测试点可以输出.c文件
都是一些定位错误的方法
```

先完成肉眼浏览 然后开始调试（输出调试结合波形调试）

11.17

哭了 为什么我申请一个地址的数据 但是总线不给我数据

我emmm想不明白

1是写口 我把它当成读的口了 解决

对于mem的一些些理解

注意 memctrl a_out的结果在下一个周期返回

现阶段的目标 ：调出mem intru out to if

时序逻辑的assign中 右边的值按照这个时序逻辑最后的状态（assign 是随时变化的）

同一个时序中不论在哪里display结果输出都是相同的 （注意不同于顺序执行 脑子要清楚）

波形调试结合输出调试

11.18

关于读入的问题 分支之后丢弃了的东西要捡回来 

现在的mem应该是比较好的 解决了一些计数的问题 emmm然后我的计数方法要比cq好 他在read时候最后用了阻塞赋值（cnt=4的时候）这样比较危险 而我采用了比较正常的写法 但是有可能会造成额外的周期数 不是很好

outln(999)可以outlln (1000)就炸了！！

11.19

跑通了之后削一些东西

不要忘记改forever

**过了gcd 下一个点expr** 没有任何输出

11.20

超级感谢zyl 成功上板

![image-20211120003833269.png](https://s2.loli.net/2022/01/15/R1wpHJ7GCx65Yof.png)

11.21

add ichache

| 测试点      | first drsft | icache 11.22 128byte | icache 11.22 256byte | icache 11.22 512byte | icache 11.22 1024byte |
| ----------- | ----------- | -------------------- | -------------------- | -------------------- | --------------------- |
| array_test2 | 10483       | 7985                 | 6455                 | 6053                 | 5021                  |
| array_test1 | 10195       | 7479                 | 6047                 | 5747                 | 4829                  |
| lvalue2     | 293         | 273                  | 273                  | 273                  | 273                   |
| gcd         | 19259       | 11117                | 9037                 | 7327                 | 7167                  |
| expr        | 130737      | 50269                | 44415                | 40319                | 40243                 |

//todo add write back dcache

由于icache是读一片连续的地址 用直接映射效果比较好 dcache读的比较分散 个人感觉用组关联（两路组关联）的效果比较好 然后用write back的性能比较好 相比于write through可以降低总线的占用率

但是组关联会导致组合逻辑复杂度上升

降低lut的一个方法！：去掉初始化的for循环(除了valid)，

11.23

安装虚拟机

和vivado

端口选择012

11.24

test result

![image-20211124104214209.png](https://s2.loli.net/2022/01/15/u8fi23AvIFx9Yoe.png)

波形数值是上升沿后改变的值

AC is ok!!!!!!

优化decache的时候需要调整开始的初始化

写掉dcache  真男鞋qwqq

//todo dcache hci commment 

//todo dump of statement test and we can pass the fpga input at the beginning of the test 

现在的版本dcache 会导致两字的写入不在cache里面 memread操作不一定能读到

11.27同样的问题qwqqqq

1127基础版本真正收工

if prfetch write buffer dcache 特权指令 tlb虚拟内存 mmu

改掉dcache （自己搞明白）和一些版本rst问题

read的时候有一些要加入到dacache里面 不用

之前对于写的操作采取不同的操作在本地版本（1129上午的版本是可以成立的）simulation can pass 但是在fpga上只能过掉小的点 未能解决 所以牺牲性能采取原来的dcache写法

今天才发现begin是可以匹配的

可以用beyond compare比较两个文件夹 

dcache杀我 时延好难调整 而且 我降频一直失败qwqqqqq 救命啊！！看不懂vivado critical path在干什莫

emmm 还是用精简的设计比较好emmmm 小而精的设计还是好的

只优化读的性能 写的操作全部采用write through 并且全部更新dcache 为了节省读的周期 对于写没有优化

12.1 

一些设想！

prefetch 可以混emmm就没有向memctrl发出请求的时候xjb可以收集一些指令放在一个存储很少的寄存器中间 这样子可以保证一些Memctrl不空跑指令 write buffer同理

https://kns.cnki.net/KXReader/Detail?invoice=vkKCi2kvIrgAXoMguS8h5nXrfzL1LTQJLH6y%2FaJlnZ9Oabf5sKOx2UnAQnYRBOSuKX6lcrU1gOYAC9x6%2FUlprBAHpFAE2vJ79X0lakjk8U8U%2BltOZSToRuT3wfI8MHXfh5fMfXpuYlzbW43I6YDIQ8%2Frk59IbflB0fB%2BfRep0U0%3D&DBCODE=CJFD&FileName=JSYJ200902006&TABLEName=cjfd2009&nonce=360EE0C440A548CC935133C287B9C0DD&uid=&TIMESTAMP=1638362257093

一些高级的分支预测

**Cache prefetching** is a technique used by computer processors to boost execution performance by fetching instructions or data from their original storage in slower memory to a faster local memory before it is actually needed (hence the term 'prefetch').[[1\]](https://en.wikipedia.org/wiki/Cache_prefetching#cite_note-:3-1) 

12.5 我的memctrl写法很有利于节省周期 可以不必在addr发过来 的时候在memctrl等待一个周期	

1.14

循环队列来实现的write buffer 来保证正确性





