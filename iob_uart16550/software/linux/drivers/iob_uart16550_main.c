/*
 * SPDX-FileCopyrightText: 2025 IObundle
 *
 * SPDX-License-Identifier: MIT
 */

/* iob_uart16550_main.c: driver for iob_uart16550
 * using device platform. No hardcoded hardware address:
 * 1. load driver: insmod iob_uart16550.ko
 * 2. run user app: ./user/user
 */

#include <linux/cdev.h>
#include <linux/fs.h>
#include <linux/io.h>
#include <linux/ioport.h>
#include <linux/kernel.h>
#include <linux/mod_devicetable.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/uaccess.h>

#include <linux/ioctl.h>

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

#include "iob_class/iob_class_utils.h"
#include "iob_uart16550_driver_files.h"

static int iob_uart16550_probe(struct platform_device *);
static int iob_uart16550_remove(struct platform_device *);

static ssize_t iob_uart16550_read(struct file *, char __user *, size_t,
                                  loff_t *);
static ssize_t iob_uart16550_write(struct file *, const char __user *, size_t,
                                   loff_t *);
static loff_t iob_uart16550_llseek(struct file *, loff_t, int);
static int iob_uart16550_open(struct inode *, struct file *);
static int iob_uart16550_release(struct inode *, struct file *);

static long iob_uart16550_ioctl(struct file *, unsigned int, unsigned long);

static struct iob_data iob_uart16550_data = {0};
DEFINE_MUTEX(iob_uart16550_mutex);

#include "iob_uart16550_sysfs.h"

static const struct file_operations iob_uart16550_fops = {
    .owner = THIS_MODULE,
    .write = iob_uart16550_write,
    .read = iob_uart16550_read,
    .llseek = iob_uart16550_llseek,
    .unlocked_ioctl = iob_uart16550_ioctl,
    .open = iob_uart16550_open,
    .release = iob_uart16550_release,
};

static const struct of_device_id of_iob_uart16550_match[] = {
    {.compatible = "iobundle,uart165500"},
    {},
};

static struct platform_driver iob_uart16550_driver = {
    .driver =
        {
            .name = "iob_uart16550",
            .owner = THIS_MODULE,
            .of_match_table = of_iob_uart16550_match,
        },
    .probe = iob_uart16550_probe,
    .remove = iob_uart16550_remove,
};

//
// Module init and exit functions
//
static int iob_uart16550_probe(struct platform_device *pdev) {
  struct resource *res;
  int result = 0;

  if (iob_uart16550_data.device != NULL) {
    pr_err("[Driver] %s: No more devices allowed!\n",
           IOB_UART16550_DRIVER_NAME);

    return -ENODEV;
  }

  pr_info("[iob_uart16550] %s: probing.\n", IOB_UART16550_DRIVER_NAME);

  // Get the I/O region base address
  res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
  if (!res) {
    pr_err("[Driver]: Failed to get I/O resource!\n");
    result = -ENODEV;
    goto r_get_resource;
  }

  // Request and map the I/O region
  iob_uart16550_data.regbase = devm_ioremap_resource(&pdev->dev, res);
  if (IS_ERR(iob_uart16550_data.regbase)) {
    result = PTR_ERR(iob_uart16550_data.regbase);
    goto r_ioremmap;
  }
  iob_uart16550_data.regsize = resource_size(res);

  // Allocate char device
  result = alloc_chrdev_region(&iob_uart16550_data.devnum, 0, 1,
                               IOB_UART16550_DRIVER_NAME);
  if (result) {
    pr_err("%s: Failed to allocate device number!\n",
           IOB_UART16550_DRIVER_NAME);
    goto r_alloc_region;
  }

  cdev_init(&iob_uart16550_data.cdev, &iob_uart16550_fops);

  result = cdev_add(&iob_uart16550_data.cdev, iob_uart16550_data.devnum, 1);
  if (result) {
    pr_err("%s: Char device registration failed!\n", IOB_UART16550_DRIVER_NAME);
    goto r_cdev_add;
  }

  // Create device class // todo: make a dummy driver just to create and own the
  // class: https://stackoverflow.com/a/16365027/8228163
  if ((iob_uart16550_data.class =
           class_create(THIS_MODULE, IOB_UART16550_DRIVER_CLASS)) == NULL) {
    printk("Device class can not be created!\n");
    goto r_class;
  }

  // Create device file
  iob_uart16550_data.device =
      device_create(iob_uart16550_data.class, NULL, iob_uart16550_data.devnum,
                    NULL, IOB_UART16550_DRIVER_NAME);
  if (iob_uart16550_data.device == NULL) {
    printk("Can not create device file!\n");
    goto r_device;
  }

  result = iob_uart16550_create_device_attr_files(iob_uart16550_data.device);
  if (result) {
    pr_err("Cannot create device attribute file......\n");
    goto r_dev_file;
  }

  dev_info(&pdev->dev, "initialized.\n");
  goto r_ok;

r_dev_file:
  iob_uart16550_remove_device_attr_files(&iob_uart16550_data);
r_device:
  class_destroy(iob_uart16550_data.class);
r_class:
  cdev_del(&iob_uart16550_data.cdev);
r_cdev_add:
  unregister_chrdev_region(iob_uart16550_data.devnum, 1);
r_alloc_region:
  // iounmap is managed by devm
r_ioremmap:
r_get_resource:
r_ok:

  return result;
}

