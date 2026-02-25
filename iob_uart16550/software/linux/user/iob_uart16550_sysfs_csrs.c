/*
 * SPDX-FileCopyrightText: 2025 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "iob_uart16550_driver_files.h"

#include "iob_uart16550_csrs.h"

int sysfs_read_file(const char *filename, uint32_t *read_value) {
  // Open file for read
  FILE *file = fopen(filename, "r");
  if (file == NULL) {
    perror("[User] Failed to open the file");
    return -1;
  }

  // Read uint32_t value from file in ASCII
  ssize_t ret = fscanf(file, "%u", read_value);
  if (ret == -1) {
    perror("[User] Failed to read from file");
    fclose(file);
    return -1;
  }

  fclose(file);

  return ret;
}

int sysfs_write_file(const char *filename, uint32_t write_value) {
  // Open file for write
  FILE *file = fopen(filename, "w");
  if (file == NULL) {
    perror("[User] Failed to open the file");
    return -1;
  }

  // Write uint32_t value to file in ASCII
  ssize_t ret = fprintf(file, "%u", write_value);
  if (ret == -1) {
    perror("[User] Failed to write to file");
    fclose(file);
    return -1;
  }

  fclose(file);

  return ret;
}

// Empty init function - base address is obtained from device tree
void iob_uart16550_csrs_init_baseaddr(uint32_t addr) {}

// Core Setters and Getters
void iob_uart16550_csrs_set_rbr_thr_dll(uint8_t value) {
  sysfs_write_file(IOB_UART16550_SYSFILE_RBR_THR_DLL, value);
}
uint8_t iob_uart16550_csrs_get_rbr_thr_dll() {
  uint32_t return_value = 0;
  sysfs_read_file(IOB_UART16550_SYSFILE_RBR_THR_DLL, &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_ier_dlm(uint8_t value) {
  sysfs_write_file(IOB_UART16550_SYSFILE_IER_DLM, value);
}
uint8_t iob_uart16550_csrs_get_ier_dlm() {
  uint32_t return_value = 0;
  sysfs_read_file(IOB_UART16550_SYSFILE_IER_DLM, &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_iir_fcr(uint8_t value) {
  sysfs_write_file(IOB_UART16550_SYSFILE_IIR_FCR, value);
}
uint8_t iob_uart16550_csrs_get_iir_fcr() {
  uint32_t return_value = 0;
  sysfs_read_file(IOB_UART16550_SYSFILE_IIR_FCR, &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_lcr(uint8_t value) {
  sysfs_write_file(IOB_UART16550_SYSFILE_LCR, value);
}
uint8_t iob_uart16550_csrs_get_lcr() {
  uint32_t return_value = 0;
  sysfs_read_file(IOB_UART16550_SYSFILE_LCR, &return_value);
  return (uint8_t)return_value;
}
void iob_uart16550_csrs_set_mcr(uint8_t value) {
  sysfs_write_file(IOB_UART16550_SYSFILE_MCR, value);
}
uint8_t iob_uart16550_csrs_get_lsr() {
  uint32_t return_value = 0;
  sysfs_read_file(IOB_UART16550_SYSFILE_LSR, &return_value);
  return (uint8_t)return_value;
}
uint8_t iob_uart16550_csrs_get_msr() {
  uint32_t return_value = 0;
  sysfs_read_file(IOB_UART16550_SYSFILE_MSR, &return_value);
  return (uint8_t)return_value;
}
uint16_t iob_uart16550_csrs_get_version() {
  uint32_t return_value = 0;
  sysfs_read_file(IOB_UART16550_SYSFILE_VERSION, &return_value);
  return (uint16_t)return_value;
}
