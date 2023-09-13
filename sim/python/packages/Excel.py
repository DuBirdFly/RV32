import openpyxl, os, re

class MyExcel:

    def __init__(self, xls_path: str, sheet_name: str):
        self.workbook = openpyxl.load_workbook(xls_path)
        self.sheet = self.workbook[sheet_name]
        self.last_row = self.sheet.max_row

    # read col
    def rdCol(self, col: str, rows: list) -> list:
        data = []
        for row in rows:
            cell_value = self.sheet[col + str(row)].value         # type: ignore
            data.append(cell_value)

        return data

    # find valid row, return list
    def fdVldRow(self, col, start_row, end_row, target="") -> list:
        data = []
        for row in range(start_row, end_row + 1):
            cell_value = self.sheet[col + str(row)].value         # type: ignore
            if cell_value:
                if target == "": data.append(row)
                elif cell_value == target: data.append(row)

        return data

    # build dictioanry
    def bdDict(self, col1, col2, start_row, end_row) -> dict:
        data = {}
        for row in range(start_row, end_row + 1):
            key = self.sheet[col1 + str(row)].value               # type: ignore
            val = self.sheet[col2 + str(row)].value               # type: ignore
            data[key] = val

        return data

if __name__ == "__main__":

    NAME_XLS = 'ins_set_plus.xlsx'
    NAME_DUMP = 'I-ECALL-01.elf.objdump'

    CWD = os.getcwd().replace('\\', '/')
    PH_EXCEL = CWD + '/doc/' + NAME_XLS
    PH_DUMP = CWD + '/sim/riscv-compliance/build_generated/rv32i/' + NAME_DUMP

    #################################################################################
    s1 = MyExcel(PH_EXCEL, 'Sheet1')
    s2 = MyExcel(PH_EXCEL, 'Sheet2')

    inst_ok_row = s1.fdVldRow('B', 2, s1.last_row, 'Y')  # 所有已经写好代码的指令 - 行号
    inst_ok = s1.rdCol('C', inst_ok_row)                 # 所有已经写好代码的指令 - 指令
    inst_true_row = s1.fdVldRow('C', 2, s1.last_row)     # 所有真指令的行号  - 行号
    inst_true = s1.rdCol('C', inst_true_row)             # 所有真指令       - 指令
    pseu2true = s2.bdDict('A', 'C', 2, s2.last_row)      # 构建伪指令到真指令的映射字典 -1

    for key, value in pseu2true.items():                 # 构建伪指令到真指令的映射字典 -2
        if value is not None:
            # 获取第一个token
            value = value.split()[0]
            pseu2true[key] = value

    # print(f"所有已经写好代码的指令: \n{inst_ok}")
    # print(f"所有真指令: \n{inst_true}")
    # print(f"伪指令到真指令的映射字典: \n{pseu2true}")

    inst_used = []                                       # dump文件拆解: 所有指令
    inst_used_true = []                                  # dump文件拆解: 真指令
    inst_used_pseu = []                                  # dump文件拆解: 伪指令
    inst_used_unkonw = []                                # dump文件拆解: 未知指令

    with open(PH_DUMP, 'r') as f:
        for line in f.readlines():
            # (任意长度' ''\t')(任意长度hex)(:)((任意长度' ''\t'))(长度为8的hex)(任意ASCII码)
            match = re.match(r'^\s*\w+:\s*([0-9a-fA-F]{8})\s*(.*)$', line)
            if match:
                last_part = match.group(2).strip()       # 获取第二个捕获组并去除空格或制表符
                inst_used.append(last_part.split()[0])   # 切分字符串并获取第一个非空字符串

    inst_used = list(set((inst_used)))

    for inst in inst_used:
        if inst in inst_true:
            inst_used_true.append(inst)
        elif inst in pseu2true:
            inst_used_pseu.append(inst)
        else:
            inst_used_unkonw.append(inst)

    # print(f"dump文件拆解: 所有指令(含伪指令和未知指令): \n{inst_used}")
    # print(f"dump文件拆解: 真指令: \n{inst_used_true}")
    # print(f"dump文件拆解: 伪指令: \n{inst_used_pseu}")
    # print(f"dump文件拆解: 未知指令: \n{inst_used_unkonw}")

    used_ins_final = inst_used_true             # dump文件用到的所有真指令 (伪指令 -> 真指令)
    for inst in inst_used_pseu: used_ins_final.append(pseu2true[inst])
    used_ins_final = list(set((used_ins_final)))

    inst_uncode = []

    for inst in used_ins_final:
        if inst not in inst_ok:
            inst_uncode.append(inst)

    print(f"dump文件用到的所有真指令 (伪指令 -> 真指令): \n{used_ins_final}")
    print(f"所有未写代码的指令+未知指令: \n{inst_uncode + inst_used_unkonw}")