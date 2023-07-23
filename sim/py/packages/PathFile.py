import os, fnmatch, glob

class PathFile:
    def __init__(self, path):
        pass

    @classmethod
    def get_all_files(cls, dir_path: str, file_type: str = '*.v'):
        # 获取文件夹中的所有文件的绝对路径, 返回一个list
        # dir_path -> str : 文件夹路径, 绝对路径

        files_path = []

        # os.walk() 函数用于遍历目录，fnmatch.filter() 函数用于过滤出 .v 文件
        for root, dirnames, filenames in os.walk(f"{dir_path}"):
            for filename in fnmatch.filter(filenames, file_type):
                # 将找到的文件的相对路径添加到列表中
                absolute_file_path = os.path.join(root, filename)
                files_path.append(absolute_file_path.replace('\\', '/'))

        return files_path

    @classmethod
    def get_file_path(cls,dir_path: str, file_name: str):
        # 获取文件夹中的所有file_name文件的绝对路径, 返回一个list
        file_path_pattern = os.path.join(dir_path, '**', file_name)
        files = glob.glob(file_path_pattern, recursive=True)
        return [s.replace("\\", "/") for s in files]


