# SPDX-FileCopyrightText: 2025 IObundle, Lda
#
# SPDX-License-Identifier: MIT
#
# Py2HWSW Version 0.81 has generated this code (https://github.com/IObundle/py2hwsw).

NAME=iob_uart16550
CSR_IF ?=iob
BUILD_DIR_NAME=iob_uart16550_V0.1
IS_FPGA=0

CONFIG_BUILD_DIR = $(dir $(lastword $(MAKEFILE_LIST)))
ifneq ($(wildcard $(CONFIG_BUILD_DIR)/custom_config_build.mk),)
include $(CONFIG_BUILD_DIR)/custom_config_build.mk
endif
