import math, os

class FileSimilar:

    def __init__(self, file1_path, file2_path):
        self.file1_path = file1_path
        self.file2_path = file2_path

        # 计算两个文件的相似度
        self.similarity = self.calculate_similarity(file1_path, file2_path)
        

    @classmethod
    def cos_similarity(cls, v1, v2):
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

    @classmethod
    def calculate_similarity(cls, file1_path, file2_path):
        # 计算两个文件的相似度, 最大为1.0, 最小为0.0

        # 读取文件内容
        with open(file1_path, 'r') as f: file1_content = f.read()
        with open(file2_path, 'r') as f: file2_content = f.read()

        # 转化为向量
        file1_words = file1_content.split()
        file2_words = file2_content.split()
        all_words = list(set(file1_words + file2_words))
        file1_vector = [file1_words.count(word) for word in all_words]
        file2_vector = [file2_words.count(word) for word in all_words]

        # 计算余弦相似度
        similarity = cls.cos_similarity(file1_vector, file2_vector)

        # 返回相似度
        return similarity

if __name__ == "__main__":
    PATH_CWD = os.getcwd().replace('\\', '/')
    PATH_SIM = f"{PATH_CWD}/sim"
    PATH_REF = f"{PATH_SIM}/riscv-compliance"
    NAME_INST_SET = "rv32i"
    NAME_BIN = "I-JAL-01"

    ref_file = f"{PATH_REF}/riscv-test-suite/{NAME_INST_SET}/references/{NAME_BIN}.reference_output"
    my_file = f"{PATH_SIM}/output/signature.output"

    similarity = FileSimilar(ref_file, my_file).similarity

    print(f"文件相似度为 = ", '{:.2%}'.format(similarity))