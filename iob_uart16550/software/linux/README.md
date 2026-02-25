<!--
SPDX-FileCopyrightText: 2025 IObundle

SPDX-License-Identifier: MIT
-->

# IOB_UART16550 Linux Kernel Drivers
- Structure:
    - `drivers/`: directory with linux kernel module drivers for iob_uart16550
        - `iob_uart16550_main.c`: driver source
        - `iob_uart16550_driver_files.h` and `iob_uart16550_sysfs.h`: header files
        - `driver.mk`: makefile segment with `iob_uart16550-obj:` target for driver
          compilation
    - `user/`: directory with user application example that uses iob_uart16550
      drivers
        - `iob_uart16550_user.c`: user space application that uses iob_uart16550
          drivers. Example provided for some cores.
        - `Makefile`: user application compilation targets
    - `iob_uart16550.dts`: device tree template with iob_uart16550 node
        - manually add the `iob_uart16550` node to the system device tree so the
          iob_uart16550 is recognized by the linux kernel
