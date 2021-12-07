---
title: "9. Mount"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Pre knowledge

## Pre knowledge

Disk devices and partitions have already surfaced in other courses.
We briefly depict how you can explore these devices on Linux

## Disk devices

Sata disks devices:

```console
$ ls /dev/sd*
/dev/sda	/dev/sdb
```

## Disk partitions

Every disk:

* maximum 4 primary/extended partitions
* one extended partition can host further logical (sub)partitions

| Partition Type   | naming |
| :--------------- | :----- |
| Primary (max 4)  | 1-4    |
| Extended (max 1) | 1-4    |
| Logical          | 5-     |

## fdisk

Display and modify partitions of a disk.

```console
$ sudo fdisk -l 
Disk /dev/sda: 64 GiB, 68719476736 bytes, 134217728 sectors
[...]

Device     Boot   Start       End   Sectors  Size Id Type
/dev/sda1          2048   4501503   4499456  2.1G 82 Linux swap / Solaris
/dev/sda2  *    4501504 134217727 129716224 61.9G 83 Linux
```

## File systems

Linux file systems (common):

* ext2
* ext3 - with journaling
* ext4 - latest version, with journaling
* xfs

Other file systems:

* vfat
* ntfs
* iso9660

## Formating a partition

mkfs = MaKe FileSystem

```console
$ sudo mkfs -t ext3 /dev/sdb3
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 244224 4k blocks and 61056 inodes
Filesystem UUID: 396d698d-eac6-44f3-9b95-34db7d461664
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done
```

## Changing defaults of a file system

Every partition has e.g. reserved blocks for root user only:

```console
$ sudo tune2fs -l /dev/sdb3 | grep -i "block count"
Block count:              104388
Reserved block count:     5219
```

---

Update with `tune2fs`
e.g. reduce to 3% reserved blocks

```console
$ sudo tune2fs -m3 /dev/sdb3 "
tune2fs 1.45 (Jan-2020)
Setting reserved blocks percentage to 3 (3131 blocks)
```

# Mount

## Manual mount

mount = Making a partition available in the file tree

1. make a mount point ~ a mount directory, e.g.

    ```console
    $ sudo mkdir /mnt/newmountpoint
    ```

2. bind the partition to the mount point

    ```console
    $ sudo mount -t ext3 /dev/sdb3 /mnt/newmountpoint
    ```

## Display mount points

```console
$ mount | grep sd
/dev/sda1 on / type ext4 (rw,relatime,errors=remount-ro)
/dev/sda4 on /home type ext4 (rw,relatime)
```

## Permanent mounts

Partitions which will be mounted at boot: `/etc/fstab`

```console
$ cat /etc/fstab
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/sda1 			/               ext4    errors=remount-ro 0       1
/dev/sda2 			/boot           ext4    defaults        0       2
/dev/sda4 			/home           ext4    defaults        0       2
/dev/sda3 			none            swap    sw              0       0
```

## Mount options

Mount has some useful options:

* ro - read-only
* rw - read-write
* remount - mount an already mounted device with new options

```console
$ mount | grep boot 
/dev/sda2 on /boot type ext4 (rw,relatime)
$ sudo mount -o remount,ro /boot/
$ mount | grep boot 
/dev/sda2 on /boot type ext4 (ro,relatime)
```

# UUID

## UUID def

UUID = universally unique identifier

* 128 bits
* generated while formating

## lookup UUID

```console
$ sudo tune2fs -l /dev/sda2 | grep UUID
Filesystem UUID:          fd5db924-4be6-4fee-9a92-ca9db8fe2b9c
$ blkid /dev/sda2
/dev/sda2: UUID="fd5db924-4be6-4fee-9a92-ca9db8fe2b9c" TYPE="ext4" PARTUUID="97584a69-02"
```

## fstab with UUID

unique indication of partition in case e.g. sda and sdb get switched when booting

```console
$ cat /etc/fstab
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sda1 during installation
UUID=757350f2-9cb2-4ce5-86bc-4528dfe9d9ac /               ext4    errors=remount-ro 0       1
# /boot was on /dev/sda2 during installation
UUID=fd5db924-4be6-4fee-9a92-ca9db8fe2b9c /boot           ext4    defaults        0       2
# /home was on /dev/sda4 during installation
UUID=502c37ca-255c-4a38-9294-9802a5fb5941 /home           ext4    defaults        0       2
# swap was on /dev/sda3 during installation
UUID=b559d746-ef9d-45bc-acfb-faa036b3418f none            swap    sw              0       0
```
