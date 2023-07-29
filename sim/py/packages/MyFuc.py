import subprocess, os, sys


def run_cmd(cmd):
    # cmd可以是str, 也可以是list

    process = subprocess.run(cmd, capture_output=True)

    if process.stdout: print(process.stdout.decode('utf-8'), end='')
    else: print("stdout: None")

    if process.stderr:
        print(f"stderr:\n{process.stderr.decode('utf-8')}\n强行终止程序")
        exit(0)