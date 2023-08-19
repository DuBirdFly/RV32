import openpyxl, os, re

CWD = os.getcwd().replace('\\', '/')
path_excel = CWD + '/doc/ins_set.xlsx'

############################################################
workbook = openpyxl.load_workbook(path_excel)   # 打开Excel文件
sheet = workbook.active                         # 获取工作表

# 获取指定列的值，并将其存储到列表中
ins_true = []                                   # 存储所有有效指令
ins_has_code = []                               # 已经写好代码的指令
pseu2true = {}                                  # 构建伪指令到真指令的映射字典

for i in range(1, 86):
    if (i < 49):
        ins_true.append(sheet['C'][i].value)        # type: ignore
        if (sheet['D'][i].value == 'Y'):            # type: ignore
            ins_has_code.append(sheet['C'][i].value)# type: ignore
    else:
        val1 = sheet['C'][i].value                  # type: ignore
        val2 = sheet['N'][i].value.split(" ")[0]    # type: ignore
        pseu2true[val1] = val2

# print(f"所有真指令: \n{ins_true}")
# print(f"所有已经写好代码的指令: \n{ins_has_code}")
# print(f"伪指令到真指令的映射字典: \n{pseu2true}\n")

############################################################
# True: 使用新的测试文件(riscv-compliance)
# False: 使用旧的测试文件(riscv-isa)
SIM = CWD + '/sim'
IS_NEW_TEST = False

if IS_NEW_TEST: path_dump = SIM + '/riscv-compliance/build_generated/rv32i/I-ADD-01.elf.objdump'
else: path_dump = SIM + '/riscv-isa/generated/rv32ui-p-lw.dump'

used_ins = []                              # 存储所有用到的真实指令

with open(path_dump, 'r') as f:
    lines = f.readlines()
    # (任意长度' ''\t')(任意长度hex)(:)((任意长度' ''\t'))(长度为8的hex)(任意ASCII码)
    # 具体分析"正则匹配"的话问问ChatGPT
    pattern = r'^\s*\w+:\s*([0-9a-fA-F]{8})\s*(.*)$'
    for line in lines:
        match = re.match(pattern, line)         # 找出所有指令行
        if match:
            last_part = match.group(2).strip()  # 获取第二个捕获组并去除空格或制表符
            first_word = last_part.split()[0]   # 切分字符串并获取第一个非空字符串
            used_ins.append(first_word)

used_ins = list(set(used_ins))
print(f"dump文件用到的指令(含伪指令): \n{used_ins}\n")

############################################################

used_ins_true = []          # 存储所有用到的真指令的列表
used_ins_pseu = set()       # 存储所有用到的伪指令的集合
used_ins_unkonw = []        # 存储所有未知指令的列表
used_ins_final = []         # 存储所有用到的指令的列表，包括真指令和伪指令

for ins in used_ins:
    if ins in ins_true:     # 如果是真指令
        used_ins_true.append(ins)
    elif ins in pseu2true:  # 如果是伪指令
        used_ins_true.append(pseu2true[ins])
        used_ins_pseu.add(ins)
    else:                   # 如果是未知指令
        used_ins_unkonw.append(ins)

# 统计所有用到的真指令，包括used_ins_true[]和used_ins_pseu{}中的真指令部分
used_ins_final = used_ins_true + [pseu2true[ins_pseu] for ins_pseu in used_ins_pseu]
used_ins_final = list(set(used_ins_final))  # 去重

print(f"所有实际用到的真指令: \n{used_ins_final}\n")
print(f"所有用到的未知指令: \n{used_ins_unkonw}\n")

############################################################
ins_uncode = []

for ins in used_ins_final:
    if ins not in ins_has_code:
        ins_uncode.append(ins)

print(f"所有未写代码的指令: \n{ins_uncode}\n")

