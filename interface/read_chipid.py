#!/usr/bin/env python3

import sys

from u8api import U8Debug

def main():
    if len(sys.argv) != 2:
        print("usage: {} SERIAL_PORT".format(sys.argv[0]))
        return
    dbg = U8Debug(sys.argv[1])
    # start debug interface
    dbg.write_val(0x00, 0xaafe)
    # read ChipID
    chipid_words = []
    chipid_words.append(dbg.read_val(0x40))
    chipid_words.append(dbg.read_val(0x41))
    chipid_words.append(dbg.read_val(0x42))
    chipid_words.append(dbg.read_val(0x43))
    chipid_words.append(dbg.read_val(0x50))
    chipid_words.append(dbg.read_val(0x51))
    chipid_words.append(dbg.read_val(0x52))
    chipid_words.append(dbg.read_val(0x53))
    print("{:04x}{:04x}".format(chipid_words[1], chipid_words[0]))
    print("{:04x}{:04x}".format(chipid_words[3], chipid_words[2]))
    print("{:04x}{:04x}".format(chipid_words[5], chipid_words[4]))
    print("{:04x}{:04x}".format(chipid_words[7], chipid_words[6]))

if __name__ == "__main__":
    main()
