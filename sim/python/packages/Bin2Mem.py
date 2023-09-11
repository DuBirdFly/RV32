import os

class Bin2Mem:

    def __init__(self, iFile, oFile):
        # oFile 使用绝对路径

        if not os.path.exists(iFile) or not os.path.isabs(iFile):
            raise FileNotFoundError(f'文件不存在或非绝对路径: {iFile}')

        # 如果输出文件所在的文件夹不存在，则创建文件夹
        dirname = os.path.dirname(oFile)
        if not os.path.exists(dirname):
            print(f'INFO: 文件夹已创建: {dirname}\n')
            os.makedirs(dirname)

        self.iFile = iFile
        self.oFile = oFile

    def run(self) -> None:

        # 读取二进制文件内容
        with open(self.iFile, 'rb') as f: bin_content = f.read()

        # 将二进制数据按照小端模式解码为整数int列表
        int_list = []
        for i in range(0, len(bin_content), 4):
            int_list.append(int.from_bytes(bin_content[i:i+4], byteorder='little'))

        # 将整数列表格式化为16进制32位，并在每32位之间添加回车
        hex_str = ''
        for i, num in enumerate(int_list):
            hex_str += '{:08X}'.format(num) + '\n'

        # 将格式化后的16进制字符串写入到txt文件中
        with open(self.oFile, 'w') as f: f.write(hex_str)

if __name__ == "__main__":
    pass
