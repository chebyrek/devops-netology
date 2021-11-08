## Задание 1

Вам необходимо поднять в докере:
- elasticsearch(hot и warm ноды)
- logstash
- kibana
- filebeat

и связать их между собой.

Logstash следует сконфигурировать для приёма по tcp json сообщений.

Filebeat следует сконфигурировать для отправки логов docker вашей системы в logstash.

В директории [help](./help) находится манифест docker-compose и конфигурации filebeat/logstash для быстрого 
выполнения данного задания.

Результатом выполнения данного задания должны быть:
- скриншот `docker ps` через 5 минут после старта всех контейнеров (их должно быть 5)  

![task 1-01](/homework/img/100401.jpg)

- скриншот интерфейса kibana  

![task 1-02](/homework/img/100402.jpg)


## Задание 2
---
Я не осилил настроить logstash, настроил filebeat отправлять данные сразу в elastic.
На filebeat такая ошибка, хз что делать
```
{"level":"error","timestamp":"2021-11-08T09:21:22.067Z","caller":"logstash/async.go:256","message":"Failed to publish events caused by: read tcp 172.20.0.6:34886->172.20.0.5:5046: i/o timeout"}
{"level":"error","timestamp":"2021-11-08T09:21:22.068Z","caller":"logstash/async.go:256","message":"Failed to publish events caused by: client is not connected"}
{"level":"error","timestamp":"2021-11-08T09:21:23.148Z","caller":"pipeline/output.go:121","message":"Failed to publish events: client is not connected"}
{"level":"info","timestamp":"2021-11-08T09:21:23.148Z","caller":"pipeline/output.go:95","message":"Connecting to backoff(async(tcp://logstash:5046))"}
{"level":"info","timestamp":"2021-11-08T09:21:23.149Z","caller":"pipeline/output.go:105","message":"Connection to backoff(async(tcp://logstash:5046)) established"}
{"level":"info","timestamp":"2021-11-08T09:21:23.152Z","logger":"publisher","caller":"pipeline/retry.go:189","message":"retryer: send unwait-signal to consumer"}
{"level":"info","timestamp":"2021-11-08T09:21:23.152Z","logger":"publisher","caller":"pipeline/retry.go:191","message":"  done"}
```
При этом в логах контейнера logstash видно, что что-то приходит
```
{
          "port" => 34936,
          "host" => "filebeat.help_elastic",
       "message" => "\\xAFU\\x98iU\\xD0\\xC4\\xE3\\xC5\\b\\xB1\\u0014\\u0018\\x96\\xFF\\x8A[S\\xCE\\xCB:s7\\xAAS\\u000E\\x93x>\\xB5\\u001Dj%a\\xE8\\xFA\\xC4\\u0001;rÔ؎\\u000F>x\\u000Ev\\xDC0\\xB1m+\\x85\\xC4\\u000F\\x83\\x94`\\u000F'\\u0010\\x99\\xA1M#/\\xC2\\u001E\\x8DЅ\\x86T\\xAE\\xAC\\u0006\\xD8R\\x84\\x9A\\u00184_j\\xC6:\\xE5\\u000EH\\x9B\\u0013\\x87\\xE6\\xBDb\\rKܧ5۷\\xC3\\u0017\\xE6\\xA9v\\xC3\\xE4\\xD4\\xDFk\\xEB\\x83\\r\\x87SE7E\\xE0P\\\\\\xB3\\xB7\\xC6W\\u001A\\xEA\\x86\\xE2\\u0005ަ\\f;\\xAB0\\xD4\\u0006\\xDDYE`\\xBB\\xBC\\xB6\\xC9\\xCF[W]\\xAAXl\\x93\\x88\\xDC\\xD6;o\\xDDAg\\u001D\\xC8T\\xABr]\\xCDg\\xCB\\xE2E\\x93\\x89<\\xEA\\xF5\\xFE7\\xD9(\\u0013\\xB1\\x95\\x9Bܶ\\x8C\\xACj\\\\\\xF1\\xF9\\xAC\\xC6冡VW\\x85\\xD4\\xC3\\xEB\\vu\\xF7\\xC9@k\\u0015?[$-\\xC2\\xD4Q\\xAEa\\xBAm\\xD5nV",
      "@version" => "1",
          "tags" => [
        [0] "_jsonparsefailure"
    ],
    "@timestamp" => 2021-11-08T09:22:58.273Z
}
{
          "port" => 34936,
          "host" => "filebeat.help_elastic",
       "message" => "\\xBD\\xD0",
      "@version" => "1",
          "tags" => [
        [0] "_jsonparsefailure"
    ],
    "@timestamp" => 2021-11-08T09:22:58.277Z
}
{
          "port" => 34936,
          "host" => "filebeat.help_elastic",
       "message" => "JۨU\\xB2\\x8E0ˊ,\\xAD\\x94\\xA4\\\\\\u0001\\x835M\\xEE\\u007F\\u0010\\x85\\u001D<\\xEA\\x81&\\xE0\\xDB\\xFD\\xBBD\\xD1\\t\\x94M٩Je-v\\x99D\\x94MW\\x89\\u0014\\xB1U\\x9D(Hλ\\x92\\xB22\\xAB\\xE7YY\\xB7MC\\xB5(\\u0011)Ǵ\\x95\\x85\\u0002\\u0006\\xDA\\xE0\\x92\\x80oa@C\\xC0\\xA1\\xD7݄\\xD3&\\u00197~e\\a>\\x8F\\xDB\\b\\xFBQ\\u000F\\u0004;\\u0006\\u0003\\u001A\\u0002\\u000E\\xCE\\u001AZ\\xE08\\u0002\\x83\\u001E;\\xEA\\u001D\\xF0-\\bk\\u0016Ҋ[\\x9A\\u0016\\u009A\\xD1:Z\\xACir\\xDA\\xEE/#/\\xE3\\u0014\\u0002\\u0006\\xB3\\x90\\u001FG\\t;(\\xBD\\x8CV\\xE8V\\xC0\\x81\\xF2\\xA6@\\x89]W\\x8B\\xBA\\x99˪ld\\xD3\\xE5\\x94\\u0015i\\xA3r\\xAA\\x9A\\u0002U!۲UT\\xD6",
      "@version" => "1",
          "tags" => [
        [0] "_jsonparsefailure"
    ],
    "@timestamp" => 2021-11-08T09:22:58.288Z
```
Но никаких индексов не создается в любом случае.

---
Перейдите в меню [создания index-patterns  в kibana](http://localhost:5601/app/management/kibana/indexPatterns/create)
и создайте несколько index-patterns из имеющихся.

Перейдите в меню просмотра логов в kibana (Discover) и самостоятельно изучите как отображаются логи и как производить 
поиск по логам.
![task 2-01](/homework/img/100404.jpg)
В манифесте директории help также приведенно dummy приложение, которое генерирует рандомные события в stdout контейнера.
Данные логи должны порождать индекс logstash-* в elasticsearch. Если данного индекса нет - воспользуйтесь советами 
и источниками из раздела "Дополнительные ссылки" данного ДЗ.
![task 2-02](/homework/img/100403.jpg)
 
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---

 
