#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/io.h>
#include <linux/mm.h>
#include <linux/slab.h>
#include <linux/device/class.h>
#include <linux/device.h>
#include <asm/csr.h>

#define DEVICE_NAME "disable_sche"
#define IOCTL_SET_PHYS_ADDR _IOW('p', 1, unsigned long)
int timer_enter_print;
static int major;
static struct class *cls;

static int device_open(struct inode *inode, struct file *file)
{
	return 0;
}

static int device_release(struct inode *inode, struct file *file)
{
	return 0;
}

static long device_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	csr_set(CSR_SIE, 0);
	csr_set(CSR_IP, 0);
	timer_enter_print = 1;
	pr_err("disable timer interrupt\n");
	return 0;
}

static int device_mmap(struct file *file, struct vm_area_struct *vma)
{
	return 0;
}

static struct file_operations fops = {
	.owner = THIS_MODULE,
	.open = device_open,
	.release = device_release,
	.unlocked_ioctl = device_ioctl,
	.mmap = device_mmap,
};

static int __init disable_sche_init(void)
{
	pr_err("init disable scheduler module\n");
	major = register_chrdev(0, DEVICE_NAME, &fops);
	if (major < 0) {
		printk(KERN_ALERT "Failed to register character device\n");
		return major;
	}

	cls = class_create(DEVICE_NAME);
	device_create(cls, NULL, MKDEV(major, 0), NULL, DEVICE_NAME);
	pr_err("phys_mem device registered with major number %d\n", major);

	return 0;
}

static void __exit disable_sche_exit(void)
{
	device_destroy(cls, MKDEV(major, 0));
	class_destroy(cls);
	unregister_chrdev(major, DEVICE_NAME);

	printk(KERN_INFO "phys_mem device unregistered\n");
}

module_init(disable_sche_init);
module_exit(disable_sche_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("tingzhu.wang@sophgo.com");
MODULE_DESCRIPTION("a simple device driver for mapping physical memory to user space");
