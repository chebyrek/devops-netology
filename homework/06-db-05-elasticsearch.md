# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
```dockerfile
FROM centos:latest
WORKDIR /opt/elasticsearch
COPY ./elasticsearch-7.13.3 /opt/elasticsearch  
EXPOSE 9200
RUN useradd -d /opt/elasticsearch -M -s /bin/bash -U elasticsearch && \
    mkdir -p /var/lib/elasticsearch/data && \
    chown -R elasticsearch:elasticsearch /opt/elasticsearch && \
    chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
CMD ["su", "elasticsearch", "/opt/elasticsearch/bin/elasticsearch"]
```
- ссылку на образ в репозитории dockerhub  
https://hub.docker.com/repository/docker/chebyrek/06-db-05-elasticsearch
- ответ `elasticsearch` на запрос пути `/` в json виде
```json
$ curl localhost:9200/
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "d8J2zzHkR4OmwnrwXEdALA",
  "version" : {
    "number" : "7.13.3",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "5d21bea28db1e89ecc1f66311ebdec9dc3aa7d64",
    "build_date" : "2021-07-02T12:06:10.804015202Z",
    "build_snapshot" : false,
    "lucene_version" : "8.8.2",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```sh
$ curl -X GET "localhost:9200/_cat/indices"
green  open ind-1 afYKSk4RTQ-T_7jrxTbUDQ 1 0 0 0 208b 208b
yellow open ind-3 trn3ZX7OTNmLjHeVSVRzvA 4 2 0 0 832b 832b
yellow open ind-2 qUsmMdlfTqSUmU55YmufBw 2 1 0 0 416b 416b
```
Получите состояние кластера `elasticsearch`, используя API.
```json
$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
   "cluster_name":"elasticsearch",
   "status":"yellow",
   "timed_out":false,
   "number_of_nodes":1,
   "number_of_data_nodes":1,
   "active_primary_shards":7,
   "active_shards":7,
   "relocating_shards":0,
   "initializing_shards":0,
   "unassigned_shards":10,
   "delayed_unassigned_shards":0,
   "number_of_pending_tasks":0,
   "number_of_in_flight_fetch":0,
   "task_max_waiting_in_queue_millis":0,
   "active_shards_percent_as_number":41.17647058823529
}
```
Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?  

*Потому что часть шардов находится в состоянии UNASSIGNED. Необходимо привязать их к ноде, чтобы статус изменился. У индекса `ind-1` состояние `green`, потому что у него всего один шард.*
```
$ curl -X GET "localhost:9200/_cat/shards"
ind-3 1 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 1 r UNASSIGNED                   
ind-3 1 r UNASSIGNED                   
ind-3 3 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 3 r UNASSIGNED                   
ind-3 3 r UNASSIGNED                   
ind-3 2 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 2 r UNASSIGNED                   
ind-3 2 r UNASSIGNED                   
ind-3 0 p STARTED    0 208b 172.17.0.2 netology_test
ind-3 0 r UNASSIGNED                   
ind-3 0 r UNASSIGNED                   
ind-1 0 p STARTED    0 208b 172.17.0.2 netology_test
ind-2 1 p STARTED    0 208b 172.17.0.2 netology_test
ind-2 1 r UNASSIGNED                   
ind-2 0 p STARTED    0 208b 172.17.0.2 netology_test
ind-2 0 r UNASSIGNED              
```
Удалите все индексы.
```sh
curl -X DELETE "localhost:9200/ind-{1,2,3}"
```
**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.
```sh
$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/opt/elasticsearch/snapshots"
  }
}
'
{
  "acknowledged" : true
}
```
Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.
```sh
$ curl -X GET "localhost:9200/_cat/indices"
green open test X5XF8OgrSv-dGyq2S1yzNA 1 0 0 0 208b 208b
```
[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.
```sh
ls -l snapshots/
total 44
-rw-r--r-- 1 elasticsearch elasticsearch   505 Jul 12 15:07 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Jul 12 15:07 index.latest
drwxr-xr-x 3 elasticsearch elasticsearch  4096 Jul 12 15:06 indices
-rw-r--r-- 1 elasticsearch elasticsearch 25649 Jul 12 15:07 meta-JlP8a1irSnGWdAY3lmAvzQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch   360 Jul 12 15:07 snap-JlP8a1irSnGWdAY3lmAvzQ.dat
```
Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.
```sh
$ curl -X GET "localhost:9200/_cat/indices"
green open test-2 GKWPqxiFR2O8AHLYlXyo6Q 1 0 0 0 208b 208b
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```sh
$ curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty"
{
  "accepted" : true
}
$ curl -X GET "localhost:9200/_cat/indices"
green open test-2 GKWPqxiFR2O8AHLYlXyo6Q 1 0 0 0 208b 208b
green open test  v3jPXb-GRQqbXe1arrFkdg 1 0 0 0 208b 208b
```
Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
