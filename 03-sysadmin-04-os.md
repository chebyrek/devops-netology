**1. На лекции мы познакомились с node_exporter. В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter: поместите его в автозагрузку, предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на systemctl cat cron), удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.**  
```
$ sudo useradd node_exporter -s /sbin/nologin
$ sudo systemctl start node_exporter.service
$ systemctl status node_exporter.service
● node_exporter.service - Prometheus exporter for hardware and OS metrics exposed by *NIX kernels
     Loaded: loaded (/etc/systemd/system/node_exporter.service; disabled; vendor preset: enabled)
     Active: active (running) since Fri 2021-04-23 08:02:57 UTC; 10s ago
   Main PID: 8104 (node_exporter)
      Tasks: 3 (limit: 2169)
     Memory: 2.1M
     CGroup: /system.slice/node_exporter.service
             └─8104 /usr/bin/node_exporter

$ sudo systemctl stop node_exporter.service
user@testubuntu:/etc/systemd/system$ systemctl status node_exporter.service
● node_exporter.service - Prometheus exporter for hardware and OS metrics exposed by *NIX kernels
     Loaded: loaded (/etc/systemd/system/node_exporter.service; disabled; vendor preset: enabled)
     Active: inactive (dead)

$ sudo systemctl enable node_exporter.service
Created symlink /etc/systemd/system/multi-user.target.wants/node_exporter.service → /etc/systemd/system/node_exporter.service.
```
```
cat /etc/systemd/system/node_exporter.service
# node_exporter unit
[Unit]
Description=Prometheus exporter for hardware and OS metrics exposed by *NIX kernels
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
EnvironmentFile=-/etc/default/node_exporter
ExecStart=/usr/bin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
```

**2. Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.**  

collector.cpu.info, collector.cpu, collector.cpufreq, collector.diskstats, collector.filesystem, collector.loadavg, collector.meminfo, collector.netdev, collector.netstat, collector.uname  

**4. Можно ли по выводу dmesg понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?**  

Да, можно
```
# на Hyper-v, например такие строки в dmesg
[    0.000000] DMI: Microsoft Corporation Virtual Machine/Virtual Machine, BIOS 090007  05/18/2018
[    0.000000] Hypervisor detected: Microsoft Hyper-V
[    0.000000] Hyper-V: features 0x2e7f, hints 0x60e24, misc 0xbed7b2
[    0.000000] Hyper-V Host Build:17763-10.0-0-0.737
[    0.000000] Hyper-V: LAPIC Timer Frequency: 0xc3500
[    0.000000] tsc: Marking TSC unstable due to running on Hyper-V
[    0.000000] Hyper-V: Using hypercall for remote TLB flush
```
```
# а на VirtualBox такие

```
