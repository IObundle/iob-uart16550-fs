/*
 * SPDX-FileCopyrightText: 2026 IObundle, Lda
 *
 * SPDX-License-Identifier: MIT
 *
 * Py2HWSW Version 0.81.0 has generated this code (https://github.com/IObundle/py2hwsw).
 */


#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "iob_uart16550_driver_files.h"

#include "iob_uart16550_csrs.h"

uint32_t read_reg(int fd, uint32_t addr, uint32_t nbits, uint32_t *value) {
  ssize_t ret = -1;

  if (fd == 0) {
    perror("[User] Invalid file descriptor");
    return -1;
  }

  // Point to register address
  if (lseek(fd, addr, SEEK_SET) == -1) {
    perror("[User] Failed to seek to register");
    return -1;
  }

  // Read value from device
  switch (nbits) {
  case 8:
    uint8_t value8 = 0;
    ret = read(fd, &value8, sizeof(value8));
    if (ret == -1) {
      perror("[User] Failed to read from device");
    }
    *value = (uint32_t)value8;
    break;
  case 16:
    uint16_t value16 = 0;
    ret = read(fd, &value16, sizeof(value16));
    if (ret == -1) {
      perror("[User] Failed to read from device");
    }
    *value = (uint32_t)value16;
    break;
  case 32:
    uint32_t value32 = 0;
    ret = read(fd, &value32, sizeof(value32));
    if (ret == -1) {
      perror("[User] Failed to read from device");
    }
    *value = (uint32_t)value32;
    break;
  default:
    // unsupported nbits
    ret = -1;
    *value = 0;
    perror("[User] Unsupported nbits");
    break;
  }

  return ret;
}

uint32_t write_reg(int fd, uint32_t addr, uint32_t nbits, uint32_t value) {
  ssize_t ret = -1;

  if (fd == 0) {
    perror("[User] Invalid file descriptor");
    return -1;
  }

  // Point to register address
  if (lseek(fd, addr, SEEK_SET) == -1) {
    perror("[User] Failed to seek to register");
    return -1;
  }

  // Write value to device
  switch (nbits) {
  case 8:
    uint8_t value8 = (uint8_t)value;
    ret = write(fd, &value8, sizeof(value8));
    if (ret == -1) {
      perror("[User] Failed to write to device");
    }
    break;
  case 16:
    uint16_t value16 = (uint16_t)value;
    ret = write(fd, &value16, sizeof(value16));
    if (ret == -1) {
      perror("[User] Failed to write to device");
    }
    break;
  case 32:
    ret = write(fd, &value, sizeof(value));
    if (ret == -1) {
      perror("[User] Failed to write to device");
    }
    break;
  default:
    break;
  }

  return ret;
}

int fd = 0;

void iob_uart16550_csrs_init_baseaddr(uint32_t addr) {
  fd = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd == -1) {
    perror("[User] Failed to open the device file");
  }
}

// Core Setters and Getters
void iob_uart16550_csrs_set_rbr_thr_dll(uint8_t value) {
  write_reg(fd, IOB_UART16550_CSRS_RBR_THR_DLL_ADDR,
            IOB_UART16550_CSRS_RBR_THR_DLL_W, value);
}
uint8_t iob_uart16550_csrs_get_rbr_thr_dll() {
  uint32_t return_value = 0;
  read_reg(fd, IOB_UART16550_CSRS_RBR_THR_DLL_ADDR,
           IOB_UART16550_CSRS_RBR_THR_DLL_W, &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_ier_dlm(uint8_t value) {
  write_reg(fd, IOB_UART16550_CSRS_IER_DLM_ADDR, IOB_UART16550_CSRS_IER_DLM_W,
            value);
}
uint8_t iob_uart16550_csrs_get_ier_dlm() {
  uint32_t return_value = 0;
  read_reg(fd, IOB_UART16550_CSRS_IER_DLM_ADDR, IOB_UART16550_CSRS_IER_DLM_W,
           &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_iir_fcr(uint8_t value) {
  write_reg(fd, IOB_UART16550_CSRS_IIR_FCR_ADDR, IOB_UART16550_CSRS_IIR_FCR_W,
            value);
}
uint8_t iob_uart16550_csrs_get_iir_fcr() {
  uint32_t return_value = 0;
  read_reg(fd, IOB_UART16550_CSRS_IIR_FCR_ADDR, IOB_UART16550_CSRS_IIR_FCR_W,
           &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_lcr(uint8_t value) {
  write_reg(fd, IOB_UART16550_CSRS_LCR_ADDR, IOB_UART16550_CSRS_LCR_W, value);
}
uint8_t iob_uart16550_csrs_get_lcr() {
  uint32_t return_value = 0;
  read_reg(fd, IOB_UART16550_CSRS_LCR_ADDR, IOB_UART16550_CSRS_LCR_W,
           &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_mcr(uint8_t value) {
  write_reg(fd, IOB_UART16550_CSRS_MCR_ADDR, IOB_UART16550_CSRS_MCR_W, value);
}
uint8_t iob_uart16550_csrs_get_lsr() {
  uint32_t return_value = 0;
  read_reg(fd, IOB_UART16550_CSRS_LSR_ADDR, IOB_UART16550_CSRS_LSR_W,
           &return_value);
  return (uint8_t)return_value;
}
uint8_t iob_uart16550_csrs_get_msr() {
  uint32_t return_value = 0;
  read_reg(fd, IOB_UART16550_CSRS_MSR_ADDR, IOB_UART16550_CSRS_MSR_W,
           &return_value);
  return (uint8_t)return_value;
}
uint16_t iob_uart16550_csrs_get_version() {
  uint32_t return_value = 0;
  read_reg(fd, IOB_UART16550_CSRS_VERSION_ADDR, IOB_UART16550_CSRS_VERSION_W,
           &return_value);
  return (uint16_t)return_value;
}
