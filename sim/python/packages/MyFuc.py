import subprocess, os, sys


def run_cmd(cmd):
    # cmd可以是str, 也可以是list

    process = subprocess.run(cmd, capture_output=True)

    if process.stdout: print(process.stdout.decode('utf-8'), end='')
    else: print("stdout: None")

    if process.stderr:
        print(f"stderr:\n{process.stderr.decode('utf-8')}\n强行终止程序")
        exit(0)


def find_all_insts_old():
    DIR_PH_CWD = os.getcwd().replace('\\', '/')
    DIR_PH_SIM = f"{DIR_PH_CWD}/sim"
    DIR_PH_REF = f"{DIR_PH_SIM}/riscv-isa"
    DIR_PH_BIN = f"{DIR_PH_REF}/generated"

    insts = []

    for root, dirs, files in os.walk(DIR_PH_BIN):
        for file in files:
            if file.endswith(".bin"):
                insts.append(file.split('.')[0].split('-')[-1])

    return insts

# list去重
def list_unique(lst):
    return list(set(lst))

if __name__ == "__main__":
    print(find_all_insts_old())