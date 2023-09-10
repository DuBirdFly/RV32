import math, os

class FileSimilar:

    def __init__(self, file1, file2):

        if not os.path.exists(file1): raise FileNotFoundError(f'文件1不存在: {file1}\n')
        if not os.path.exists(file2): raise FileNotFoundError(f'文件2不存在: {file2}\n')

        self.file1 = file1
        self.file2 = file2

        self.similarity = FileSimilar.run(file1, file2)
        self.similarityStr = f'文件1: {file1}\n文件2: {file2}\n相似度: {self.similarity:.2%}\n'

    @staticmethod
    def cos_similarity(v1, v2): # 计算余弦相似度 (v1, v2为向量)

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

    @staticmethod
    def run(file1, file2):
        # 计算两个文件的相似度, 最大为1.0, 最小为0.0

        # 读取文件内容
        with open(file1, 'r') as f: file1_content = f.read()
        with open(file2, 'r') as f: file2_content = f.read()

        # 转化为向量
        file1_words = file1_content.split()
        file2_words = file2_content.split()
        all_words = list(set(file1_words + file2_words))
        file1_vector = [file1_words.count(word) for word in all_words]
        file2_vector = [file2_words.count(word) for word in all_words]

        # 计算余弦相似度
        similarity = FileSimilar.cos_similarity(file1_vector, file2_vector)

        return similarity

if __name__ == "__main__":
    
    pass