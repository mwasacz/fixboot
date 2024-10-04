#!/bin/sh
set -e

copy_bytes () {
    dd if=fixboot.bin of=boot_v1.7bigflash.bin conv=notrunc bs=1 seek=$1 skip=$1 count=$(($2-$1))
}

cp boot_v1.7.bin boot_v1.7bigflash.bin

# Run the assembler
xtensa-lx106-elf-as --warn fixboot.s -o fixboot.o
xtensa-lx106-elf-ld fixboot.o -o fixboot.elf
xtensa-lx106-elf-objcopy -O binary fixboot.elf fixboot.bin

# Splice the files
copy_bytes $((0x10)) $((0x40))
copy_bytes $((0x756)) $((0x759))
copy_bytes $((0xDC9)) $((0xDD5))

# Update checksum (calculated using esptool.py)
printf '\xE9' | dd of=boot_v1.7bigflash.bin conv=notrunc bs=1 seek=$((0xFEF))

rm fixboot.o fixboot.elf fixboot.bin
echo 'DONE'
