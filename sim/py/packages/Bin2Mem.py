import sys, os

class Bin2Mem:

    def __init__(self, filepath_in, filepath_out):
        # filepath_out 使用绝对路径

        if not os.path.exists(filepath_in):
            raise Exception(f'指定的Bin文件{filepath_in}不存在\n')
        
        if not os.path.isabs(filepath_in):
            raise Exception(f'Bin2Mem.py 应使用绝对路径 --> {filepath_in}\n')

        # 如果输出文件所在的文件夹不存在，则创建文件夹
        dirname = os.path.dirname(filepath_out)
        if not os.path.exists(dirname):
            sys.stdout.write(f'INFO: 文件夹已创建: {dirname}\n')
            os.makedirs(dirname)

        self.filepath_in = filepath_in
        self.filepath_out = filepath_out

    def run(self):

        sys.stdout.write("----------------------------------\n")
        sys.stdout.write("------ PROCESS : Bin2Mem.py ------\n")
        sys.stdout.write("----------------------------------\n")
        sys.stdout.write(f"Bin文件地址: {self.filepath_in}\n")
        sys.stdout.write(f"Mem文件地址: {self.filepath_out}\n")

        # 读取二进制文件内容
        with open(self.filepath_in, 'rb') as f:
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
        with open(self.filepath_out, 'w') as f:
            f.write(hex_str)

if __name__ == "__main__":

    if len(sys.argv) == 3:
        Bin2Mem(sys.argv[1], sys.argv[2]).run()
    else:
        raise Exception("Bin2Mem.py: 指令数量错误\n")
