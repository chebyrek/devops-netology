**2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?**  
Нет, потому что жесткие ссылки указывает на один объект, а у него может быть только один набор прав  

**4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.**  
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

**5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.**  
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

**6. Соберите mdadm RAID1 на паре разделов 2 Гб.**  
```
$ sudo mdadm -C /dev/md0 -l 1 -n 2 /dev/sdb1 /dev/sdc1
$ sudo mdadm /dev/md0
/dev/md0: 2045.00MiB raid1 2 devices, 0 spares. Use mdadm --detail for more detail.
```
**7. Соберите mdadm RAID0 на второй паре маленьких разделов. **  
```
$ sudo mdadm -C /dev/md1 -l 0 -n 2 /dev/sdb2 /dev/sdc2
$ sudo mdadm /dev/md1
/dev/md1: 1017.00MiB raid0 2 devices, 0 spares. Use mdadm --detail for more detail.
```
