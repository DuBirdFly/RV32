import subprocess, sys, os

class Sim:

    def __init__(
        self,
        # 路径均为绝对路径, 注意 filepath 与 dirpath 的区别
        filepath_vvp_script : str,
        dirpath_defines : str,
        filepath_tb_top : str,
        dirpath_rtls : str
    ):

        # 判断'文件/文件夹'是否存在, dirpath_vvp_script
        self.exists(os.path.dirname(filepath_vvp_script))
        self.exists(dirpath_defines)
        self.exists(filepath_tb_top)
        self.exists(dirpath_rtls)

        # 生成指令
        self.ivg_cmd = (["iverilog", "-o", filepath_vvp_script])    # '-o' --> output
        self.ivg_cmd.extend(["-I", dirpath_defines])                # '-I' --> includedir

        # 指定顶层模块 (如果没有用'-s'显示指定的话, 顶层模块被视为第一个file文件, 也就是此处做法)
        self.ivg_cmd.append(filepath_tb_top)                 

        # 指定其他的rtl文件
        filepaths = []
        for root, dirnames, filenames in os.walk(dirpath_rtls):
            for filename in filenames:
                if filename.endswith(".v") or filename.endswith(".sv"):
                    filepaths.append(os.path.join(root, filename))

        self.ivg_cmd.extend(filepaths)

        # 要求 vvp 必须处于环境变量中
        self.vvp_cmd = ["vvp", filepath_vvp_script]

    @staticmethod
    def exists(path):
        if not os.path.exists(path):
            raise Exception(f"ERROR: {path}文件夹不存在")
        elif not os.path.isabs(path):
            raise Exception(f"ERROR: Sim.py 应使用绝对路径 --> {path}")

    @staticmethod
    def run_cmd(cmd):
        process = subprocess.run(cmd, capture_output=True)
        if process.stdout:
            # ivg和vvp指令输出自带一个'\n',所以不用再加一个'\n'
            sys.stdout.write(process.stdout.decode('utf-8'))
        if process.stderr:
            raise Exception(process.stderr.decode('utf-8'))

    def run(self):
        self.run_cmd(self.ivg_cmd)
        self.run_cmd(self.vvp_cmd)

if __name__ == "__main__":

    sys.stdout.write("----------------------------------\n")
    sys.stdout.write("-------- PROCESS : Sim.py --------\n")
    sys.stdout.write("----------------------------------\n")

    if len(sys.argv) == 5:  # sys.argv[0] 是本文件的路径
        Sim(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]).run()
    else:
        raise Exception("Sim.py: 参数数量错误\n")