import subprocess, sys, os
from PathFile import PathFile

class Sim:

    def __init__(
        self,
        path_vvp_script : str,      # 生成的vvp_script.vvp脚本中间文件的绝对路径
        path_log : str,             # 生成的log文件的绝对路径
        path_tb_top : str,          # testbench顶层模块的绝对路径
        path_rtl_dir : str          # rtl文件夹的绝对路径
    ):

        self.path_vvp_script = path_vvp_script
        self.path_log = path_log
        self.path_tb_top = path_tb_top
        self.path_rtl_dir = path_rtl_dir

        ########################## iverilog指令 ##########################
        # iverilog指令固定开始片段, 此时iverilog必须处于环境变量中
        self.ivg_cmd = ['iverilog']

        # 指定编译生成的脚本文件, '-o' --> output
        self.ivg_cmd.append("-o")
        self.ivg_cmd.append(path_vvp_script)

        # 指定rtl文件夹的头文件(rtl/core/defines.v)路径, '-I' --> includedir
        # 注意: 路径是文件夹路径, 而不是defines.v这个文件的路径
        tmp = PathFile.get_file_path(path_rtl_dir, "defines.v")
        if len(tmp) == 0:
            sys.stdout.write(f"INFO: {path_rtl_dir}文件夹下没有'defines.v'文件, 所以iverilog不指定'-I'参数")
        elif len(tmp) > 1:
            sys.stderr.write(f"ERROR: {path_rtl_dir}文件夹下有多个'defines.v'文件\n")
        else:
            self.ivg_cmd.append("-I")
            tmp = os.path.dirname(tmp[0])
            self.ivg_cmd.append(tmp)

        # 指定额外的宏定义, 将其添加到{tb_top}文件中, '-D' --> macro[=defn]
        # 这个命令用于{tb_top}文件中的verilog语法: fd = $fopen(`OUTPUT);
        # 我选择直接卸载{tb_top}文件中, 此处注释掉
        # self.ivg_cmd.append("-D")
        # self.ivg_cmd.append('OUTPUT="signature.txt"')

        # 指定顶层模块 (如果没有用'-s'显示指定的话, 顶层模块被视为第一个file文件, 也就是此处做法)
        self.ivg_cmd.append(path_tb_top)

        # 指定其他的rtl文件, 以及testbench文件
        self.ivg_cmd.extend(PathFile.get_all_files(path_rtl_dir))

        ########################### vvp指令 ##########################
        # vvp指令固定开始片段, 此时vvp必须处于环境变量中
        self.vvp_cmd = ['vvp']
        self.vvp_cmd.append(path_vvp_script)

    def gen_vvp_script(self):
        # 执行iverilog指令, 生成vvp_script.vvp脚本中间文件
        # 注意! iverilog指令执行成功并不会输出stdout (但报错会有stderr)
        # iverilog指令执行成功后, 使用vvp指令才会输出stdout和vcd文件

        cmd = ' '.join(self.ivg_cmd)

        process = subprocess.run(cmd, capture_output=True)

        if process.stderr:
            raise Exception(process.stderr.decode('utf-8'))

    def run_vvp(self):
        # 执行vvp指令 (可能能生成vcd波形文件)
        # 波形文件名路径需要在testbench中指定, 如:
        # --> $dumpfile("tinyriscv_soc_tb.vcd");
        # --> $dumpvars(0, tinyriscv_soc_tb);

        cmd = ' '.join(self.vvp_cmd)

        # vvp_log文件用于存储vvp的输出信息(stdout和stderr), 主要是verilog-$display的输出
        process = subprocess.run(cmd, capture_output=True)

        if process.stdout: 
            str = process.stdout.decode('utf-8')
            sys.stdout.write(str)
            with open(self.path_log, 'w') as vvp_log:
                vvp_log.write(str)

        if process.stderr:
            raise Exception(process.stderr.decode('utf-8'))

    def run(self):
        
        self.gen_vvp_script()
        self.run_vvp()

if __name__ == "__main__":

    if len(sys.argv) == 5:
        # path_this_file = sys.argv[0]    # argv[0] --> Sim.py(本文件)的绝对路径
        path_vvp_script = sys.argv[1]   # argv[1] --> 生成的vvp_script.vvp脚本中间文件的绝对路径
        path_log = sys.argv[2]          # argv[2] --> 希望生成的vvp_log.log文件的绝对路径
        path_tb_top = sys.argv[3]       # argv[3] --> testbench顶层模块的绝对路径
        path_rtl_dir = sys.argv[4]      # argv[4] --> rtl文件夹的绝对路径

        sim = Sim(path_vvp_script, path_log, path_tb_top, path_rtl_dir)
        sim.run()

    else:
        str = f"SimPlus.py: 参数数量错误, 当前len(sys.argv) = {len(sys.argv)}"
        str += "指令格式: python Sim.py <path_vvp_script> <path_log> <path_tb_top> <path_rtl_dir>"

        print(str)
