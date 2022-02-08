# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: front-back
  name: front-back
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: front-back
  template:
    metadata:
      labels:
        app: front-back
    spec:
      containers:
        - image: quay.io/chebyrek/frontend13
          imagePullPolicy: IfNotPresent
          name: front
        - image: quay.io/chebyrek/backend13
          imagePullPolicy: IfNotPresent
          name: back

---
apiVersion: v1
kind: Service
metadata:
  name: front-back
  namespace: default
spec:
  type: NodePort
  ports:
    - name: front
      port: 80
    - name: back
      port: 9000
  selector:
    app: front-back
```
* база данных — через statefulset.
```yml

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: db
  selector:
    matchLabels:
      app: postgres
  replicas: 1
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:latest
          volumeMounts:
            - name: pg-disk
              mountPath: /data
          env:
            - name: POSTGRES_PASSWORD
              value: postgres
            - name: POSTGRES_USER
              value: postgres
            - name: PGDATA
              value: /data/pgdata
            - name: POSTGRES_DB
              value: news
  volumeClaimTemplates:
    - metadata:
        name: pg-disk
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pg-disk
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  hostPath:
    path: /tmp/pg-disk
---
apiVersion: v1
kind: Service
metadata:
  name: db
  labels:
    app: postgres
spec:
  type: ClusterIP
  ports:
    - port: 5432
  selector:
    app: postgres

```
я так и не смог заставить работать приложение из папки 13-kubernetes-config, поэтому просто покажу, что контейнеры видят друг друга
```
:::~/13$ k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                       AGE
db           ClusterIP   10.233.1.182    <none>        5432/TCP                      22h
front-back   NodePort    10.233.19.112   <none>        80:32546/TCP,9000:30031/TCP   22h
kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP                       3d14h
:::~/13$ k get po
NAME                           READY   STATUS        RESTARTS      AGE
front-back-5485b5f888-9bvj5    2/2     Running       3 (16m ago)   22h
hello-node1-7c6b57dfd4-8zgg8   1/1     Terminating   0             3d14h
nm1-6b6bb949c6-lkph5           1/1     Running       2 (41m ago)   37h
postgres-0                     1/1     Running       1 (41m ago)   22h
```
подключение с фронта к бэку
```
::~/13$ k exec front-back-5485b5f888-9bvj5 -c front -- curl localhost:9000
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    22  100    22    0     0   2200      0 --:--:-- --:--:-- --:--:--  2200
{"detail":"Not Found"}
```
подключение с бэка до БД
```
:::~/13$ k exec front-back-5485b5f888-9bvj5 -c back -- pg_isready -h db -p 5432
db:5432 - accepting connections
```
## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

front
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: front
  name: front
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: front
  template:
    metadata:
      labels:
        app: front
    spec:
      containers:
        - image: quay.io/chebyrek/frontend13
          imagePullPolicy: IfNotPresent
          name: front
          env:
            - name: BASE_URL
              value: "http://back:9000"

---
apiVersion: v1
kind: Service
metadata:
  name: front
  namespace: default
spec:
  type: NodePort
  ports:
    - name: front
      port: 80
  selector:
    app: front

```
back
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: back
  name: back
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: back
  template:
    metadata:
      labels:
        app: back
    spec:
      containers:
        - image: quay.io/chebyrek/backend13
          imagePullPolicy: IfNotPresent
          name: back
          env:
            - name: DATABASE_URL
              value: "postgresql://postgres:postgres@db:5432/news"
---
apiVersion: v1
kind: Service
metadata:
  name: back
  namespace: default
spec:
  type: ClusterIP
  ports:
    - name: back
      port: 9000
  selector:
    app: back

```
```
:::~/13/1$ k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
back         ClusterIP   10.233.37.222   <none>        9000/TCP       2m20s
db           ClusterIP   10.233.39.235   <none>        5432/TCP       2m20s
front        NodePort    10.233.51.163   <none>        80:30905/TCP   2m20s
kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP        3d15h
:::~/13/1$ k get po
NAME                           READY   STATUS        RESTARTS      AGE
back-7b4bc5c8b6-tkqn6          1/1     Running       0             2m54s
front-6c86b646b8-f7rtc         1/1     Running       0             2m54s
hello-node1-7c6b57dfd4-8zgg8   1/1     Terminating   0             3d14h
nm1-6b6bb949c6-lkph5           1/1     Running       2 (65m ago)   37h
postgres-0                     1/1     Running       0             2m54s
```
```
:::~/13/1$ k exec front-6c86b646b8-f7rtc -- curl back:9000
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    22  100    22    0     0    785      0 --:--:-- --:--:-- --:--:--   785{"detail":"Not Found"}
```
```
:::~/13/1$ k exec back-7b4bc5c8b6-tkqn6 -- curl db:5432
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (52) Empty reply from server
command terminated with exit code 52
```

Я пробовал запускать приложение из dockercompose, там оно у меня тоже не заработало, на 9000 порту отдает `{"detail":"Not Found"}`, видимо не может с базой связаться, хотя она доступна, разбираться нет времени. 
