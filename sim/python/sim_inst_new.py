import os

from packages.Bin2Mem import Bin2Mem
from packages.Sim import Sim

def sim_inst(bin_name : str):

    # 格式化 bin_name: 取出 bin_name '.' 之前的部分
    bin_name = bin_name.split('.')[0]

    # 固定路径
    CWD = os.getcwd()

    PH_D_OUT = f"{CWD}/sim/output"
    PH_F_MEM = f"{CWD}/sim/output/inst.data"
    PH_F_VVP = f"{CWD}/sim/output/vvp_script.vvp"

    PH_D_BIN = f"{CWD}/sim/riscv-compliance/build_generated/rv32i"
    PH_D_REF = f"{CWD}/sim/riscv-compliance/riscv-test-suite/rv32i/references"

    PH_F_TBTOP = f"{CWD}/user/sim/tb_CoreTop_New.v"
    PH_D_INC = f"{CWD}/user/src/inc"
    PH_D_RTL = f"{CWD}/user/src/core"

    # 找到 bin_name 对应的 bin 文件
    PH_F_BIN = ""
    for root, dirs, files in os.walk(PH_D_BIN):
        for file in files:
            if file.endswith(".bin") and bin_name in file:
                PH_F_BIN = f"{PH_D_BIN}/{file}"
                break

    if PH_F_BIN == "": raise Exception(f"输入的 bin_name 不存在\n")

    # 指令: 生成 inst.data
    Bin2Mem(PH_F_BIN, PH_F_MEM).run()

    # 补齐 inst.data 的行数至 3072 行
    with open(PH_F_MEM, 'r') as file: line_count = sum(1 for _ in file)

    if line_count < 3072:
        with open(PH_F_MEM, 'a') as file:
            for i in range(3072 - line_count): file.write('00000000\n')

    # 指令: Sim.py
    str = Sim(PH_F_VVP, PH_D_INC, PH_F_TBTOP, PH_D_RTL).run()

    return str

###################################################################
inst = "I-ADD-01"

print(sim_inst(inst))