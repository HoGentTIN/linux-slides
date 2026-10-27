---
title: "Mounting filesystems"
subtitle: "Linux"
author: "HOGENT toegepaste informatica"
date: "2026-2027"
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

## Partition table

Every disk with Master Boot Record (**MBR**) partition table can have:

- maximum 4 primary/extended partitions
- one extended partition can host further logical (sub)partitions

| Partition Type   | naming |
| :--------------- | :----- |
| Primary (max 4)  | 1-4    |
| Extended (max 1) | 1-4    |
| Logical          | 5-     |

**GPT** (Globally Unique Identifier Partition Table) is the successor of MBR and has no such limitations.

## lsblk

Show block devices and their partitions

```console
$ lsblk -f
NAME    FSTYPE FSVER LABEL UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
sda                                                                            
├─sda1  ext4   1.0         df4df5bb-613a-4382-8cf9-653304605a1f    3.3G    62% /
├─sda14                                                                        
└─sda15 vfat   FAT16       6EA5-B51D                             114.8M     7% /boot/efi
```

## fdisk

Display and modify partitions of a disk.

```console
$ sudo fdisk -l /dev/sda
Disk /dev/sda: 10 GiB, 10737418240 bytes, 20971520 sectors
Disk model: HARDDISK        
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 97AF9C2E-CA04-4A3C-BCE2-24A66EFB4208

Device      Start      End  Sectors  Size Type
/dev/sda1  262144 20971486 20709343  9.9G Linux root (x86-64)
/dev/sda14   2048     8191     6144    3M BIOS boot
/dev/sda15   8192   262143   253952  124M EFI System

Partition table entries are not in disk order.
```

## Common file systems on Linux

- ext2 - "original" ext file system, no journaling, deprecated
- ext3, ext4 - evolution of ext2, with journaling
- btrfs - focus on modern features, lower performance
- xfs - journaling, large files, default on EL

## Other notable file systems

- bcachefs - features + performance, no kernel support
- exfat - for flash drives, SD cards
- hfs, hfs+ - Mac file systems
- iso9660 - for CD/DVD
- vfat, ntfs - Windows file systems
- zfs - BSD licensed, features + performance

## Formating a partition

`mkfs` = MaKe FileSystem

```console
$ sudo mkfs -t ext4 /dev/sdb1
mke2fs 1.47.2 (1-Jan-2025)
Creating filesystem with 488192 4k blocks and 122160 inodes
Filesystem UUID: 8587ac09-73d2-4f7b-a3ab-dd9cc08737d4
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done 
```

(tip: try `ls /sbin/mk*` to see currently supported file systems)

## Changing defaults of a file system

Every partition has e.g. reserved blocks for root user only:

```console
$ sudo tune2fs -l /dev/sdb1 | grep -i 'block count'
Block count:              488192
Reserved block count:     24409
```

(only works for ext3/ext4)

---

Update with `tune2fs`
e.g. reduce to 3% reserved blocks

```console
$ sudo tune2fs -m3 /dev/sdb1
tune2fs 1.47.2 (1-Jan-2025)
Setting reserved blocks percentage to 3% (14645 blocks)
$ sudo tune2fs -l /dev/sdb1 | grep -i 'block count'
Block count:              488192
Reserved block count:     14645
```

# Mount

## Manual mount

mount = Making a partition available in the file tree

```console
$ sudo mkdir /mnt/newmountpoint
$ sudo mount /dev/sdb1 /mnt/newmountpoint/
```

Display mount points

```console
$ findmnt --real
TARGET               SOURCE     FSTYPE OPTIONS
/                    /dev/sda1  ext4   rw,relatime,discard,errors=remount-ro
├─/boot/efi          /dev/sda15 vfat   rw,relatime,fmask=0077,dmask=0077,...
└─/mnt/newmountpoint /dev/sdb1  ext4   rw,relatime
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

- ro - read-only
- rw - read-write
- remount - mount an already mounted device with new options

```console
$ mount | grep boot 
/dev/sda2 on /boot type ext4 (rw,relatime)
$ sudo mount -o remount,ro /boot/
$ mount | grep boot 
/dev/sda2 on /boot type ext4 (ro,relatime)
```

# UUID

## Universally Unique IDentifier

- e.g. `8587ac09-73d2-4f7b-a3ab-dd9cc08737d4`
- 128 bits
- generated while formatting

## lookup UUID

```console
$ blkid /dev/sda2
/dev/sda2: UUID="fd5db924-4be6-4fee-9a92-ca9db8fe2b9c" TYPE="ext4" PARTUUID="97584a69-02"
$ sudo tune2fs -l /dev/sda2 | grep UUID
Filesystem UUID:          fd5db924-4be6-4fee-9a92-ca9db8fe2b9c
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