static int iob_uart16550_remove(struct platform_device *pdev) {
  iob_uart16550_remove_device_attr_files(&iob_uart16550_data);
  class_destroy(iob_uart16550_data.class);
  cdev_del(&iob_uart16550_data.cdev);
  unregister_chrdev_region(iob_uart16550_data.devnum, 1);
  // Note: no need for iounmap, since we are using devm_ioremap_resource()

  dev_info(&pdev->dev, "exiting.\n");

  return 0;
}

static int __init iob_uart16550_init(void) {
  pr_info("[iob_uart16550] %s: initializing.\n", IOB_UART16550_DRIVER_NAME);

  return platform_driver_register(&iob_uart16550_driver);
}

static void __exit iob_uart16550_exit(void) {
  pr_info("[iob_uart16550] %s: exiting.\n", IOB_UART16550_DRIVER_NAME);
  platform_driver_unregister(&iob_uart16550_driver);
}

//
// File operations
//

static int iob_uart16550_open(struct inode *inode, struct file *file) {
  pr_info("[iob_uart16550] Device opened\n");

  if (!mutex_trylock(&iob_uart16550_mutex)) {
    pr_info("[iob_uart16550] Another process is accessing the device\n");

    return -EBUSY;
  }

  return 0;
}

static int iob_uart16550_release(struct inode *inode, struct file *file) {
  pr_info("[iob_uart16550] Device closed\n");

  mutex_unlock(&iob_uart16550_mutex);

  return 0;
}

static ssize_t iob_uart16550_read(struct file *file, char __user *buf,
                                  size_t count, loff_t *ppos) {
  int size = 0;
  u32 value = 0;

  /* read value from register */
  switch (*ppos) {
  case IOB_UART16550_CSRS_RBR_THR_DLL_ADDR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_RBR_THR_DLL_ADDR,
                              IOB_UART16550_CSRS_RBR_THR_DLL_W);
    size = (IOB_UART16550_CSRS_RBR_THR_DLL_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] Dev - Read rbr_thr_dll: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_IER_DLM_ADDR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_IER_DLM_ADDR,
                              IOB_UART16550_CSRS_IER_DLM_W);
    size = (IOB_UART16550_CSRS_IER_DLM_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] Dev - Read ier_dlm: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_IIR_FCR_ADDR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_IIR_FCR_ADDR,
                              IOB_UART16550_CSRS_IIR_FCR_W);
    size = (IOB_UART16550_CSRS_IIR_FCR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] Dev - Read iir_fcr: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_LCR_ADDR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_LCR_ADDR,
                              IOB_UART16550_CSRS_LCR_W);
    size = (IOB_UART16550_CSRS_LCR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] Dev - Read lcr: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_LSR_ADDR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_LSR_ADDR,
                              IOB_UART16550_CSRS_LSR_W);
    size = (IOB_UART16550_CSRS_LSR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] Dev - Read lsr: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_MSR_ADDR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_MSR_ADDR,
                              IOB_UART16550_CSRS_MSR_W);
    size = (IOB_UART16550_CSRS_MSR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] Dev - Read msr: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_VERSION_ADDR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_VERSION_ADDR,
                              IOB_UART16550_CSRS_VERSION_W);
    size = (IOB_UART16550_CSRS_VERSION_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] Dev - Read version: 0x%x\n", value);
    break;
  default:
    // invalid address - no bytes read
    return -EACCES;
  }

  // Read min between count and REG_SIZE
  if (size > count)
    size = count;

  if (copy_to_user(buf, &value, size))
    return -EFAULT;

  return count;
}

