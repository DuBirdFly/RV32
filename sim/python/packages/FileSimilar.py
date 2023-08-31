import math, sys, os

class FileSimilar:

    def __init__(self, file1_path, file2_path):

        if not os.path.exists(file1_path):
            raise Exception(f'文件1不存在: {file1_path}\n')
        elif not os.path.exists(file2_path):
            raise Exception(f'文件2不存在: {file2_path}\n')

        self.file1_path = file1_path
        self.file2_path = file2_path

    @staticmethod
    def cos_similarity(v1, v2):
        # 计算余弦相似度 (v1, v2为向量)
        
        # 向量点乘
        dot_product = sum(a * b for a, b in zip(v1, v2))
        # 向量长度
        magnitude1 = math.sqrt(sum(a ** 2 for a in v1))
        magnitude2 = math.sqrt(sum(b ** 2 for b in v2))
        # 计算余弦相似度
        if magnitude1 == 0 or magnitude2 == 0:
            return 0
        else:
            return dot_product / (magnitude1 * magnitude2)

    def run(self):
        # 计算两个文件的相似度, 最大为1.0, 最小为0.0

        sys.stdout.write("----------------------------------\n")
        sys.stdout.write("---- PROCESS : FileSimilar.py ----\n")
        sys.stdout.write("----------------------------------\n")

        sys.stdout.write(f"文件1的路径为: {self.file1_path}\n")
        sys.stdout.write(f"文件2的路径为: {self.file2_path}\n")

        # 读取文件内容
        with open(self.file1_path, 'r') as f: file1_content = f.read()
        with open(self.file2_path, 'r') as f: file2_content = f.read()

        # 转化为向量
        file1_words = file1_content.split()
        file2_words = file2_content.split()
        all_words = list(set(file1_words + file2_words))
        file1_vector = [file1_words.count(word) for word in all_words]
        file2_vector = [file2_words.count(word) for word in all_words]

        # 计算余弦相似度
        similarity = self.cos_similarity(file1_vector, file2_vector)

        sys.stdout.write("文件相似度为 = {:.2%}\n".format(similarity))

if __name__ == "__main__":
    
    if len(sys.argv) == 3:
        FileSimilar(sys.argv[1], sys.argv[2]).run()
    else:
        raise Exception("ERROR, 指令结构错误")