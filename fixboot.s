# Fix for the legacy ESP8266 bootloader
# Allows OTA updates with 8MB or 16MB flash map
# Only works with boot_1.7.bin (5d6f877)

# Problem with the original bootloader:
# The bootloader always runs user1 slot, ignoring settings in the config section.
# Reason:
# SPIRead function is called to read config section from the last flash sectors to decide which OTA slot to run.
# SPIRead first checks if the section to read is less than flashchip->chipsize.
# However, it appears that flashchip->chipsize is not updated and has the default value 0x400000.
# Therefore, SPIRead fails and the default user1 slot is run.
# Fix:
# Update flashchip->chipsize right before calling SPIRead to read the last flash sector.

.org 0x10                       # Section from 0x10 to 0x3F appears to be unused so we can place our code here
flashchip:  .word 0x3FFFC714
SPIRead:    .word 0x40004B1C
fix_chipsize:
    l32r    a0, flashchip       # Load address of pointer to the flashchip struct
    l32i    a0, a0, 0           # Load the pointer
    addmi   a2, a2, 0x1000      # Register a2 holds the address of last flash sector, add 0x1000 to get flash size
    s32i    a2, a0, 4           # Store flash size, chipsize is at offset 4 in the flashchip struct
    addmi   a2, a2, -0x1000     # Restore previous a2 value
    l32r    a0, SPIRead         # Load address of SPIRead function, this is the instruction we replaced at 0x756
    j       call_SPIRead        # Jump back
.org 0x40

.org 0x756                      # This is the place where SPIRead was called
load_SPIRead_addr:              # Original instruction was: l32r a0, SPIRead
    j       fix_chipsize        # Jump to our code instead
call_SPIRead:                   # Keep the original instruction: callx0 a0
.org 0x759

.org 0xDC9                      # Overwrite the version string
version:    .ascii "1.7 bigflash"
.org 0xDD5
