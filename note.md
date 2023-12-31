# 笔记

## 版本

### v1

使用老版本的sim方案, 路径 (sim/riscv-isa/generated)

测试指令对象:
['add', 'addi', 'and', 'andi', 'auipc', 'beq', 'bge', 'bgeu', 'blt', 'bltu', 'bne', 'fence_i', 'jal', 'jalr', 'lb', 'lbu', 'lh', 'lhu', 'lui', 'lw', 'or', 'ori', 'sb', 'sh', 'simple', 'sll', 'slli', 'slt', 'slti', 'sltiu', 'sltu', 'sra', 'srai', 'srl', 'srli', 'sub', 'sw', 'xor', 'xori', 'div', 'divu', 'mul', 'mulh', 'mulhsu', 'mulhu', 'rem', 'remu']

除了以下是"fail"之外其他都"pass" (通过了rv32i)

fence_i, div, divu, mul, mulh, mulhsu, mulhu, rem, remu  

### v2

使用新版本的sim方案, 路径 (sim/riscv-compliance/build_generated)

## git相关

### gitignore

[使用说明](https://blog.csdn.net/ThinkWon/article/details/101447866)

**如果你已经把不想上传的文件上传到了git仓库**，那么你必须先从远程仓库删了它，==我们可以从远程仓库直接删除然后pull代码到本地仓库这些文件就会本删除==，或者从本地删除这些文件并且在.gitignore文件中添加这些你想忽略的文件，<font color=red>然后再push到远程仓库</font>。

### git代理无法连接的操作

如果使用了VPN, 会导致代理地址变化, 如clash的代理端口为 <http://127.0.0.1:7890>

所以需要在Git Bash中执行以下两条命令:

```bash
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

具体看文档 <https://zhuanlan.zhihu.com/p/636418854>

## Python相关

`sys.stdout.write`指令不自带"\n"
`sys.stderr.write`指令不自带"\n
`raise Exception()`可以抛出异常

## 芯片

XC7Z010CLG400-1

## 流水线冒险

<https://zhuanlan.zhihu.com/p/425235910>

### 结构冒险

1. 由于 IF 与 MEM 都需要读取RAM内存, 然而内存地址只有一个, 只能在1个clk中读取1个数据
解决方案: 将 DataCache 和 InstCatch 分开, 使用混合架构的CPU, ----finished

1. 由于 ID 与 MEM 都需要使用通用寄存器组, 所以要求通用寄存器组必须读写分离, 也就是REGS的2个读通道和1个写通道可以同时使用

```verilog
module Registers (
    input               clk,
    // read
    input       [ 4:0]  rdaddr1,
    output reg  [31:0]  REGS_rddata1,
    input       [ 4:0]  rdaddr2,
    output reg  [31:0]  REGS_rddata2,
    // write
    input               wen,        // 写使能信号
    input       [ 4:0]  wraddr,
    input       [31:0]  wrdata
);
```

### 数据冒险

后面的指令的 read_regs_addr 与 前一条指令的 write_regs_addr 相同, 也就是指令之间存在依赖关系,其解决方案主要有以下几种:

1. 引入软件NOP, 也就是流水线停顿, 或称"流水线冒泡"
2. 硬件阻塞, 也就是在ID阶段检测到冲突时, 将后一条指令的ID阶段阻塞, 或称"流水线暂停"
3. 将每一条指令的的结果数据传输给下一条数据的ALU, 或称"操作数前推/转发"

我考虑到以下几种经典的数据冒险情况:

1. `"add x28, x29, x30" + "addi x20, x28, 15"`; 第二条指令的rs与第一条指令的rd相同(寄存器x28), 然而第二条指令在ID想要读取Regs的x28的时候 第一条指令在EX的输出端口还没写回, 这种情况使用`数据冒险·解决方案3`: 操作数前推/转发 (module --> OprForward)

```verilog
// OF_x_rs1
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs1 && EX_rd != 5'd0)
        OF_x_rs1 = EX_x_rd;
    else
        OF_x_rs1 = REGS_rddata1;
end

// OF_x_rs2
always @(*) begin
    if (EX_rd_vld && EX_rd == ID_REG_rs2 && EX_rd != 5'd0)
        OF_x_rs2 = EX_x_rd;
    else
        OF_x_rs2 = REGS_rddata2;
end
```

2. `"add x28, x29, x30" + "NOP" + "addi x20, x28, 15"`; 第三条指令的rs与第一条指令的rd相同(寄存器x28), 然而第三条指令在ID想要读取Regs的x28的时候, 第一条指令在MEM的输出端口还没写回, 注意到MEM的输出也就是Reg的输入, 所以这种情况使用`数据先出的registers`

```verilog
always @(*) begin
    if (REGS_rdaddr1 == wraddr && wen)                   // 写后读
        REGS_rddata1 = wrdata;
    else
        REGS_rddata1 = regfile[REGS_rdaddr1];
end
always @(*) begin
    if (rdaddr2 == wraddr && wen)
        rddata2 = wrdata;
    else 
        rddata2 = regfile[rdaddr2];
end
```

3. `"ld x30, 0(x0)" + "add x30, x30, 1"`; 第二条指令的某一个rs与第一条指令的rd相同, 且第一条指令是load类型, 这叫load-use型数据冒险, 必须有一次硬件阻塞.

```verilog
always @(*) begin
    hold_IF = 1'b0;
    nop_IF = 1'b0;
    if (ID_rs1 == ID_rd_d1 || ID_rs2 == ID_rd_d1) begin
        if (ID_instID_d1 == `ID_LW) begin
            hold_IF = 1'b1;
            nop_IF = 1'b1;
        end
    end
end
```

### 控制冒险

这是由分支跳转导致的冲突.

1. 无条件跳转, 由于跳转的地址在IF2ID阶段就已经确定(我设计于ID的组合逻辑), 所以通过设计旁路电路, 将计算结果更早地送入PC, 这种方法被称为缩短分支延迟

```verilog
// 处理无条件跳转控制冒险
always @(*) begin
    if (inst[6:0] == `OPCODE_J_JAL) begin
        ID_jmp_vld <= 1'b1;
        ID_jmp_addr <= { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0 };
    end
    else begin
        ID_jmp_vld <= 1'b0;
        ID_jmp_addr <= 32'd0;
    end
end
```

2. 条件跳转, 使用分支预测(静态预测)
   1. RST后默认不跳转, 如果发生了EX_jmp_vld, 说明预测失败, 则下2条指令都是无效指令, 所以反馈给EX输入端一个2拍的inst_vld信号, 这两拍EX的控制信号(EX_x_rd_vld, EX_jmp_vld, EX_MEMrden[3:0], EX_MEMwren[3:0])均为0.
