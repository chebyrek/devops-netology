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
**3. Используя PKI Secrets Engine, создайте Root CA и Intermediate CA.**  
```

```
