# -*- coding=utf-8 -*-

import os, json
from pathlib import Path

class DirTree:
    def __init__(self, path='.', shieldpath=[]):
        self.path = path
        self.shieldpath = shieldpath
        self.tree_dict = self.gen_tree_dict()

    def gen_tree_dict(self):
        # 返回一个嵌套的字典
        tree_dict = {}
        for root, dirs, files in os.walk(self.path):
            # 跳过被屏蔽的文件夹路径
            for shield in self.shieldpath:
                if str(Path(root).resolve()).startswith(str(Path(shield).resolve())):
                    dirs.clear()
                    break
            # 生成子树
            subtree = tree_dict
            for files_path in Path(root).relative_to(self.path).parts:
                subtree = subtree.setdefault(files_path, {})
            # 添加文件到子树
            for file in files:
                subtree[file] = None
        
        return tree_dict

    @classmethod
    def gen_tree_str_cmd(cls, dict, indent=0, last=True):
        # 模仿cmd的tree命令输出树状结构, 返回一个字符串
        count = len(dict)
        result = ""
        for index, (key, value) in enumerate(dict.items()):
            if index == count - 1:
                line = "└─ "
                next_indent = "   " if last else "│  "
            else:
                line = "├─ "
                next_indent = "│  "
            result += ' ' * indent + line + str(key) + "\n"
            if value is not None:
                is_last = (index == count - 1)
                result += cls.gen_tree_str_cmd(value, indent + len(next_indent), is_last)
        return result

    @classmethod
    def gen_tree_str_json(cls, dict):
        # 生成tree_dict字典的json字符串
        return json.dumps(dict, indent=4)

    @classmethod
    def gen_dict_from_json(cls, json_str):
        # 由json字符串生成tree_dict字典
        return json.loads(json_str)

if __name__ == '__main__':

    dirT = DirTree(shieldpath=["sim/riscv-compliance", "sim/riscv-isa"])

    tree_str = dirT.gen_tree_str_cmd(dirT.tree_dict)

    print(tree_str)

    #将tree_str写入文件, 使用utf-8编码
    with open("tree.txt", "w", encoding="utf-8") as f:
        f.write(tree_str)

    print("---------------------------Finished!---------------------------")
