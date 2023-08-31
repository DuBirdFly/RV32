import os
from packages.MyFuc import run_cmd

DIR_PH_CWD = os.getcwd().replace('\\', '/')
DIR_PH_SIM = f"{DIR_PH_CWD}/sim"
DIR_PH_OUT = f"{DIR_PH_SIM}/output"

# 指令: GtkWave
for filename in os.listdir(DIR_PH_OUT):
    if filename.endswith(".vcd"):
        cmd = ["gtkwave", f"{DIR_PH_OUT}/{filename}"]
        run_cmd(cmd)
        break           # 只打开第一个.vcd文件