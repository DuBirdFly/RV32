import subprocess, os

class Sim:

    def __init__(
        self,
        # 路径均为绝对路径, 注意 filepath 与 dirpath 的区别
        filepath_vvp_script : str,
        dirpath_defines : str or None,
        filepath_tb_top : str,
        filelist : list
    ):

        # 判断'文件/文件夹'是否存在且为绝对路径
        self.exists(os.path.dirname(filepath_vvp_script))
        self.exists(dirpath_defines)
        self.exists(filepath_tb_top)
        for filepath in filelist: self.exists(filepath)

        # 生成 iverilog 指令, 要求 iverilog 必须处于环境变量中
        self.ivg_cmd = (["iverilog", "-o", filepath_vvp_script])            # '-o' --> output
        if dirpath_defines: self.ivg_cmd.extend(["-I", dirpath_defines])    # '-I' --> includedir

        # 指定顶层模块 (如果没有用'-s'显示指定的话, 顶层模块被视为第一个file文件, 也就是此处做法)
        self.ivg_cmd.append(filepath_tb_top)

        # 指定其他的rtl文件
        self.ivg_cmd.extend(filelist)

        # 生成 vvp 指令, 要求 vvp 必须处于环境变量中
        self.vvp_cmd = ["vvp", filepath_vvp_script]

        # 执行 iverilog 指令
        self.ivg_stdout = self.run_ivg()

        # 执行 vvp 指令
        self.vvp_stdout = self.run_vvp()

    @staticmethod
    def exists(path) -> None:
        if not os.path.exists(path):
            raise Exception(f"ERROR: {path}文件夹不存在")
        elif not os.path.isabs(path):
            raise Exception(f"ERROR: Sim.py 应使用绝对路径 --> {path}")

    @staticmethod
    def run_cmd(cmd):
        process = subprocess.run(cmd, capture_output=True)
        if process.stdout:
            out = process.stdout.decode('utf-8')
            while out[-1] == '\n': out = out[:-1]   # 删去 out 最后的所有'\n'
            return out
        if process.stderr:
            raise Exception(f"{process.stderr.decode('utf-8')}")

    def run_ivg(self) -> str:
        # 返回没有'\n'的 stdout
        return f'{self.run_cmd(self.ivg_cmd)}'

    def run_vvp(self) -> str:
        # 返回没有'\n'的 stdout
        return f'{self.run_cmd(self.vvp_cmd)}'

if __name__ == "__main__":

    pass