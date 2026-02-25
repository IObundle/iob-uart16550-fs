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
#include <sys/ioctl.h>
#include <unistd.h>

#include "iob_uart16550_driver_files.h"

#include "iob_uart16550_csrs.h"

#define WR_RBR_THR_DLL _IOW('?', 0, int32_t *)
#define RD_RBR_THR_DLL _IOR('?', 1, int32_t *)
#define WR_IER_DLM _IOW('?', 2, int32_t *)
#define RD_IER_DLM _IOR('?', 3, int32_t *)
#define WR_IIR_FCR _IOW('?', 4, int32_t *)
#define RD_IIR_FCR _IOR('?', 5, int32_t *)
#define WR_LCR _IOW('?', 6, int32_t *)
#define RD_LCR _IOR('?', 7, int32_t *)
#define WR_MCR _IOW('?', 8, int32_t *)
#define RD_LSR _IOR('?', 9, int32_t *)
#define RD_MSR _IOR('?', 10, int32_t *)
#define RD_VERSION _IOR('?', 11, int32_t *)
int fd = 0;

void iob_uart16550_csrs_init_baseaddr(uint32_t addr) {
  fd = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd == -1) {
    perror("[User] Failed to open the device file");
  }
}

// Core Setters and Getters
void iob_uart16550_csrs_set_rbr_thr_dll(uint8_t value) {
  ioctl(fd, WR_RBR_THR_DLL, (int32_t *)&value);
}
uint8_t iob_uart16550_csrs_get_rbr_thr_dll() {
  uint32_t return_value = 0;
  ioctl(fd, RD_RBR_THR_DLL, (int32_t *)&return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_ier_dlm(uint8_t value) {
  ioctl(fd, WR_IER_DLM, (int32_t *)&value);
}
uint8_t iob_uart16550_csrs_get_ier_dlm() {
  uint32_t return_value = 0;
  ioctl(fd, RD_IER_DLM, (int32_t *)&return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_iir_fcr(uint8_t value) {
  ioctl(fd, WR_IIR_FCR, (int32_t *)&value);
}
uint8_t iob_uart16550_csrs_get_iir_fcr() {
  uint32_t return_value = 0;
  ioctl(fd, RD_IIR_FCR, (int32_t *)&return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_lcr(uint8_t value) {
  ioctl(fd, WR_LCR, (int32_t *)&value);
}
uint8_t iob_uart16550_csrs_get_lcr() {
  uint32_t return_value = 0;
  ioctl(fd, RD_LCR, (int32_t *)&return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_mcr(uint8_t value) {
  ioctl(fd, WR_MCR, (int32_t *)&value);
}
uint8_t iob_uart16550_csrs_get_lsr() {
  uint32_t return_value = 0;
  ioctl(fd, RD_LSR, (int32_t *)&return_value);
  return (uint8_t)return_value;
}
uint8_t iob_uart16550_csrs_get_msr() {
  uint32_t return_value = 0;
  ioctl(fd, RD_MSR, (int32_t *)&return_value);
  return (uint8_t)return_value;
}
uint16_t iob_uart16550_csrs_get_version() {
  uint32_t return_value = 0;
  ioctl(fd, RD_VERSION, (int32_t *)&return_value);
  return (uint16_t)return_value;
}