static ssize_t iob_uart16550_write(struct file *file, const char __user *buf,
                                   size_t count, loff_t *ppos) {
  int size = 0;
  u32 value = 0;

  switch (*ppos) {
  case IOB_UART16550_CSRS_RBR_THR_DLL_ADDR:
    size = (IOB_UART16550_CSRS_RBR_THR_DLL_W >> 3); // bit to bytes
    if (count != size) {
      pr_info("[iob_uart16550] write size %d for rbr_thr_dll CSR is not equal "
              "to register size %d\n",
              (int)count, size);
      return -EACCES;
    }
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_RBR_THR_DLL_ADDR,
                       IOB_UART16550_CSRS_RBR_THR_DLL_W);
    pr_info("[iob_uart16550] Dev - Write rbr_thr_dll: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_IER_DLM_ADDR:
    size = (IOB_UART16550_CSRS_IER_DLM_W >> 3); // bit to bytes
    if (count != size) {
      pr_info("[iob_uart16550] write size %d for ier_dlm CSR is not equal to "
              "register size %d\n",
              (int)count, size);
      return -EACCES;
    }
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_IER_DLM_ADDR,
                       IOB_UART16550_CSRS_IER_DLM_W);
    pr_info("[iob_uart16550] Dev - Write ier_dlm: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_IIR_FCR_ADDR:
    size = (IOB_UART16550_CSRS_IIR_FCR_W >> 3); // bit to bytes
    if (count != size) {
      pr_info("[iob_uart16550] write size %d for iir_fcr CSR is not equal to "
              "register size %d\n",
              (int)count, size);
      return -EACCES;
    }
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_IIR_FCR_ADDR,
                       IOB_UART16550_CSRS_IIR_FCR_W);
    pr_info("[iob_uart16550] Dev - Write iir_fcr: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_LCR_ADDR:
    size = (IOB_UART16550_CSRS_LCR_W >> 3); // bit to bytes
    if (count != size) {
      pr_info("[iob_uart16550] write size %d for lcr CSR is not equal to "
              "register size %d\n",
              (int)count, size);
      return -EACCES;
    }
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_LCR_ADDR, IOB_UART16550_CSRS_LCR_W);
    pr_info("[iob_uart16550] Dev - Write lcr: 0x%x\n", value);
    break;
  case IOB_UART16550_CSRS_MCR_ADDR:
    size = (IOB_UART16550_CSRS_MCR_W >> 3); // bit to bytes
    if (count != size) {
      pr_info("[iob_uart16550] write size %d for mcr CSR is not equal to "
              "register size %d\n",
              (int)count, size);
      return -EACCES;
    }
    if (read_user_data(buf, size, &value))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_MCR_ADDR, IOB_UART16550_CSRS_MCR_W);
    pr_info("[iob_uart16550] Dev - Write mcr: 0x%x\n", value);
    break;
  default:
    pr_info("[iob_uart16550] Invalid write address 0x%x\n",
            (unsigned int)*ppos);
    // invalid address - no bytes written
    return -EACCES;
  }

  return count;
}

/* Custom lseek function
 * check: lseek(2) man page for whence modes
 */
static loff_t iob_uart16550_llseek(struct file *filp, loff_t offset,
                                   int whence) {
  loff_t new_pos = -1;

  switch (whence) {
  case SEEK_SET:
    new_pos = offset;
    break;
  case SEEK_CUR:
    new_pos = filp->f_pos + offset;
    break;
  case SEEK_END:
    new_pos = (1 << IOB_UART16550_CSRS_ADDR_W) + offset;
    break;
  default:
    return -EINVAL;
  }

  // Check for valid bounds
  if (new_pos < 0 || new_pos > iob_uart16550_data.regsize) {
    return -EINVAL;
  }

  // Update file position
  filp->f_pos = new_pos;

  return new_pos;
}

/* IOCTL function
 * This function will be called when we write IOCTL on the Device file
 */
