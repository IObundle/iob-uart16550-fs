<!--
SPDX-FileCopyrightText: 2025 IObundle

SPDX-License-Identifier: MIT
-->

# IObundle Releases Open-Source UART16550 Core for FPGA SoC Design

**Lisbon, Portugal** — IObundle, Lda., a company specializing in open-source FPGA System-on-Chip (SoC) components, announces the release of IOb-UART16550, a free and open-source UART16550 serial communication IP core adapted for the IOb-SoC platform.

## About IOb-UART16550

IOb-UART16550 is an open-source hardware core that implements the industry-standard 16550 Universal Asynchronous Receiver-Transmitter (UART) interface, widely supported by major operating systems including Linux. Based on the well-known OpenCores UART16550 project, IObundle's adaptation integrates seamlessly with the IOb-SoC ecosystem, enabling designers to quickly add robust serial communication to their FPGA-based systems.

## Key Features

- **Multiple CSR interfaces**: Supports IOb native, AXI-Lite, and Wishbone control and status register interfaces, offering flexibility for different SoC architectures.
- **Hardware flow control**: Implements dedicated hardware-based RTS/CTS signal management for reliable high-speed serial communication.
- **Large FIFO buffers**: Provides 256-byte transmit and receive FIFOs for efficient data handling and reduced CPU overhead.
- **Linux-compatible**: Fully compatible with standard Linux UART drivers, facilitating rapid software development and deployment.
- **Py2HWSW integration**: Leverages the [Py2HWSW](https://nlnet.nl/project/Py2HWSW/) workflow for automated hardware and software component generation, simplifying the design process.
- **FuseSoC support**: Pre-built, FuseSoC-compatible releases are available, enabling straightforward integration with popular FPGA toolchains.

## Applications

IOb-UART16550 is well-suited for FPGA-based SoC designs requiring serial communication, including embedded Linux systems, debug consoles, industrial control systems, and hardware prototyping platforms. It is currently used as part of the [SoCLinux](https://nlnet.nl/project/SoCLinux) project, which targets running Linux on fully open-source FPGA SoCs.

## Availability

IOb-UART16550 is available now as free and open-source software under the MIT license at:
[https://github.com/IObundle/iob-uart16550](https://github.com/IObundle/iob-uart16550)

## Funding

This core is developed as part of the [SoCLinux](https://nlnet.nl/project/SoCLinux) project, funded through [NGI Zero Core](https://nlnet.nl/core), a fund established by [NLnet](https://nlnet.nl) with financial support from the European Commission's Next Generation Internet program.

## About IObundle, Lda.

IObundle, Lda. is a Portuguese technology company dedicated to developing open-source hardware and software solutions for FPGA-based SoC design. IObundle's IP cores and tools are freely available on GitHub at [https://github.com/IObundle](https://github.com/IObundle).

**Contact:**
IObundle, Lda.
Lisbon, Portugal
[https://github.com/IObundle](https://github.com/IObundle)
