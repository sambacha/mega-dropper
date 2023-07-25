from huff import *


def main():
    c = comment_align('    loop512:             // [size_left]')
    for i in range(512):
        print(line(2, c, f'0x{(i + 1)*0x20:x} // [size_left, rel_offset]'))
        print(line(2, c, 'dup2 // [size_left, rel_offset, size_left]'))
        print(line(2, c, 'sub // [size_left, cd_offset]'))
        print(line(2, c, 'SEND_ETH() // [size_left]'))


if __name__ == '__main__':
    main()
