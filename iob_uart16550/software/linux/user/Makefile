# SPDX-FileCopyrightText: 2025 IObundle
#
# SPDX-License-Identifier: MIT

# Select kernel-userspace interface: sysfs; dev; ioctl
IF ?= sysfs
UPPER_IF = $(shell echo $(IF) | tr '[:lower:]' '[:upper:]')
SRC = $(BIN).c iob_uart16550_$(IF)_csrs.c
SRC += $(wildcard ../../src/iob_uart16550.c)
HDR += ../drivers/iob_uart16550_driver_files.h
FLAGS = -Wall -Werror -O2
FLAGS += -static
FLAGS += -march=rv32imac
FLAGS += -mabi=ilp32
FLAGS += -I../drivers -I../../src
FLAGS += -D$(UPPER_IF)_IF
BIN = iob_uart16550_user
CC = riscv64-unknown-linux-gnu-gcc

$(BIN)_$(IF): $(SRC) $(HDR)
	$(CC) $(FLAGS) $(INCLUDE) -o $(BIN)_$(IF) $(SRC)

all:
	make IF=sysfs
	make IF=dev
	make IF=ioctl
	make BIN=iob_uart16550_tests IF=sysfs
	make BIN=iob_uart16550_tests IF=dev
	make BIN=iob_uart16550_tests IF=ioctl

clean:
	rm -f $(BIN)_sysfs $(BIN)_dev $(BIN)_ioctl

.PHONY: all clean
