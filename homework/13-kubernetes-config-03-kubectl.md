# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
```bash
:::$ k port-forward back-7b4bc5c8b6-jfq6k 9000:9000
:::~/13/3$ curl 127.1:9000
{"detail":"Not Found"}
```
```bash
:::~/13/3$ k exec nm1-6b6bb949c6-lkph5 -- curl back:9000
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    22  100    22    0     0   3421      0 --:--:-- --:--:-- --:--:--  3666
{"detail":"Not Found"}
```
* сделайте запросы к фронту;
```bash
:::~$ k port-forward front-6c86b646b8-hc974 8080:80
:::~/13/3$ curl 127.1:8080
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```

```bash
:::~/13/3$ k exec nm1-6b6bb949c6-lkph5 -- curl front
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   448  100   448    0     0   8751      0 --:--:-- --:--:-- --:--:--  8784
<!DOCTYPE html>
<html lang="ru">
<head>
    <title>Список</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="/build/main.css" rel="stylesheet">
</head>
<body>
    <main class="b-page">
        <h1 class="b-page__title">Список</h1>
        <div class="b-page__content b-items js-list"></div>
    </main>
    <script src="/build/main.js"></script>
</body>
</html>
```
* подключитесь к базе данных.
```bash
:::~$ k port-forward postgres-0 5432:5432
:::~/13/3$ psql postgresql://postgres:postgres@localhost:5432/news -c '\dt'
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | news | table | postgres
(1 row)
```
```bash
:::~/13/3$ k exec -ti nm1-6b6bb949c6-lkph5 -- psql postgresql://postgres:postgres@db:5432/news -c '\dt'
        List of relations
 Schema | Name | Type  |  Owner   
--------+------+-------+----------
 public | news | table | postgres
(1 row)
```

## Задание 2: ручное масштабирование
При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. После уменьшите количество копий до 1. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe).
```bash
:::~/13/3$ kubectl get nodes
NAME    STATUS   ROLES                  AGE   VERSION
node1   Ready    control-plane,master   11d   v1.23.1
node2   Ready    <none>                 11d   v1.23.1
node3   Ready    <none>                 11d   v1.23.1

:::~/13/3$ k get po
NAME                                  READY   STATUS    RESTARTS      AGE
back-7b4bc5c8b6-jfq6k                 1/1     Running   0             25m
front-6c86b646b8-hc974                1/1     Running   0             56m
nfs-server-nfs-server-provisioner-0   1/1     Running   1 (68m ago)   6d1h
nm1-6b6bb949c6-lkph5                  1/1     Running   4 (68m ago)   9d
postgres-0                            1/1     Running   0             56m

:::~/13/3$ k scale deploy back --replicas=3
deployment.apps/back scaled

:::~/13/3$ k scale deploy front --replicas=3
deployment.apps/front scaled

:::~/13/3$ k get po
NAME                                  READY   STATUS    RESTARTS      AGE
back-7b4bc5c8b6-4z8nc                 1/1     Running   0             20s
back-7b4bc5c8b6-jfq6k                 1/1     Running   0             40m
back-7b4bc5c8b6-vf245                 1/1     Running   0             20s
front-6c86b646b8-hc974                1/1     Running   0             71m
front-6c86b646b8-p6vfh                1/1     Running   0             5s
front-6c86b646b8-rjbph                1/1     Running   0             5s
nfs-server-nfs-server-provisioner-0   1/1     Running   1 (83m ago)   6d2h
nm1-6b6bb949c6-lkph5                  1/1     Running   4 (83m ago)   9d
postgres-0                            1/1     Running   0             71m


:::~/13/3$ k describe po back | egrep -i '^name:|^node:'
Name:         back-7b4bc5c8b6-4z8nc
Node:         node3/10.2.35.23
Name:         back-7b4bc5c8b6-jfq6k
Node:         node2/10.2.35.24
Name:         back-7b4bc5c8b6-vf245
Node:         node3/10.2.35.23

:::~/13/3$ k describe po front | egrep -i '^name:|^node:'
Name:         front-6c86b646b8-hc974
Node:         node3/10.2.35.23
Name:         front-6c86b646b8-p6vfh
Node:         node3/10.2.35.23
Name:         front-6c86b646b8-rjbph
Node:         node2/10.2.35.24

:::~/13/3$ k scale deploy front --replicas=1
deployment.apps/front scaled

:::~/13/3$ k scale deploy back --replicas=1
deployment.apps/back scaled

:::~/13/3$ k get po
NAME                                  READY   STATUS    RESTARTS      AGE
back-7b4bc5c8b6-jfq6k                 1/1     Running   0             48m
front-6c86b646b8-rjbph                1/1     Running   0             8m49s
nfs-server-nfs-server-provisioner-0   1/1     Running   1 (92m ago)   6d2h
nm1-6b6bb949c6-lkph5                  1/1     Running   4 (92m ago)   9d
postgres-0                            1/1     Running   0             80m

:::~/13/3$ k describe po front| egrep -i '^name:|^node:'
Name:         front-6c86b646b8-rjbph
Node:         node2/10.2.35.24

:::~/13/3$ k describe po back | egrep -i '^name:|^node:'
Name:         back-7b4bc5c8b6-jfq6k
Node:         node2/10.2.35.24
```
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
