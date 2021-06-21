**1. Посмотрите на сценарий ниже и ответьте на вопрос: "Подходит ли в этом сценарии использование докера? Или лучше подойдет виртуальная машина, физическая машина? Или возможны разные варианты?" Детально опишите и обоснуйте свой выбор.**    

* Высоконагруженное монолитное java веб-приложение;  

  Для монолита подойдет отдельная ВМ, удобство администрирования перекрывает выигрыш в производительности от использования голого железа, а контейнер кажется тут ни к чему.  
  
* Go-микросервис для генерации отчетов;  

  Здесь докер позволит рационально использовать ресурсы, и такой сервис скорее всего stateless, а докер для того  и нужен 

* Nodejs веб-приложение;  

  А имеет смысл использовать докер если на сервере будет только одно приложение? С виртуалкой я согласен, там снимки, миграция, бэкапы. А какой-то смысл от конструкции железо -> виртуалка -> докер с одним контейнером есть? По идее тут подойдет и ВМ и докер, зависит от потребностей приложения.  
  
* Мобильное приложение c версиями для Android и iOS;  

  Тоже, что для Nodejs приложения выше.  
  
* База данных postgresql используемая, как кэш;  
  
  Доступ к кэшу должен быть максимально быстрым, значит лучше использовать физическую машину.
  
* Шина данных на базе Apache Kafka;  
  
  Я так понимаю шина только отдает данные из хранилища по API, значит сама  ничего не хранит, а значит докер подойдет  
  
* Очередь для Logstash на базе Redis;  

  Докер подходит  
  
* Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;  

  Здесь подойдет докер, мне кажется будет удобнее рулить несколькими нодами, чем при использовании ВМ

* Мониторинг-стек на базе prometheus и grafana;  

  Докер
  
* Mongodb, как основное хранилище данных для java-приложения;

  БД вроде бы не желательно размещать в контейнерах, поэтому ВМ или железо  
  
* Jenkins-сервер. 

  Докер  
  
Получается так, что докер подходит в большинстве случаев, в докерхабе есть образы для всего из вышеперечисленного, а значит в большей степени все зависит от условий, а не от самого приложения.  

**2. Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на докерхаб-репо.**  

https://hub.docker.com/repository/docker/chebyrek/docker-test  

**3. Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /info контейнера.**  

```bash
$ sudo docker pull centos
Using default tag: latest
latest: Pulling from library/centos
7a0437f04f83: Pull complete 
Digest: sha256:5528e8b1b1719d34604c87e11dcd1c0a20bedf46e83b5632cdeac91b8c04efc1
Status: Downloaded newer image for centos:latest
docker.io/library/centos:latest
$ sudo docker pull debian:latest
latest: Pulling from library/debian
d960726af2be: Pull complete 
Digest: sha256:acf7795dc91df17e10effee064bd229580a9c34213b4dba578d64768af5d8c51
Status: Downloaded newer image for debian:latest
docker.io/library/debian:latest
$ mkdir info
$ sudo docker run -dit -v /home/user/info:/share/info centos 
d5c1040ead93252a4b77dec751222c517bb9d54c21fb1d8625c707841da00de9
$ sudo docker run -dit -v /home/user/info:/info debian
58020e198b11a8b108001164b44482bb01c26f225b216c598700f7aebc017895
$ sudo docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS          PORTS     NAMES
58020e198b11   debian    "bash"        22 seconds ago   Up 21 seconds             goofy_shamir
d5c1040ead93   centos    "/bin/bash"   30 seconds ago   Up 29 seconds             busy_merkle
$ sudo docker exec -it d5c1040ead93 /bin/bash
[root@d5c1040ead93 /]# cd /share/info/
[root@d5c1040ead93 info]# echo "Hello, world" > netology.txt
[root@d5c1040ead93 info]# exit
exit
$ touch info/netology2.txt
$ sudo docker exec -it 58020e198b11 /bin/bash
root@58020e198b11:/# ls -l /info
total 4
-rw-r--r-- 1 root root 13 Jun 21 12:20 netology.txt
-rw-rw-r-- 1 1000 1000  0 Jun 21 12:21 netology2.txt
root@58020e198b11:/# 
```
