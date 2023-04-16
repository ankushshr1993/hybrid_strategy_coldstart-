def prime_number(n):
    from time import time
    t0 = time()
    primes = []
    for i in range (2, n+1):
        for j in range(2, i):
            if i%j == 0:
                break
        else:
            primes.append(i)

    return len(primes)


def main(args):
    prime = args.get("primenumber", 15000)
    output = prime_number(prime)
    return {"primenumber": output}
