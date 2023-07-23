import os, subprocess
from packages.FileSimilar import FileSimilar

# True: 使用新的测试文件(riscv-compliance)
# False: 使用旧的测试文件(riscv-isa)
IS_NEW_TEST = False

PATH_CWD = os.getcwd().replace('\\', '/')
PATH_SIM = f"{PATH_CWD}/sim"

if IS_NEW_TEST:
    PATH_REF = f"{PATH_SIM}/riscv-compliance"
    PATH_BIN_FILE = f"{PATH_REF}/build_generated/rv32i/I-ADD-01.elf.bin"
    NAME_TB = "tinyriscv_soc_tb_compliance.v"
else:
    PATH_REF = f"{PATH_SIM}/riscv-isa"
    PATH_BIN_FILE = f"{PATH_REF}/generated/rv32ui-p-add.bin"
    NAME_TB = "tinyriscv_soc_tb_isa.v"

# Bin2Mem.py
Bin2MemArvg = ["python", f"{PATH_SIM}/py/packages/Bin2Mem.py"]
if IS_NEW_TEST:
    Bin2MemArvg.append(f"{PATH_BIN_FILE}")
else:
    Bin2MemArvg.append(f"{PATH_BIN_FILE}")
Bin2MemArvg.append(f"{PATH_SIM}/output/inst.data")

cmd = ' '.join(Bin2MemArvg)

process = subprocess.run(cmd, capture_output=True)

if process.stdout: print(process.stdout.decode('utf-8'))
if process.stderr: print(process.stderr.decode('utf-8'))

# Sim.py
SimArvg = ["python", f"{PATH_SIM}/py/packages/Sim.py"]
SimArvg.append(f"{PATH_SIM}/output/vvp_script.vvp")
SimArvg.append(f"{PATH_SIM}/output/vvp_log.log")
if IS_NEW_TEST:
    SimArvg.append(f"{PATH_CWD}/tinyriscv/tb/tb_compliance.v")
    SimArvg.append(f"{PATH_CWD}/tinyriscv/rtl")
else:
    SimArvg.append(f"{PATH_CWD}/tinyriscv/tb/tb_isa.v")
    SimArvg.append(f"{PATH_CWD}/tinyriscv/rtl")

cmd = ' '.join(SimArvg)

process = subprocess.run(cmd, capture_output=True)

if process.stdout: print(process.stdout.decode('utf-8'))
if process.stderr: print(process.stderr.decode('utf-8'))

# FileSimilar
if IS_NEW_TEST:

    path_ref_dir = os.path.dirname(PATH_BIN_FILE).replace('build_generated', 'riscv-test-suite')
    name_ref_file = os.path.basename(PATH_BIN_FILE).replace(".elf.bin", ".reference_output")
    path_ref_file = f"{path_ref_dir}/references/{name_ref_file}"

    path_my_file = f"{PATH_SIM}/output/signature.txt"

    similarity = FileSimilar(path_my_file, path_ref_file).similarity

    print("正在进行'文件比对' - FileSimilar ()")
    print("文件1 - RISC-V官方参考文件 : ", path_ref_file)
    print("文件2 - 我tb文件写入的文件 : ", path_my_file)
    print(f"文件相似度为 = ", '{:.2%}'.format(similarity))



