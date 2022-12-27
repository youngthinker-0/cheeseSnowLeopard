# cheeseSnowLeopard
计算机系统实验课

杨森---Young Thinker---(branch)main

冯哲豪---YangVillageKing---(branch)YangVillageKing-patch

master分支不用管，当时不知道干啥创了这个分支。

# Debug Diary -- Young Thinker
我在12月27日写下这篇纠错日记，主要是为了回忆自己在之前编写CPU过程中遇到的问题。
在之前编程时，遇到的问题，添加的指令，到达的节点位置都没有进行记录，只是用git上传时commit写了过到哪些点，我觉得这样子不好。

我已经忘掉了什么时候开始的CPU编写，只记得去宾馆隔离的时候过了1号点，12月21日我到达了64号点，之前的bug忘了很多很多。

印象比较深的东西是过了1号点之后添加了stallreq_for_load，但是卡到了他之前某个位置，最后发现是rf_we里错把inst_sw加上了，这个卡了我好几天。

到36号点很快，记得几乎全是改的id.v，无脑加指令。。。到43号点忘了，应该还是加指令，我对这一部分印象不深。

最难到我的东西我觉得是加hilo。。。看着那个《自己动手做cpu》我加了hilo_reg.v，就仅限于加这个文件了。剩下的不会了。又开始疯狂的找助教的录屏看，最后一次录屏只有ex段里需要加的，第一次录屏里我看到id段需要加的一部分东西了。还是不想写，没啥头绪，，，过了一天我硬着头皮写吧，先抄了录屏里的ex段，有好几个东西来路不明啊，hi_i，lo_i……不知道是啥。。。还是懵逼。写不出来，那天打王者去了直接。又过一天我问助教，他说比着那id那个reg写。我看了一会忽然间明白了，全都照着这reg写就完事，rf_waddr对于hilo来说没有，这东西是32个寄存器选哪个存用的，hilo一共就两个，直接写hi_we，lo_we，hi_wdata，lo_wdata就行了，其他的东西和这些寄存器一样传，把什么ex_to_mem_bus，mem_to_wb_bus，ex_rf_bus……只要里面有rf_we，rf_waddr，rf_wdata的总线，就把hilo_bus也加进去就行。这样加完了hilo。

之后是加除法的那个stall，那个加起来其实不难，就在ctrl.v，mycpucore.v里加stallreq_for_ex就行了（ex段把那个stallreq_for_ex给引出来），是这个地方还是哪个地方来着，我记得比较烦人的一点就是要把这一块所有的指令都加全（也好像是加hilo的时候）

之后过45号点，又卡了一下，我写的这个乘法有问题。。。我寻思这不是助教给我们写的吗，不能有问题啊。。。这个我记得他一直显示rf_wdata是0xxxxxxxxx，我也是照抄的助教录屏里的，，，沿着这个波形图查错，mul_signed这个信号不对，我没换成inst_mult。抄也没抄全，我太粗心了。。。加一句assign mul_signed = inst_mult，过到58号点。

过58号点，之后是按字节存取，这一块不难，主要是助教仓库里SampleCPU的README.md给了美观的写法。弄懂了原理之后我比着写了个不美观的，这一部分做的很快，过64号点。

只是这样说还是不太具体，正好我弄完CPU的时间也很久了，我想从头开始，再把这个代码模拟一遍来过到64号点，正好记录一下之前debug没有记录的具体信息，然后复现一下当时的情况吧。我也好再熟悉熟悉代码，为了验收加指令做做准备。（这两天阳了，计算机系统办了缓考，阳的不是时候。。。）
下午再写。
## 12.? 
初始状态，什么都不加，运行时会卡在0xbfc006bc，这时候我记不清是几号了，在宾馆隔离时做的
解决数据相关问题，将ex_to_rf_bus，mem_to_rf_bus，wb_to_rf_bus加好，id段的rdata1,rdata2写好。
加完数据相关的东西之后会卡在这里：
reference: PC = 0xbfc006f8, wb_rf_wnum = 0x19, wb_rf_wdata = 0x9fc00704
mycpu    : PC = 0xbfc00714, wb_rf_wnum = 0x19, wb_rf_wdata = 0xbfc00000
subu指令没加，从这里开始加指令。
## 12.？
这个时间点也记不清楚了。
加指令subu，jal，jr，addu，bne，sll，sw，or，lw，xor，
这时候可以到这里：
reference: PC = 0x9fc00d5c, wb_rf_wnum = 0x0a, wb_rf_wdata = 0x00000000
mycpu    : PC = 0x9fc00d5c, wb_rf_wnum = 0x0a, wb_rf_wdata = 0xbfaf5a86
过了1号点此时。
## 12.13
这时候我把stallreq_for_load加上了，但是不知道为啥，，，我那时候把inst_sw写到了rf_we里，导致我一直卡在这个点：
reference: PC = 0x9fc00d54, wb_rf_wnum = 0x09, wb_rf_wdata = 0x0000aaaa
mycpu    : PC = 0x9fc00d54, wb_rf_wnum = 0x09, wb_rf_wdata = 0xbfaffaba
当时卡了好几天，我记得最后一次实验课的时候我还卡在这里呢。。。很苦恼。
## 12.15
解决上面那个问题之后，再运行程序会陷入无限循环，查看那个波形图的wb_pc会发现最后正常的地方是9fc00d80，看看test.s知道我们又该加指令了。
加一条指令sltu，可以过5号点。
reference: PC = 0xbfc49624, wb_rf_wnum = 0x02, wb_rf_wdata = 0xc822c7e8
mycpu    : PC = 0xbfc49624, wb_rf_wnum = 0x02, wb_rf_wdata = 0x000000e8
这一部分极其无聊，就是一直加指令。