# RV32

本工程实现了一个 5级流水-32位-"I+Zicsr+Zifencei"指令集 的 RISCV处理器, 借鉴了tinyriscv的代码, 非常感谢tinyriscv作者的无私奉献

本工程的数据流图:

![Alt text](img/%E6%9C%AC%E5%B7%A5%E7%A8%8B%E7%9A%84CPU%E6%9E%B6%E6%9E%84.png)

本工程的指令集表格(rv32im没有实现):

![Alt text](img/%E6%8C%87%E4%BB%A4%E9%9B%86%E8%A1%A8%E6%A0%BC.png)

本工程之前使用的是使用老版本的sim方案, 路径 (sim/riscv-isa/generated), 搞到一半迁移到新版本的sim方案了, 路径 (sim/riscv-compliance/build_generated), 关于这两个方案的详细信息, 可以参考tinyriscv的介绍

新版本的sim方案结果:

![Alt text](img/v2%E7%89%88%E6%9C%AC%E7%9A%84%E6%8C%87%E4%BB%A4%E9%9B%86%E6%B5%8B%E8%AF%95.png)

1. 本工程写了 i, Zicsr, Zifencei 这三个指令集, 但是没有实现 rv32im 指令集
2. 目前也只对 i 指令集做了sim测试
3. i 指令集中的 SH 指令没有 PASS, 但我目前也没兴趣修复了
4. 我还想把这个CPU放到FPGA上跑一跑来着, 也搁置了

非常感谢 <<计算机组成与设计: 硬件/软件接口 (原书第5版) >> 这本书, 此书对CPU设计的入门讲解非常透彻, 本工程的CPU设计仅仅需要其中的前四章即可. 第五章是将cache的, 本工程由于是一个非常小的设计, 且并未使用到ddr, 所以并不需要cache来做层次化存储. 第六章是讲"并行处理器和云"的, 是一个科普级别的介绍.

或许我以后还会去看看 <<计算机体系结构: 量化研究方法>> 这本书吧

被搁置的这些已有问题**我就不管了**, 修BUG主要就是看波形和汇编指令, 属实有点腻 (其实是因为上班新人培训期间把这个工程搁置了, 然后就不想再捡起来了, 哎, 摆了摆了)

国内的还有一个 ["一生一芯"](https://ysyx.oscc.cc/docs/2306/#%E5%AD%A6%E4%B9%A0%E7%9B%AE%E6%A0%87) 项目, 这是一个非常优质的项目, 有兴趣的朋友们可以去看看, 由于本人是为上班短期突击的手搓CPU, 而 "一生一芯" 又比较体系长期, 所以非常遗憾不能参与到 "一生一芯" 项目中去

非常感谢 [Digital-IDE 插件](https://digital-eda.github.io/DIDE-doc-Cn/#/?id=digital-ide-version-030) , 这个插件非常好用, 而且因为是国人做的, 反馈也很方便, so nice
