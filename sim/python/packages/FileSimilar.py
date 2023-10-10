import math, os

class FileSimilar:

    def __init__(self, file1, file2):

        if not os.path.exists(file1): raise FileNotFoundError(f'文件1不存在: {file1}\n')
        if not os.path.exists(file2): raise FileNotFoundError(f'文件2不存在: {file2}\n')

        self.file1 = file1
        self.file2 = file2

        self.similarity = FileSimilar.run(file1, file2)
        self.similarityStr = f'文件1: {file1}\n文件2: {file2}\n相似度: {self.similarity:.4%}\n'

    @classmethod
    def run(cls, file1, file2):
        # 读取文件内容
        with open(file1, 'r', encoding='utf-8') as f: lines1 = f.readlines()
        with open(file2, 'r', encoding='utf-8') as f: lines2 = f.readlines()

        set1 = set(lines1)
        set2 = set(lines2)

        intersection = set1.intersection(set2)
        union = set1.union(set2)

        similarity = len(intersection) / len(union)

        return similarity

if __name__ == "__main__":
    pass