# Fixboot

Fix for legacy ESP8266 bootloader which allows OTA updates with 8MB or 16MB flash map.

## Description

The ESP8266 NONOS SDK, as well as RTOS SDK v1.x/v2.x, rely on the legacy bootloader provided as a binary blob.
Unfortunately, it has a bug that prevents OTA updates when the 8MB or 16MB flash map is used. This repository provides a
patched `boot_v1.7bigflash.bin` that is a drop-in replacement for `boot_v1.7.bin` bootloader and enables OTA updates
with any flash size, without the need to change any user code.

The patch works by inserting a small assembly stub into an unused part of the original bootloader. See
[fixboot.s](fixboot.s) for details. It was developed by partially reverse-engineering the bootloader to identify and fix
the problem. The following resources were very helpful:

- [Decompiling the ESP8266 boot loader v1.3(b3)](
https://richard.burtons.org/2015/05/17/decompiling-the-esp8266-boot-loader-v1-3b3/)
- [ESP8266 16MB Flash Handling](
https://piers.rocks/esp8266/16mb/flash/eeprom/2016/10/14/esp8266-16mbyte-flash_handling.html)
- [An short guide to Xtensa assembly language](http://cholla.mmto.org/esp8266/xtensa.html)

If you don't like binary blobs, check out [MBoot](https://github.com/mwasacz/mboot) which is also a drop-in replacement
for `boot_v1.7bin`, but is fully open source.

**Note:** NONOS SDK and RTOS SDK v1.x/v2.x are deprecated. You should use RTOS SDK v3.x for new projects.

## Compilation

The compiled binary is available on the [Releases](https://github.com/mwasacz/fixboot/releases) page. If you want to
build it yourself, you'll need the ESP8266 toolchain (version 4.8.5 is recommended). On Windows, a compatibility layer
such as MSYS2 is required. For installation instructions, refer to
[RTOS SDK docs](https://docs.espressif.com/projects/esp8266-rtos-sdk/en/latest/get-started/index.html#setup-toolchain).
Make sure `xtensa-lx106-elf/bin` is added to the `PATH` environment variable.

Once you have the toolchain installed, run `./fixboot.sh` (on Windows use the MSYS2 shell). On successful completion,
the script should print `DONE`.

## Usage

When flashing the ESP8266, simply use `boot_v1.7bigflash.bin` instead of `boot_v1.7.bin`. The regular NONOS SDK or RTOS
SDK v1.x/v2.x OTA update process should work without issues.

## License

This project is released under the [Apache-2.0 license](LICENSE). The `boot_v1.7.bin` file was taken from the
[ESP8266 RTOS SDK](https://github.com/espressif/ESP8266_RTOS_SDK) repository which is released under the
[Apache-2.0 license](https://github.com/espressif/ESP8266_RTOS_SDK/blob/master/LICENSE).
