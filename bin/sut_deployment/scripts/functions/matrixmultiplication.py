def matrix_multiplication(matrix1=(900,800),matrix2=(800,700)):

    import numpy as np
    from time import time

    np.random.seed(42)
    t0 = time()
    A = np.random.randint(100, 200, size=(matrix1[0],matrix1[1]))
    B = np.random.randint(100, 200, size =(matrix2[0],matrix2[0]))
    C = np.matmul(A, B)

    #print("matrix generation and multiplication completed in %0.8fs." % (time() - t0))
    tm=(time() - t0)
    return tm

def main(args):
    matrix = args.get("matrix", 0)
    output = matrix_multiplication(matrix)
    return {"matrix": output}
