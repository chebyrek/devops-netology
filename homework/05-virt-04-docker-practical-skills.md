**1. Измените базовый образ предложенного Dockerfile на Arch Linux c сохранением его функциональности.**  
```Dockerfile
FROM archlinux:latest
 
RUN pacman --noconfirm -Syu ponysay

ENTRYPOINT ["/usr/bin/ponysay"]
CMD ["Hey, netology”]
```
![Docker run result](/homework/img/05-virt-04-t1.jpg)

https://hub.docker.com/repository/docker/chebyrek/05_virt_04_t1

**2. В данной задаче вы составите несколько разных Dockerfile для проекта Jenkins, опубликуем образ в dockerhub.io и посмотрим логи этих контейнеров.**  

chebyrek/05_virt_04_t2:ver2
```dockerfile
FROM ubuntu:latest
RUN apt-get update &&\
    apt-get -y install wget gnupg &&\
    wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add - &&\
    sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list' &&\
    apt-get update &&\
    apt-get -y install default-jre jenkins
EXPOSE 8080
CMD ["/usr/bin/java","-jar","/usr/share/jenkins/jenkins.war"]
```
![ver2 logs](/homework/img/05_virt_04_t2_ubnt_log.jpg)
