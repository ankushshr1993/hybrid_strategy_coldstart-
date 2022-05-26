def matrix_multiplication(n):

    import numpy as np
    from time import time

    np.random.seed(42)
    t0 = time()
    A = np.random.randint(100, 200, size=(900,800))
    B = np.random.randint(100, 200, size =(800,700))
    C = np.matmul(A, B)

    #print("matrix generation and multiplication completed in %0.8fs." % (time() - t0))
    tm=(time() - t0)
    return tm

def main(args):
    matrix1 = args.get("matrix", 0)
    output = matrix_multiplication(matrix1)
    return {"output": output}
