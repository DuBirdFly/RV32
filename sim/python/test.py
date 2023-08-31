import os, re

DIR_PH_CWD = os.getcwd().replace('\\', '/')

DIR_PH_BIN = f"{DIR_PH_CWD}/sim/riscv-compliance/build_generated/rv32i"

FILES_BIN = []
for root, dirs, files in os.walk(DIR_PH_BIN):
    for file in files:
        if file.endswith(".elf.bin"):
            FILES_BIN.append(file)


for file in FILES_BIN:
    matches = re.findall('-(.*?)-', file)
    print(matches[0], end = ' ')