**1. Измените базовый образ предложенного Dockerfile на Arch Linux c сохранением его функциональности.**  
```Docker
FROM archlinux:latest
 
RUN pacman --noconfirm -Syu ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```
![Docker run result](/homework/img/05-virt-04-t1.jpg)

https://hub.docker.com/repository/docker/chebyrek/05_virt_04_t1


