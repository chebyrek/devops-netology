**1. Установите Hashicorp Vault в виртуальной машине Vagrant/VirtualBox.**  
```
vagrant@vagrant:~$ vault -v
Vault v1.7.1 (917142287996a005cb1ed9d96d00d06a0590e44e)
```
**2. Запустить Vault-сервер в dev-режиме** 
```
vagrant@vagrant:~$ vault server -dev -dev-listen-address="0.0.0.0:8200"
==> Vault server configuration:

             Api Address: http://0.0.0.0:8200
                     Cgo: disabled
         Cluster Address: https://0.0.0.0:8201
...
```
**3, 4, 5, 6**  
```
vagrant@vagrant:~/ssl$ vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_e9972e3d    per-token private secret storage
identity/     identity     identity_170b7530     identity store
pki/          pki          pki_c43489db          n/a
pki_int/      pki          pki_7b5ac5d0          n/a
secret/       kv           kv_10d8725a           key/value secret storage
sys/          system       system_1e7dca28       system endpoints used for control, policy and debugging

vagrant@vagrant:~/ssl$ cat /etc/hosts
127.0.0.1       netology.example.com
...
```
```
vagrant@vagrant:~$ ls /home/vagrant/ssl/
interm.crt  netology.example.com.crt  netology.example.com.key
vagrant@vagrant:~$ sudo ln -s /home/vagrant/ssl/interm.crt /usr/local/share/ca-certificates/interm.crt
vagrant@vagrant:~$ sudo update-ca-certificates
```
```
vagrant@vagrant:~$ cat /etc/nginx/sites-available/default

server {
        listen 443 ssl default_server;
        listen [::]:443 ssl default_server;
        
        ssl_certificate /home/vagrant/ssl/netology.example.com.crt;
        ssl_certificate_key /home/vagrant/ssl/netology.example.com.key;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        server_name test.example.com;

        location / {
                try_files $uri $uri/ =404;
        }
}
```
```
vagrant@vagrant:~/ssl$ curl -I https://netology.example.com
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Fri, 14 May 2021 03:57:59 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Thu, 13 May 2021 08:09:06 GMT
Connection: keep-alive
ETag: "609cdea2-264"
Accept-Ranges: bytes
```
