import os, subprocess
from packages.MyFuc import run_cmd

# 常数 ########################################################################
# True: 使用新的测试文件(riscv-compliance)
# False: 使用旧的测试文件(riscv-isa)
IS_NEW_TEST = True

PATH_CWD = os.getcwd().replace('\\', '/')
PATH_SIM = f"{PATH_CWD}/sim"

if IS_NEW_TEST:
    PATH_REF = f"{PATH_SIM}/riscv-compliance"
    PATH_BIN_FILE = f"{PATH_REF}/build_generated/rv32i/I-ADD-01.elf.bin"
else:
    PATH_REF = f"{PATH_SIM}/riscv-isa"
    PATH_BIN_FILE = f"{PATH_REF}/generated/rv32ui-p-add.bin"

MEM_FILE = f"{PATH_SIM}/output/inst.data"
# MEM_FILE = f"C:/Users/29378/Desktop/aa/inst.data"

# 指令: Bin2Mem.py ############################################################
Bin2MemArvg = ["python", f"{PATH_SIM}/python/packages/Bin2Mem.py"]

if IS_NEW_TEST:
    Bin2MemArvg.append(f"{PATH_BIN_FILE}")
else:
    Bin2MemArvg.append(f"{PATH_BIN_FILE}")
Bin2MemArvg.append(MEM_FILE)

cmd = ' '.join(Bin2MemArvg)

run_cmd(cmd)

# 指令: Sim.py ################################################################
SimArvg = ["python", f"{PATH_SIM}/python/packages/Sim.py"]
SimArvg.append(f"{PATH_SIM}/output/vvp_script.vvp")
SimArvg.append(f"{PATH_CWD}/tinyriscv/rtl/core")
if IS_NEW_TEST:
    SimArvg.append(f"{PATH_CWD}/tinyriscv/tb/tb_compliance.v")
else:
    SimArvg.append(f"{PATH_CWD}/tinyriscv/tb/tb_isa.v")

SimArvg.append(f"{PATH_CWD}/tinyriscv/rtl")

cmd = ' '.join(SimArvg)

run_cmd(cmd)

# 指令: FileSimilar.py ########################################################
if IS_NEW_TEST:

    path_ref_dir = os.path.dirname(PATH_BIN_FILE).replace('build_generated', 'riscv-test-suite')
    name_ref_file = os.path.basename(PATH_BIN_FILE).replace(".elf.bin", ".reference_output")

    cmd = ["python", f"{PATH_SIM}/python/packages/FileSimilar.py"]
    cmd.append(f"{path_ref_dir}/references/{name_ref_file}")    # 官方的参考文件路径
    cmd.append(f"{PATH_SIM}/output/signature.txt")              # 我用TestBench捕获的数据

    run_cmd(cmd)



