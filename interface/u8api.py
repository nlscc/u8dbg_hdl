import struct
import serial # pyserial

DEBUG = False

class U8Debug:
    """ Interface class with nX-u8 debugger FPGA """
    def __init__(self, port="/dev/ttyUSB1"):
        self.ser = serial.Serial(port, 9600)
    def read_val(self, reg):
        """ Read a 7-bit debug register. """
        assert reg < 0x80
        self.ser.write(b"r")
        self.ser.write(bytes([reg]))
        res = struct.unpack(">H", self.ser.read(2))[0]
        if DEBUG: print("[d] read(0x{:02x}) => 0x{:04x}".format(reg, res))
        return res
    def write_val(self, reg, val):
        """ Write a 16-bit value to a 7-bit debug register. """
        assert reg < 0x80
        self.ser.write(b"w")
        self.ser.write(bytes([reg]))
        self.ser.write(struct.pack(">H", val))
        if DEBUG: print("[d] write(0x{:02x}, 0x{:04x})".format(reg, val))
        assert self.ser.read(2) == bytes.fromhex("1000")
