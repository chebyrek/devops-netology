**1. ipvs. Если при запросе на VIP сделать подряд несколько запросов (например, `for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done` ), ответы будут получены почти мгновенно. Тем не менее, в выводе `ipvsadm -Ln` еще некоторое время будут висеть активные `InActConn`. Почему так происходит?** 

```
vagrant@netology1:~$ sudo ipvsadm -Ln --timeout
Timeout (tcp tcpfin udp): 900 120 300
```
За поведение в вопросе отвечает tcpfin (120), т.е. как долго сессия сохраняется после закрытия.

**2. На лекции мы познакомились отдельно с ipvs и отдельно с keepalived. Воспользовавшись этими знаниями, совместите технологии вместе (VIP должен подниматься демоном keepalived). Приложите конфигурационные файлы, которые у вас получились, и продемонстрируйте работу получившейся конструкции. Используйте для директора отдельный хост, не совмещая его с риалом! Подобная схема возможна, но выходит за рамки рассмотренного на лекции.**  

vagrantfile
```ruby
bal = {
    'bal01' => '11',
    'bal02' => '12'
}

srv = {
    'srv01' => '21',
    'srv02' => '22'
}

Vagrant.configure("2") do |config|
  config.vm.network "private_network", virtualbox__intnet: true, auto_config: false
  config.vm.box = "bento/ubuntu-20.04"

  config.vm.define 'client' do |node|
    node.vm.provision "shell" do |s|
      s.inline = "hostname client;"\
      "ip addr add 192.168.10.250/24 dev eth1;"\
      "ip link set dev eth1 up;"\
    end
  end

  bal.each do |k, v|
    config.vm.define k do |node|
      node.vm.provision "shell" do |s|
        s.inline = "hostname $1;"\
          "ip addr add $2 dev eth1;"\
          "ip link set dev eth1 up;"\
          "apt update && apt -y install ipvsadm keepalived;"\
          "ipvsadm -A -t 192.168.10.2:80 -s rr &&"\
          "ipvsadm -a -t 192.168.10.2:80 -r 192.168.10.21:80 -g -w 1 &&"\
          "ipvsadm -a -t 192.168.10.2:80 -r 192.168.10.22:80 -g -w 1;"
        s.args = [k, "192.168.10.#{v}/24"]
      end
    end
  end

  srv.each do |k, v|
    config.vm.define k do |node|
      node.vm.provision "shell" do |s|
        s.inline = "hostname $1;"\
          "ip addr add $2 dev eth1;"\
          "ip link set dev eth1 up;"\
          "apt update && apt -y install nginx;"\
          "sysctl -w net.ipv4.conf.all.arp_ignore=1 && sysctl -w net.ipv4.conf.all.arp_announce=2;"\
          "ip addr add 192.168.10.2/32 dev lo label lo:2"
        s.args = [k, "192.168.10.#{v}/24"]
      end
    end
  end
end
```

```shell
vagrant@bal01:~$ cat /etc/keepalived/keepalived.conf
global_defs {
   router_id bal01
}

vrrp_instance VI_1 {
    state MASTER
    interface eth1
    virtual_router_id 41
    priority 10
    advert_int 1

   virtual_ipaddress {
       192.168.10.2/32 dev eth1 label eth1:2
    }
}
```
```shell
vagrant@bal02:~$ cat /etc/keepalived/keepalived.conf
global_defs {
   router_id bal02
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth1
    virtual_router_id 41
    priority 9
    advert_int 1

   virtual_ipaddress {
       192.168.10.2/32 dev eth1 label eth1:2
    }
}
```
На bal01 и bal02 выполняю
```shell
sudo systemctl start keepalived
```
На клиенте выполняю:
```shell
vagrant@client:~$ for i in {1..50}; do curl -I -s 192.168.10.2>/dev/null; done
```

На bal01 видим соединения:
```shell
vagrant@bal01:~$ sudo ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.10.2:80 rr
  -> 192.168.10.21:80             Route   1      0          25
  -> 192.168.10.22:80             Route   1      0          25
```

Выключаю интерфейс на bal01
```shell
vagrant@bal01:~$ sudo ip l set eth1 down
vagrant@bal01:~$ tail -n 5 /var/log/syslog
May 10 08:06:31 vagrant Keepalived_vrrp[782]: Netlink reports eth1 down
May 10 08:06:31 vagrant systemd-networkd[383]: eth1: Link DOWN
May 10 08:06:31 vagrant Keepalived_vrrp[782]: (VI_1) Entering FAULT STATE
May 10 08:06:31 vagrant systemd-networkd[383]: eth1: Lost carrier
May 10 08:06:31 vagrant Keepalived_vrrp[782]: (VI_1) sent 0 priority
```
На клиенте снова выполняю:
```shell
vagrant@client:~$ for i in {1..50}; do curl -I -s 192.168.10.2>/dev/null; done
```
Теперь соединения и VIP появились на bal02
```shell
vagrant@bal02:~$ sudo ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.10.2:80 rr
  -> 192.168.10.21:80             Route   1      0          25
  -> 192.168.10.22:80             Route   1      0          25
  
vagrant@bal02:~$ sudo ip a s eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:46:e8:aa brd ff:ff:ff:ff:ff:ff
    inet 192.168.10.12/24 scope global eth1
       valid_lft forever preferred_lft forever
    inet 192.168.10.2/32 scope global eth1:2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe46:e8aa/64 scope link
       valid_lft forever preferred_lft forever
       
vagrant@bal02:~$ tail -n 1 /var/log/syslog
May 10 08:06:34 vagrant Keepalived_vrrp[782]: (VI_1) Entering MASTER STATE       
```

**3. В лекции мы использовали только 1 VIP адрес для балансировки. У такого подхода несколько отрицательных моментов, один из которых – невозможность активного использования нескольких хостов (1 адрес может только переехать с master на standby). Подумайте, сколько адресов оптимально использовать, если мы хотим без какой-либо деградации выдерживать потерю 1 из 3 хостов при входящем трафике 1.5 Гбит/с и физических линках хостов в 1 Гбит/с? Предполагается, что мы хотим задействовать 3 балансировщика в активном режиме (то есть не 2 адреса на 3 хоста, один из которых в обычное время простаивает).**  

Я возможно не очень понял вопрос, но если нужно 3 балансировщика, то и адреса должно быть 3. При потере 1 балансировщика останется 2 с суммарным каналом в 2 Гбит/с, что больше чем входящий трафик.
