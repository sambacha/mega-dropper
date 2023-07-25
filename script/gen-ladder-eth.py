from huff import *


def main():
    c = comment_align('    send256:                // [size_left]')

    for i in range(1, 10):
        size = 1 << i

        if i == 1:
            inner = 'msize msize'
        else:
            inner = f'WORD_{1 << (i-1)}() WORD_{1 << (i-1)}()'

        print(
            line(
                0, None, f'#define macro WORD_{size}() = takes(0) returns({size}) {{ {inner} }}')
        )

    for i in range(1, 10):
        size = 1 << i

        if i == 1:
            inner = 'SEND_ETH_STEP() SEND_ETH_STEP()'
        else:
            inner = f'SEND_ETH_STEP_{1 << (i-1)}() SEND_ETH_STEP_{1 << (i-1)}()'

        print(
            line(
                0, None, f'#define macro SEND_ETH_STEP_{size}() = takes({size + 1}) returns(1) {{ {inner} }}')
        )

    for i in range(8, 0, -1):
        size = 1 << i
        print(line(1, c, f'send{size}: // [size_left]'))
        print(line(2, c, f'dup1 // [size_left, size_left]'))
        print(
            line(
                2, c, f'0x{size << 5:x} // [size_left, size_left, {size}*0x20]')
        )
        print(
            line(2, c, f'and // [size_left, section_bit_set]')
        )
        print(
            line(2, c, f'iszero // [size_left, skip_section]')
        )
        print(
            line(2, c, f'send{1 << (i-1)} jumpi // [size_left]')
        )
        if size > 32:
            print(line(2, c, f'0x0 // [size_left, 0]'))
            print(line(2, c, f'mstore // []'))
            print(line(2, c, f'WORD_{size}() // [0x20 ...]'))
        elif size == 32:
            print(line(2, c, f'WORD_16() // [size_left, 0x20 ...]'))
            print(line(2, c, f'swap16 // [0x20 ..., size_left]'))
            print(line(2, c, f'WORD_16() // [0x20 ..., size_left, 0x20 ...]'))
            print(line(2, c, f'swap16 // [0x20 ..., size_left]'))
        else:
            print(line(2, c, f'WORD_{size}() // [size_left, 0x20 ...]'))

        if size > 16:
            print(line(2, c, f'0x0 // [0x20 ..., 0]'))
            print(line(2, c, f'mload // [0x20 ..., size_left]'))
        else:
            print(line(2, c, f'swap{size} // [0x20 ..., size_left]'))

        print(line(2, c, f'SEND_ETH_STEP_{size}() // [size_left\']'))

    print(line(1, c, 'send1: // [size_left]'))
    print(line(2, c, 'iszero // [skip_section]'))
    print(line(2, c, 'end jumpi // []'))
    print(line(2, c, 'SEND_ETH() // []'))


if __name__ == '__main__':
    main()
