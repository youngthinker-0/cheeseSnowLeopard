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
## 12.12
这时候我把stallreq_for_load加上了，但是不知道为啥，，，我那时候把inst_sw写到了rf_we里，导致我一直卡在这个点：  
reference: PC = 0x9fc00d54, wb_rf_wnum = 0x09, wb_rf_wdata = 0x0000aaaa  
mycpu    : PC = 0x9fc00d54, wb_rf_wnum = 0x09, wb_rf_wdata = 0xbfaffaba  
当时卡了好几天，我记得最后一次实验课的时候我还卡在这里呢。。。很苦恼。  
## 12.14
解决上面那个问题之后，再运行程序会陷入无限循环，查看那个波形图的wb_pc会发现最后正常的地方是9fc00d80，看看test.s知道我们又该加指令了。  
加一条指令sltu，可以过5号点。  
reference: PC = 0xbfc49624, wb_rf_wnum = 0x02, wb_rf_wdata = 0xc822c7e8  
mycpu    : PC = 0xbfc49624, wb_rf_wnum = 0x02, wb_rf_wdata = 0x000000e8  
这里注意将data_ram_wen在inst_sw时赋值为4‘b1111，如果只是赋值为1会卡在这里。（这是我重新模拟的时候踩的坑，之前没有在这里卡住。）  
之后加的指令有slt，加完就到8号点了，和我在github的commit也可以对应起来。  
reference: PC = 0xbfc03574, wb_rf_wnum = 0x02, wb_rf_wdata = 0x00000001  
mycpu    : PC = 0xbfc050e0, wb_rf_wnum = 0x09, wb_rf_wdata = 0x09000000  

## 晚上又开始发烧了，我不打算继续写这个日记，重新熟悉代码的目的已经达到，剩下的12月15日到21日所添加的东西都在github的记录中有呈现，再写就相当于对比一下github上不同时间提交之间的区别，做一下总结罢了。以后再弄这种东西我会做好记录，把细节都呈现出来。其实今天下午重新模拟一遍还是有好处的，我遇到了一些原先自己没有遇到的bug。我本来以为自己已经编写了一遍程序，从头再编写一遍是一件很轻松的事情，并不是这样的。
## 始终觉得不写完有点不得劲，我想把这个日记补全。。。
## 12.15
加指令slti，sltiu，j，add，addi，sub，and，andi，nor，xori，sllv，sra，srav，srl，srlv。  
过36号点，到了这个位置：  
reference: PC = 0xbfc560a0, wb_rf_wnum = 0x02, wb_rf_wdata = 0x40200000  
mycpu    : PC = 0xbfc560e0, wb_rf_wnum = 0x15, wb_rf_wdata = 0x40200000  
这一部分加的毫无趣味，就是在id段对着那个A03文档补指令，也是最轻松的。
## 12.18
仍然是加指令bgez，bgtz，blez，bltz，bltzal，bgezal，jalr。  
过43点，到这个位置：  
reference: PC = 0xbfc560a0, wb_rf_wnum = 0x02, wb_rf_wdata = 0x40200000  
mycpu    : PC = 0xbfc560e0, wb_rf_wnum = 0x15, wb_rf_wdata = 0x40200000  
这一部分稍微有意思的东西就是分支跳转指令你需要加入自己的判断方法，就是rs_ge gt le lt_rt那些东西。  
主要是学了学这些英文缩写都是什么意思：
ge-greater than or equal to-大于等于  
gt-greater than-大于  
le-less than or equal to-小于等于  
lt-less than-小于  
还是比着A03文档加，轻松，这两天在写机器学习课设的报告，所以写了3天才写到43号点。  
## 12.20
首先在这天加完了hilo，这是我觉得最难的一部分了，具体前面有写。  
加的指令有mfhi，mflo，mthi，mtlo，div，divu，mult，multu。  
加hilo首先要想那个32个的reg一样新建一个hilo_reg.v，将hilo_bus加到很多的总线中去，比如说ex_to_mem_bus，ex_to_rf_bus……我们在id段需要像那32个通用寄存器一样取出hilo寄存器中的值，这里需要注意数据相关问题，模仿rf_rdata和rdata那样子进行处理，最后hilo寄存器中的值作为hi_i，lo_i传入ex，在ex段做的事情是，如果是要将数据写入到hilo寄存器，如mthi，mul，div之类的指令，hi_o，lo_o用来存储要写入的数据，并作为hilo_bus中的一部分往后传，就像rf_wdata一样。如果是mfhi，mflo之类将hilo寄存器中的值取出，存入到通用寄存器中，那这一部分ex_result将会被赋值为hilo寄存器中的值（hi_i，lo_i）。  
加完hilo可以到达这里：  
reference: PC = 0xbfc7d7dc, wb_rf_wnum = 0x15, wb_rf_wdata = 0x00000002  
mycpu    : PC = 0xbfc7d7dc, wb_rf_wnum = 0x15, wb_rf_wdata = 0x00000000  
这一部分想了3天，还有好多是抄的助教录屏里的东西，对我来说是最难的部分。  
之后还加了stallreq_for_ex，主要是因为除法它是多周期的，在一个周期算不完，具体原理还没深入了解。  但是这一部分我觉得不难，大部分东西都给你写好了。  
加完过45号点，到达这里：  
reference: PC = 0xbfc3494c, wb_rf_wnum = 0x15, wb_rf_wdata = 0x0a20a480  
mycpu    : PC = 0xbfc3494c, wb_rf_wnum = 0x15, wb_rf_wdata = 0xxxxxxxxx  
## 12.21
卡在45号点是最蠢的，mul那一块我录屏没抄全。。。  
ex段加了一句话assign mul_signed = inst_mult，过58号点，到这里：  
reference: PC = 0xbfc371a0, wb_rf_wnum = 0x02, wb_rf_wdata = 0x0000000b  
mycpu    : PC = 0xbfc371a4, wb_rf_wnum = 0x05, wb_rf_wdata = 0x800d6764  
继续，根据助教仓库里SampleCPU的README.md写的关于按字节存取的示例代码，我理解了之后写了一个不美观的。  
加的指令有lb，lbu，lh，lhu，sb，sh。  
在ex段主要就是改对于data_sram_wen和data_sram_wdata这两个，就是按字节把通用寄存器里的值往sram里存，store指令。  
mem段改的是mem_result，目的是按字节读data_sram_rdata到寄存器里，load指令。  
在理解load，store的原理之后我觉得这个没啥难度，而且有助教的代码作为参考。  
写完这些，过64号点，到这里：  
reference: PC = 0xbfc00380, wb_rf_wnum = 0x1a, wb_rf_wdata = 0x00004000  
mycpu    : PC = 0xbfc6a074, wb_rf_wnum = 0x09, wb_rf_wdata = 0x41000000  
## 过64号点之后
我看了《自己动手做cpu》后面的异常处理相关的东西（还把syscall和break指令加了上去，但并没有实现），之后有很多其他的考试和报告要写，而且验收的安排也修改了，我便去着手准备其他的东西，没有再深入研究。这两天阳了以后，我决定缓考计算机系统，有了一些时间（大部分时候脑子不清醒）。所以我写下这篇日记，回顾一下以前做的东西。收获很多，感想很多，在这里不写了，因为实在是太头晕了。。。有机会再写吧！