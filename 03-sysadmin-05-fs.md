**2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?**  
Нет, потому что жесткие ссылки указывает на один объект, а у него может быть только один набор прав  

**4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.**  
```
$sudo fdisk /dev/sdb
g
n
1
2048
+2G
n
2
4196352
5242846
$
$ sudo fdisk -l /dev/sdb
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: A1FA38F2-2FF8-3E45-ACF1-E83E90D1BD19

Device       Start     End Sectors  Size Type
/dev/sdb1     2048 4196351 4194304    2G Linux filesystem
/dev/sdb2  4196352 5242846 1046495  511M Linux filesystem
```

**5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.**  
```
$ sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc
$
$ sudo fdisk -l /dev/sdc
Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: A1FA38F2-2FF8-3E45-ACF1-E83E90D1BD19

Device       Start     End Sectors  Size Type
/dev/sdc1     2048 4196351 4194304    2G Linux filesystem
/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem
```

**6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.**  
```
$ sudo mdadm -C /dev/md0 -l 1 -n 2 /dev/sdb1 /dev/sdc1
$ sudo mdadm /dev/md0
/dev/md0: 2045.00MiB raid1 2 devices, 0 spares. Use mdadm --detail for more detail.
```
**7. Соберите `mdadm` RAID0 на второй паре маленьких разделов. **  
```
$ sudo mdadm -C /dev/md1 -l 0 -n 2 /dev/sdb2 /dev/sdc2
$ sudo mdadm /dev/md1
/dev/md1: 1017.00MiB raid0 2 devices, 0 spares. Use mdadm --detail for more detail.
```
**8. Создайте 2 независимых PV на получившихся md-устройствах.**  
```
$ sudo pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
$ sudo pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
$ sudo pvs
  PV         VG        Fmt  Attr PSize    PFree
  /dev/md0             lvm2 ---    <2.00g   <2.00g
  /dev/md1             lvm2 ---  1017.00m 1017.00m
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0
```
**9. Создайте общую volume-group на этих двух PV.**  
```
$ sudo vgcreate vgnetology /dev/md0 /dev/md1
  Volume group "vgnetology" successfully created
$ sudo vgs
  VG         #PV #LV #SN Attr   VSize   VFree
  vgnetology   2   0   0 wz--n-  <2.99g <2.99g
  vgvagrant    1   2   0 wz--n- <63.50g     0
```

**10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.**  
```
$ sudo lvcreate -L 100M -n lv1 vgnetology /dev/md1
  Logical volume "lv1" created.
$ sudo lvs -o +devices
  LV     VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices
  lv1    vgnetology -wi-a----- 100.00m                                                     /dev/md1(0)
  root   vgvagrant  -wi-ao---- <62.54g                                                     /dev/sda5(0)
  swap_1 vgvagrant  -wi-ao---- 980.00m                                                     /dev/sda5(16010)
```

**11. Создайте `mkfs.ext4` ФС на получившемся LV.**  
```
$ sudo mkfs.ext4 /dev/vgnetology/lv1
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```

**12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.**
```
$ mkdir /tmp/new
$ sudo mount /dev/vgnetology//lv1 /tmp/new
```

**13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.**  
```
wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
```

**14. Прикрепите вывод `lsblk`.**  
```
$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1017M  0 raid0
    └─vgnetology-lv1 253:2    0  100M  0 lvm   /tmp/new
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1017M  0 raid0
    └─vgnetology-lv1 253:2    0  100M  0 lvm   /tmp/new
```

**15. Протестируйте целостность файла:**  
```
$ gzip -t /tmp/new/test.gz
$ echo $?
0
```

**16. Используя `pvmove`, переместите содержимое PV с RAID0 на RAID1. **
```
$ sudo pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 8.00%
  /dev/md1: Moved: 100.00%
$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
│   └─vgnetology-lv1 253:2    0  100M  0 lvm   /tmp/new
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1017M  0 raid0
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
│   └─vgnetology-lv1 253:2    0  100M  0 lvm   /tmp/new
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1017M  0 raid0
```

**17. Сделайте `--fail` на устройство в вашем RAID1 md.**  
```
$ sudo mdadm /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```

**18. Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.**  
```
[ 5968.623967] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

**19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:**  
```
$ sudo gzip -t /tmp/new/test.gz
$ echo $?
0
```


