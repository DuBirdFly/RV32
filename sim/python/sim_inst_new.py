import os, shutil

from packages.Bin2Mem import Bin2Mem
from packages.Sim import Sim
from packages.FileSimilar import FileSimilar

# CWD = Current Working Directory, PH = Path, F = File, D = Directory
# MEM = Memory, VVP = Verilog VVP, SIG = Signature
# BIN = Binary, REF = Reference
# TBTOP = TestBench Top, INC = Include, RTL = RTL
CWD = os.getcwd()

PH_F_MEM = f"{CWD}/sim/output/inst.data"
PH_F_VVP = f"{CWD}/sim/output/vvp_script.vvp"
PH_F_SIG = f"{CWD}/sim/output/signature.txt"

PH_D_BIN = f"{CWD}/sim/riscv-compliance/build_generated/rv32i"
PH_D_REF = f"{CWD}/sim/riscv-compliance/riscv-test-suite/rv32i/references"

PH_F_TBTOP = f"{CWD}/user/sim/tb_CoreTop_New.v"
PH_D_INC = f"{CWD}/user/src/inc"
PH_D_RTL = f"{CWD}/user/src/core"

def sim_inst(bin_name : str):

    PH_F_BIN = f"{PH_D_BIN}/{bin_name}.elf.bin"
    PH_F_REF = f"{PH_D_REF}/{bin_name}.reference_output"

    # 判断文件是否存在
    if not os.path.exists(PH_F_BIN): raise FileNotFoundError(f"文件不存在: {PH_F_BIN}")
    if not os.path.exists(PH_F_REF): raise FileNotFoundError(f"文件不存在: {PH_F_REF}")

    # 指令: 生成 inst.data
    Bin2Mem(PH_F_BIN, PH_F_MEM).run()

    # 补齐 inst.data 的行数至 3072 行
    with open(PH_F_MEM, 'r') as file: line_count = sum(1 for _ in file)

    if line_count < 3072:
        with open(PH_F_MEM, 'a') as file:
            for i in range(3072 - line_count): file.write('00000000\n')

    # 指令: Sim.py
    LIST_FILE = []
    for root, dirnames, filenames in os.walk(PH_D_RTL):
        for filename in filenames:
            if filename.endswith(".v") or filename.endswith(".sv"):
                LIST_FILE.append(os.path.join(root, filename))

    sim = Sim(PH_F_VVP, PH_D_INC, PH_F_TBTOP, LIST_FILE)

    # FileSimilar.py
    similarity =  FileSimilar(PH_F_SIG, PH_F_REF).similarity

    XXXX = "PASS" if similarity > 0.99999 else "FAIL"
    return f"{inst:<20}{XXXX},  similarity: {similarity:.2%}\nvvp_stdout: {sim.vvp_stdout}"

###################################################################

isSimAll = True

if not isSimAll:
    inst = "I-SH-01"
    
    for root, dirs, files in os.walk(f'{CWD}/sim/output'):
        for file in files:
            if file.endswith(".elf.objdump") or file.endswith(".reference_output"):
                os.remove(os.path.join(root, file))

    shutil.copy2(f'{PH_D_BIN}/{inst}.elf.objdump', f'{CWD}/sim/output/{inst}.elf.objdump')
    shutil.copy2(f"{PH_D_REF}/{inst}.reference_output", f'{CWD}/sim/output/{os.path.basename(inst)}.reference_output')
    print(sim_inst(inst))

else:
    insts = []
    for root, dirs, files in os.walk(PH_D_BIN):
        for file in files:
            if file.endswith(".bin"): insts.append(file.split('.')[0])

    print(f"全体 RV32-I 的指令测试 ---> 共 {len(insts)} 条指令 :")

    for inst in insts:
        if "PASS" in sim_inst(inst): print(f"{inst:<20}PASS")
        else: print(f"{inst:<20}FAIL!!!")