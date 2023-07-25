import subprocess
import sys


def main():
    direct_out = subprocess.getoutput(
        f'huffc -r {sys.argv[1]}'
    ).splitlines()[-1]
    bytecode = bytes.fromhex(direct_out)
    print(f'size: {len(bytecode)} ({len(bytecode) / 24576:.2%})')


if __name__ == '__main__':
    main()
