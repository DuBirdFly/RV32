import math, os

class FileSimilar:

    def __init__(self, file1, file2):

        if not os.path.exists(file1): raise FileNotFoundError(f'文件1不存在: {file1}\n')
        if not os.path.exists(file2): raise FileNotFoundError(f'文件2不存在: {file2}\n')

        self.file1 = file1
        self.file2 = file2

        self.similarity = FileSimilar.run(file1, file2)
        self.similarityStr = f'文件1: {file1}\n文件2: {file2}\n相似度: {self.similarity:.4%}\n'

    @staticmethod
    def cos_similarity(v1, v2) -> float: # 计算余弦相似度 (v1, v2为向量)
        # 向量点乘
        dot_product = sum(a * b for a, b in zip(v1, v2))
        # 向量长度
        magnitude1 = math.sqrt(sum(a ** 2 for a in v1))
        magnitude2 = math.sqrt(sum(b ** 2 for b in v2))
        # 计算余弦相似度
        if magnitude1 == 0 or magnitude2 == 0: return 0
        else:
            return dot_product / (magnitude1 * magnitude2)

    @staticmethod
    def run(file1, file2) -> float:  # 计算两个文件的相似度, 最大为1.0, 最小为0.0

        # 读取文件内容, 并通过 split() 分割为单词向量
        with open(file1, 'r') as f: words1 = f.read().split()
        with open(file2, 'r') as f: words2 = f.read().split()

        # 转化为向量
        words = list(set(words1 + words2))
        vector1 = [words1.count(word) for word in words]
        vector2 = [words2.count(word) for word in words]

        # 计算余弦相似度
        return FileSimilar.cos_similarity(vector1, vector2)

if __name__ == "__main__":
    pass