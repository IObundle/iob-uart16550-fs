/*
 * SPDX-FileCopyrightText: 2025 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#include "iob_uart16550.h"
#include "iob_uart16550_csrs.h"
#include "iob_uart16550_driver_files.h"

//
// Test macros
//
#define TEST_PASSED 0
#define TEST_FAILED 1

#define TEST_WRITE_VALUE 0x12345678

#define RUN_TEST(test_name)                                                    \
  printf("Running test: %s...\n", #test_name);                                 \
  if (test_name() != TEST_PASSED) {                                            \
    printf("Test failed: %s\n", #test_name);                                   \
    return TEST_FAILED;                                                        \
  }                                                                            \
  printf("Test passed: %s\n", #test_name);

//
// Functionality tests
//

int test_functionality_rbr_thr_dll_write() {
  // Cast the test value to the correct data type, adjusting to the CSR width
  // (ignoring most significant bits if needed)
  uint8_t value = (uint8_t)TEST_WRITE_VALUE;
  iob_uart16550_csrs_set_rbr_thr_dll(value);

  uint8_t read_value = iob_uart16550_csrs_get_rbr_thr_dll();
  if (read_value != value) {
    printf("Error: Read value (0x%x) does not match written value (0x%x)\n",
           read_value, value);
    return TEST_FAILED;
  }

  return TEST_PASSED;
}

int test_functionality_rbr_thr_dll_read() {
  iob_uart16550_csrs_get_rbr_thr_dll();
  return TEST_PASSED;
}

int test_functionality_ier_dlm_write() {
  // Cast the test value to the correct data type, adjusting to the CSR width
  // (ignoring most significant bits if needed)
  uint8_t value = (uint8_t)TEST_WRITE_VALUE;
  iob_uart16550_csrs_set_ier_dlm(value);

  uint8_t read_value = iob_uart16550_csrs_get_ier_dlm();
  if (read_value != value) {
    printf("Error: Read value (0x%x) does not match written value (0x%x)\n",
           read_value, value);
    return TEST_FAILED;
  }

  return TEST_PASSED;
}

int test_functionality_ier_dlm_read() {
  iob_uart16550_csrs_get_ier_dlm();
  return TEST_PASSED;
}

int test_functionality_iir_fcr_write() {
  // Cast the test value to the correct data type, adjusting to the CSR width
  // (ignoring most significant bits if needed)
  uint8_t value = (uint8_t)TEST_WRITE_VALUE;
  iob_uart16550_csrs_set_iir_fcr(value);

  uint8_t read_value = iob_uart16550_csrs_get_iir_fcr();
  if (read_value != value) {
    printf("Error: Read value (0x%x) does not match written value (0x%x)\n",
           read_value, value);
    return TEST_FAILED;
  }

  return TEST_PASSED;
}

int test_functionality_iir_fcr_read() {
  iob_uart16550_csrs_get_iir_fcr();
  return TEST_PASSED;
}

int test_functionality_lcr_write() {
  // Cast the test value to the correct data type, adjusting to the CSR width
  // (ignoring most significant bits if needed)
  uint8_t value = (uint8_t)TEST_WRITE_VALUE;
  iob_uart16550_csrs_set_lcr(value);

  uint8_t read_value = iob_uart16550_csrs_get_lcr();
  if (read_value != value) {
    printf("Error: Read value (0x%x) does not match written value (0x%x)\n",
           read_value, value);
    return TEST_FAILED;
  }

  return TEST_PASSED;
}

int test_functionality_lcr_read() {
  iob_uart16550_csrs_get_lcr();
  return TEST_PASSED;
}

int test_functionality_mcr_write() {
  // Cast the test value to the correct data type, adjusting to the CSR width
  // (ignoring most significant bits if needed)
  uint8_t value = (uint8_t)TEST_WRITE_VALUE;
  iob_uart16550_csrs_set_mcr(value);

  return TEST_PASSED;
}

int test_functionality_lsr_read() {
  iob_uart16550_csrs_get_lsr();
  return TEST_PASSED;
}

int test_functionality_msr_read() {
  iob_uart16550_csrs_get_msr();
  return TEST_PASSED;
}

int test_functionality_version_read() {
  iob_uart16550_csrs_get_version();
  return TEST_PASSED;
}

//
// Error handling tests
//

#if defined(DEV_IF)
int test_error_concurrent_open() {
  /*
   * Test concurrent open calls to the device file.
   * This test is for the dev interface.
   */
  int fd1 = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd1 == -1) {
    perror("open");
    return TEST_FAILED;
  }

  int fd2 = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd2 != -1 || errno != EBUSY) {
    printf("Error: Second open should fail with EBUSY\n");
    if (fd2 != -1) {
      close(fd2);
    }
    close(fd1);
    return TEST_FAILED;
  }

  close(fd1);
  return TEST_PASSED;
}

