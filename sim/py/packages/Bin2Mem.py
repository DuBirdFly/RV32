import sys, os

class Bin2Mem:

    def __init__(self, filepath_in, file_path_out):
        # 使用绝对路径

        if os.path.exists(filepath_in):
            self.infile = filepath_in
        else:
            raise Exception(f'指定的Bin文件{filepath_in}不存在\n')

        if file_path_out.startswith(os.getcwd().replace('\\', '/')):
            self.outfile = file_path_out
        else:
            raise Exception("指定的Mem文件不在工作区下")

    def run(self):

        # 如果输出文件所在的目录不存在，则创建目录
        dirname = os.path.dirname(self.outfile)
        filename = os.path.basename(self.outfile)
        if not os.path.exists(dirname):
            sys.stdout.write(f'INFO: 想要在{dirname}下建立{filename}文件, 但是文件目录不存在(已自行创建目录)')
            os.makedirs(dirname)

        # 读取二进制文件内容
        with open(self.infile, 'rb') as f:
            bin_content = f.read()

        # 将二进制数据按照小端模式解码为整数int列表
        int_list = []
        for i in range(0, len(bin_content), 4):
            int_list.append(int.from_bytes(bin_content[i:i+4], byteorder='little'))

        # 将整数列表格式化为16进制32位，并在每32位之间添加回车
        hex_str = ''
        for i, num in enumerate(int_list):
            hex_str += '{:08X}'.format(num) + '\n'

        # 将格式化后的16进制字符串写入到txt文件中
        with open(self.outfile, 'w') as f:
            f.write(hex_str)

if __name__ == "__main__":

    if len(sys.argv) == 3:
        #指令示例:
        #cd D:/PrjWorkspace/rv32/sim/packages
        #python Bin2Mem.py ../compliance_test/riscv-compliance/build_generated/rv32i/I-ADD-01.elf.bin ../output/inst.data
        bin2mem = Bin2Mem(sys.argv[1], sys.argv[2])
        bin2mem.run()
    else:
        print("Fail! 指令结构错误, 正确指令: python <Bin2Mem.py文件地址> <Bin文件地址> <Mem文件地址>")
        print("-----------------------------------------------------------------------------")



