# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

Применяю такой манифест
```yml
---
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
        - name: front
          image: quay.io/chebyrek/frontend13
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - mountPath: "/static"
              name: static
        - name: back
          image: quay.io/chebyrek/backend13
          imagePullPolicy: IfNotPresent
          volumeMounts:
            - mountPath: "/static"
              name: static
      volumes:
        - name: static
          emptyDir: {}
```
Проверяю
```
:::~/13/2$ k exec front-back-5c587df5c7-5g8v7 -c back -- touch /static/test1
:::~/13/2$ k exec front-back-5c587df5c7-5g8v7 -c front -- ls -l /static/test1
-rw-r--r-- 1 root root 0 Feb 10 07:18 /static/test1
```
## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

Манифесты
front.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: front
  name: front
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: front
  template:
    metadata:
      labels:
        app: front
    spec:
      containers:
        - name: front
          image: quay.io/chebyrek/frontend13
          imagePullPolicy: Always
          volumeMounts:
            - mountPath: "/static"
              name: nfs
      volumes:
        - name: nfs
          persistentVolumeClaim:
            claimName: pvc
```
back.yml
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: back
  name: back
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: back
  template:
    metadata:
      labels:
        app: back
    spec:
      containers:
        - name: back
          image: quay.io/chebyrek/backend13
          imagePullPolicy: Always
          volumeMounts:
            - mountPath: "/static"
              name: nfs
      volumes:
        - name: nfs
          persistentVolumeClaim:
            claimName: pvc

```
pvc.yml
```yml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
spec:
  storageClassName: "nfs"
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
```
Что поднялось
```
:::~/13/2$ k get nodes
NAME    STATUS   ROLES                  AGE     VERSION
node1   Ready    control-plane,master   5d19h   v1.23.1
node2   Ready    <none>                 5d19h   v1.23.1
node3   Ready    <none>                 5d19h   v1.23.1

:::~/13/2$ k get po
NAME                                  READY   STATUS        RESTARTS        AGE
back-5dd7c48f66-mvp2p                 1/1     Running       0               19s
back-5dd7c48f66-xb6tq                 1/1     Running       0               2m26s
front-56f55b7bb8-w57sx                1/1     Running       0               2m26s
front-56f55b7bb8-xf48q                1/1     Running       0               2m26s
nfs-server-nfs-server-provisioner-0   1/1     Running       0               4h27m
nm1-6b6bb949c6-lkph5                  1/1     Running       3 (4h34m ago)   3d20h

:::~/13/2$ k get storageclasses.storage.k8s.io 
NAME   PROVISIONER                                       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    cluster.local/nfs-server-nfs-server-provisioner   Delete          Immediate           true                   107m

:::~/13/2$ k get pv,pvc
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS   REASON   AGE
persistentvolume/pvc-2884af3a-f4f3-4bfb-a1e4-04e5dae5678c   1Mi        RWX            Delete           Bound    default/pvc   nfs                     3m12s

NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc   Bound    pvc-2884af3a-f4f3-4bfb-a1e4-04e5dae5678c   1Mi        RWX            nfs            3m12s
```
Проверка
```
:::~/13/2$ k exec back-5dd7c48f66-mvp2p -- touch /static/1.txt
:::~/13/2$ k exec back-5dd7c48f66-xb6tq -- touch /static/2.txt
:::~/13/2$ k exec front-56f55b7bb8-w57sx -- ls -l /static
total 0
-rw-r--r-- 1 root root 0 Feb 10 10:44 1.txt
-rw-r--r-- 1 root root 0 Feb 10 10:44 2.txt
:::~/13/2$ k exec front-56f55b7bb8-xf48q -- ls -l /static
total 0
-rw-r--r-- 1 root root 0 Feb 10 10:44 1.txt
-rw-r--r-- 1 root root 0 Feb 10 10:44 2.txt
```
---


---
