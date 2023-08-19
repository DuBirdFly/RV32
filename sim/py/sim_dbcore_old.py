import os

from packages.Bin2Mem import Bin2Mem
from packages.Sim import Sim
from packages.MyFuc import run_cmd

# 固定路径
# DIR = directory
# PH = path
# CWD = current working directory
# SIM = simulation
# OUT = output
# MEM = memory
# VVP = vvp script
# INC = include
DIR_PH_CWD = os.getcwd().replace('\\', '/')
DIR_PH_SIM = f"{DIR_PH_CWD}/sim"
DIR_PH_OUT = f"{DIR_PH_SIM}/output"
FILE_PH_MEM = f"{DIR_PH_OUT}/inst.data"

# 可改路径
DIR_PH_REF = f"{DIR_PH_SIM}/riscv-isa"
FILE_PH_BIN = f"{DIR_PH_REF}/generated/rv32ui-p-lw.bin"

# 指令: Bin2Mem.py 
Bin2Mem(FILE_PH_BIN, FILE_PH_MEM).run()

# 指令: Sim.py 
FILE_PH_VVP = f"{DIR_PH_OUT}/vvp_script.vvp"
DIR_PH_INC = f"{DIR_PH_CWD}/user/src/inc"
FILE_PH_TBTOP = f"{DIR_PH_CWD}/user/sim/tb_CoreTop.v"
DIR_PH_RTL = f"{DIR_PH_CWD}/user/src/core"
Sim(FILE_PH_VVP, DIR_PH_INC, FILE_PH_TBTOP, DIR_PH_RTL).run()

