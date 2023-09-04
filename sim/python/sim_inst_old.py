import os

from packages.Bin2Mem import Bin2Mem
from packages.Sim import Sim
from packages.MyFuc import find_all_insts_old

def sim_all_inst(inst : str):
    # 固定路径
    DIR_PH_CWD = os.getcwd().replace('\\', '/')
    DIR_PH_SIM = f"{DIR_PH_CWD}/sim"
    DIR_PH_OUT = f"{DIR_PH_SIM}/output"
    FILE_PH_MEM = f"{DIR_PH_OUT}/inst.data"

    # 可改路径
    DIR_PH_REF = f"{DIR_PH_SIM}/riscv-isa"
    DIR_PH_BIN = f"{DIR_PH_REF}/generated"
    # FILE_PH_TBTOP = f"{DIR_PH_CWD}/user/sim/tb_CoreTop_Old.v"
    FILE_PH_TBTOP = f"{DIR_PH_CWD}/user/sim/tb_CoreTop_New.v"

    FILE_PH_BIN = ""
    for root, dirs, files in os.walk(DIR_PH_BIN):
        for file in files:
            if file.endswith(".bin") and inst in file:
                FILE_PH_BIN = f"{DIR_PH_BIN}/{file}"
                break

    if FILE_PH_BIN == "":
        raise Exception(f"sim_all_inst(): 指令{inst}不存在\n")

    # 指令: Bin2Mem.py
    Bin2Mem(FILE_PH_BIN, FILE_PH_MEM).run()

    # 补齐output/inst.data的行数至2048行
    with open(FILE_PH_MEM, 'r') as file:
        line_count = sum(1 for _ in file)

    if line_count < 2048:
        with open(FILE_PH_MEM, 'a') as file:
            for i in range(2048 - line_count):
                file.write('00000000\n')

    # 指令: Sim.py 
    FILE_PH_VVP = f"{DIR_PH_OUT}/vvp_script.vvp"
    DIR_PH_INC = f"{DIR_PH_CWD}/user/src/inc"
    DIR_PH_RTL = f"{DIR_PH_CWD}/user/src/core"

    str = Sim(FILE_PH_VVP, DIR_PH_INC, FILE_PH_TBTOP, DIR_PH_RTL).run()

    return str

###############################################################################
inst = "lb"

isSimAll = False

if isSimAll:
    for inst in find_all_insts_old():
        for line in sim_all_inst(inst).splitlines():
            if line.startswith("TEST SIM"):
                print(inst.ljust(8) + ": " + line)
else:
    str = sim_all_inst(inst)
    print(str)