int test_error_invalid_read() {
  /*
   * Test invalid read calls to the device file.
   * This test is for the dev interface.
   */
  int fd = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd == -1) {
    perror("open");
    return TEST_FAILED;
  }

  char buf;
#if defined(IOB_UART16550_CSRS_MCR_ADDR)
  lseek(fd, IOB_UART16550_CSRS_MCR_ADDR, SEEK_SET); // Seek to a write-only CSR
#else
  lseek(fd, 0xff, SEEK_SET); // Seek to an invalid address
#endif
  if (read(fd, &buf, 1) != -1 || errno != EACCES) {
    printf("Error: Invalid read should fail with EACCES\n");
    close(fd);
    return TEST_FAILED;
  }

  close(fd);
  return TEST_PASSED;
}

int test_error_invalid_write() {
  /*
   * Test invalid write calls to the device file.
   * This test is for the dev interface.
   */
  int fd = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd == -1) {
    perror("open");
    return TEST_FAILED;
  }

  char buf = 0;
  lseek(fd, IOB_UART16550_CSRS_VERSION_ADDR,
        SEEK_SET); // Seek to a read-only CSR
  if (write(fd, &buf, 1) != -1 || errno != EACCES) {
    printf("Error: Invalid write should fail with EACCES\n");
    close(fd);
    return TEST_FAILED;
  }

  close(fd);
  return TEST_PASSED;
}

int test_error_invalid_llseek() {
  /*
   * Test invalid llseek calls to the device file.
   * This test is for the dev interface.
   */
  int fd = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd == -1) {
    perror("open");
    return TEST_FAILED;
  }

  if (lseek(fd, 0, -1) != -1 || errno != EINVAL) {
    printf("Error: Invalid llseek should fail with EINVAL\n");
    close(fd);
    return TEST_FAILED;
  }

  close(fd);
  return TEST_PASSED;
}

#elif defined(IOCTL_IF)
int test_error_invalid_ioctl() {
  /*
   * Test invalid ioctl calls to the device file.
   * This test is for the ioctl interface.
   */
  int fd = open(IOB_UART16550_DEVICE_FILE, O_RDWR);
  if (fd == -1) {
    perror("open");
    return TEST_FAILED;
  }

  if (ioctl(fd, -1, NULL) == 0 || errno != ENOTTY) {
    printf("Error: Invalid ioctl should fail with ENOTTY. Errno: %d\n", errno);
    close(fd);
    return TEST_FAILED;
  }

  close(fd);
  return TEST_PASSED;
}

#elif defined(SYSFS_IF)
int test_error_sysfs_write_to_readonly() {
  /*
   * Test writing to a read-only sysfs file.
   * This test is for the sysfs interface.
   */
  char file_path[128];
  sprintf(file_path, "/sys/class/iob_uart16550/iob_uart16550/version");
  int fd = open(file_path, O_WRONLY);
  if (fd != -1 || errno != EACCES) {
    printf("Error: Opening a read-only sysfs file for writing should fail with "
           "EACCES.\n");
    if (fd != -1) {
      close(fd);
    }
    return TEST_FAILED;
  }
  return TEST_PASSED;
}