static long iob_uart16550_ioctl(struct file *file, unsigned int cmd,
                                unsigned long arg) {
  int size = 0;
  u32 value = 0;

  switch (cmd) {
  case WR_RBR_THR_DLL:
    size = (IOB_UART16550_CSRS_RBR_THR_DLL_W >> 3); // bit to bytes
    if (copy_from_user(&value, (int32_t *)arg, size))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_RBR_THR_DLL_ADDR,
                       IOB_UART16550_CSRS_RBR_THR_DLL_W);
    pr_info("[iob_uart16550] IOCTL - Write rbr_thr_dll: 0x%x\n", value);

    break;
  case RD_RBR_THR_DLL:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_RBR_THR_DLL_ADDR,
                              IOB_UART16550_CSRS_RBR_THR_DLL_W);
    size = (IOB_UART16550_CSRS_RBR_THR_DLL_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] IOCTL - Read rbr_thr_dll: 0x%x\n", value);

    if (copy_to_user((int32_t *)arg, &value, size))
      return -EFAULT;

    break;
  case WR_IER_DLM:
    size = (IOB_UART16550_CSRS_IER_DLM_W >> 3); // bit to bytes
    if (copy_from_user(&value, (int32_t *)arg, size))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_IER_DLM_ADDR,
                       IOB_UART16550_CSRS_IER_DLM_W);
    pr_info("[iob_uart16550] IOCTL - Write ier_dlm: 0x%x\n", value);

    break;
  case RD_IER_DLM:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_IER_DLM_ADDR,
                              IOB_UART16550_CSRS_IER_DLM_W);
    size = (IOB_UART16550_CSRS_IER_DLM_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] IOCTL - Read ier_dlm: 0x%x\n", value);

    if (copy_to_user((int32_t *)arg, &value, size))
      return -EFAULT;

    break;
  case WR_IIR_FCR:
    size = (IOB_UART16550_CSRS_IIR_FCR_W >> 3); // bit to bytes
    if (copy_from_user(&value, (int32_t *)arg, size))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_IIR_FCR_ADDR,
                       IOB_UART16550_CSRS_IIR_FCR_W);
    pr_info("[iob_uart16550] IOCTL - Write iir_fcr: 0x%x\n", value);

    break;
  case RD_IIR_FCR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_IIR_FCR_ADDR,
                              IOB_UART16550_CSRS_IIR_FCR_W);
    size = (IOB_UART16550_CSRS_IIR_FCR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] IOCTL - Read iir_fcr: 0x%x\n", value);

    if (copy_to_user((int32_t *)arg, &value, size))
      return -EFAULT;

    break;
  case WR_LCR:
    size = (IOB_UART16550_CSRS_LCR_W >> 3); // bit to bytes
    if (copy_from_user(&value, (int32_t *)arg, size))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_LCR_ADDR, IOB_UART16550_CSRS_LCR_W);
    pr_info("[iob_uart16550] IOCTL - Write lcr: 0x%x\n", value);

    break;
  case RD_LCR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_LCR_ADDR,
                              IOB_UART16550_CSRS_LCR_W);
    size = (IOB_UART16550_CSRS_LCR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] IOCTL - Read lcr: 0x%x\n", value);

    if (copy_to_user((int32_t *)arg, &value, size))
      return -EFAULT;

    break;
  case WR_MCR:
    size = (IOB_UART16550_CSRS_MCR_W >> 3); // bit to bytes
    if (copy_from_user(&value, (int32_t *)arg, size))
      return -EFAULT;
    iob_data_write_reg(iob_uart16550_data.regbase, value,
                       IOB_UART16550_CSRS_MCR_ADDR, IOB_UART16550_CSRS_MCR_W);
    pr_info("[iob_uart16550] IOCTL - Write mcr: 0x%x\n", value);

    break;
  case RD_LSR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_LSR_ADDR,
                              IOB_UART16550_CSRS_LSR_W);
    size = (IOB_UART16550_CSRS_LSR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] IOCTL - Read lsr: 0x%x\n", value);

    if (copy_to_user((int32_t *)arg, &value, size))
      return -EFAULT;

    break;
  case RD_MSR:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_MSR_ADDR,
                              IOB_UART16550_CSRS_MSR_W);
    size = (IOB_UART16550_CSRS_MSR_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] IOCTL - Read msr: 0x%x\n", value);

    if (copy_to_user((int32_t *)arg, &value, size))
      return -EFAULT;

    break;
  case RD_VERSION:
    value = iob_data_read_reg(iob_uart16550_data.regbase,
                              IOB_UART16550_CSRS_VERSION_ADDR,
                              IOB_UART16550_CSRS_VERSION_W);
    size = (IOB_UART16550_CSRS_VERSION_W >> 3); // bit to bytes
    pr_info("[iob_uart16550] IOCTL - Read version: 0x%x\n", value);

    if (copy_to_user((int32_t *)arg, &value, size))
      return -EFAULT;

    break;
  default:
    pr_info("[iob_uart16550] Invalid IOCTL command 0x%x\n", cmd);
    return -ENOTTY;
  }
  return 0;
}

module_init(iob_uart16550_init);
module_exit(iob_uart16550_exit);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("IObundle");
MODULE_DESCRIPTION("iob_uart16550 Drivers");
MODULE_VERSION("0.1.5");
