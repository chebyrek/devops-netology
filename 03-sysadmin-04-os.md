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
```
```
# а на VirtualBox такие
[    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
[    0.000000] Hypervisor detected: KVM
```

**5. Как настроен `sysctl fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?**  
```
$ sysctl fs.nr_open
fs.nr_open = 1048576
```
Задает максимальное количество открытых файлов для процесса  
```
$ ulimit -n
1024
```

**6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`).**  
```
# screen
# unshare -f --pid --mount-proc /bin/sleep 1h
C-a c
# nsenter --target 1220 --pid --mount
# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   8076   528 pts/1    S+   08:05   0:00 /bin/sleep 1h
root           2  0.0  0.1   9836  4232 pts/2    S    08:07   0:00 -bash
root          11  0.0  0.0  11492  3380 pts/2    R+   08:07   0:00 ps aux
```
**7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?**  

`:(){ :|:& };:` - это "fork bomb", функция множество раз вызывающая саму себя

Механизм cgroup pids controller
```
 cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-5.scope
```
Из