int test_error_sysfs_read_from_nonexistent() {
  /*
   * Test reading from a non-existent sysfs file.
   * This test is for the sysfs interface.
   */
  char file_path[128];
  sprintf(file_path, "/sys/class/iob_uart16550/iob_uart16550/nonexistent");
  int fd = open(file_path, O_RDONLY);
  if (fd != -1 || errno != ENOENT) {
    printf("Error: Opening a non-existent sysfs file for reading should fail "
           "with ENOENT.\n");
    if (fd != -1) {
      close(fd);
    }
    return TEST_FAILED;
  }
  return TEST_PASSED;
}

int test_error_sysfs_write_invalid_value() {
  /*
   * Test writing an invalid value to a sysfs file.
   * This test is for the sysfs interface.
   */
  char file_path[128];
  sprintf(file_path, "/sys/class/iob_uart16550/iob_uart16550/rbr_thr_dll");
  int fd = open(file_path, O_WRONLY);
  if (fd == -1) {
    perror("open");
    return TEST_FAILED;
  }
  if (write(fd, "invalid", 7) != -1 || errno != EINVAL) {
    printf("Error: Writing an invalid value to a sysfs file should fail with "
           "EINVAL.\n");
    close(fd);
    return TEST_FAILED;
  }
  close(fd);
  return TEST_PASSED;
}
#endif // SYSFS_IF

//
// Performance tests
//

int test_performance_rbr_thr_dll_read() {
  const int num_iterations = 100;
  struct timespec start, end;
  double total_time = 0;

  clock_gettime(CLOCK_MONOTONIC, &start);
  for (int i = 0; i < num_iterations; i++) {
    iob_uart16550_csrs_get_rbr_thr_dll();
  }
  clock_gettime(CLOCK_MONOTONIC, &end);

  total_time =
      (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
  printf("Read performance for rbr_thr_dll: %f seconds for %d iterations\n",
         total_time, num_iterations);

  return TEST_PASSED;
}

int test_performance_rbr_thr_dll_write() {
  const int num_iterations = 100;
  struct timespec start, end;
  double total_time = 0;

  clock_gettime(CLOCK_MONOTONIC, &start);
  for (int i = 0; i < num_iterations; i++) {
    iob_uart16550_csrs_set_rbr_thr_dll(i);
  }
  clock_gettime(CLOCK_MONOTONIC, &end);

  total_time =
      (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
  printf("Write performance for rbr_thr_dll: %f seconds for %d iterations\n",
         total_time, num_iterations);

  return TEST_PASSED;
}

int main() {
  // Run error handling tests that manage their own file descriptors first
#if defined(DEV_IF)
  RUN_TEST(test_error_concurrent_open);

  RUN_TEST(test_error_invalid_read);

  RUN_TEST(test_error_invalid_write);
  RUN_TEST(test_error_invalid_llseek);
#elif defined(IOCTL_IF)
  RUN_TEST(test_error_invalid_ioctl);
#endif

  // Initialize global file descriptor for remaining tests
  iob_uart16550_csrs_init_baseaddr(0);

  printf("\n[User] Version: 0x%x\n", iob_uart16550_csrs_get_version());

  // Run functionality tests

  RUN_TEST(test_functionality_rbr_thr_dll_write);
  RUN_TEST(test_functionality_rbr_thr_dll_read);
  RUN_TEST(test_functionality_ier_dlm_write);
  RUN_TEST(test_functionality_ier_dlm_read);
  RUN_TEST(test_functionality_iir_fcr_write);
  RUN_TEST(test_functionality_iir_fcr_read);
  RUN_TEST(test_functionality_lcr_write);
  RUN_TEST(test_functionality_lcr_read);
  RUN_TEST(test_functionality_mcr_write);
  RUN_TEST(test_functionality_lsr_read);
  RUN_TEST(test_functionality_msr_read);
  RUN_TEST(test_functionality_version_read);
  // Run SYSFS error tests
#if defined(SYSFS_IF)
  RUN_TEST(test_error_sysfs_write_to_readonly);
  RUN_TEST(test_error_sysfs_read_from_nonexistent);

  RUN_TEST(test_error_sysfs_write_invalid_value);

#endif

  // Run performance tests

  RUN_TEST(test_performance_rbr_thr_dll_write);
  RUN_TEST(test_performance_rbr_thr_dll_read);
  printf("All tests passed!\n");
}
