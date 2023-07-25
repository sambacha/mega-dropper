import sys
import os
import random


def main():
    random.seed(0)

    amount_cap = int(float(sys.argv[1]) * 1e18)
    total_addresses = int(sys.argv[2])

    cd = bytes()

    total = 0
    for _ in range(total_addresses):
        amount = random.randint(0, amount_cap)
        total += amount
        addr = os.urandom(20)

        encoded = amount.to_bytes(12, 'big') + addr

        cd += encoded

    print(f'amount: {total}')
    print(f'0x{cd.hex()}')


if __name__ == '__main__':
    main()
