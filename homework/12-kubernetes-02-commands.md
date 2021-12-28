# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods
```sh
user@vm1:~$ kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas=2
deployment.apps/hello-node created
user@vm1:~$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   2/2     2            2           6s5 
```

## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)

Я делал вот по этой инструкции https://itisgood.ru/2019/12/23/kak-sozdat-v-kubernetes-sluzhbu-akkaunt-polzovatelja-i-ogranichte-ego-odnim-prostranstvom-imen-s-pomoshhju-rbac/ с небольшими изменениями, ничего не понял, но работает. Этот вопрос будет более подробно освещаться на лекциях?  
Получился такой манифест (я использовал встроенную роль view):
```
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: developer
  namespace: app-namespace
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developer 
  namespace: app-namespace
subjects:
- kind: ServiceAccount
  name: developer
  namespace: app-namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
```
И такой .kube/config
```
developer@vm1:~/.kube$ cat config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRJeE1USXlNakEzTWpZeU5sb1hEVE14TVRJeU1UQTNNall5Tmxvd0ZURVRNQkVHQTFVRQpBeE1LYldsdWFXdDFZbVZEUVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTjRYCmE0cS9HQldHbnV5R1lLRXV4cGRRdjJ5b1lSZFlMK2pVSXhPMmEzMlY1TlZ2RlpjenhicnNoTW1kTkQ4ZzRpQ2UKVm5xUkpUQllDcDM0Tkx5Rmc0VTcwdVFKelpjVHZ4UldRQk9Od21IalV4YUQydUd1V3pOclJzY3VZRDBtUWs2NAovRFBtbG05TllLQk5rc2hHbHoybEVtT25EOU9mZFhmWHlwblgycE9Eb1FNbG55bGdlS3RQTVI1a0ZYVHp0amJuClVYU1Q2ZmJ3UEtWVlFjWE1NSVV6ZFMxYjlEa2NLdDhHck8xVStuTmpnOXRRMjdFeEsrQ2E0WFE5dEZsb2FnOHMKY05xSW56ZlFOQmlvdmQ0V1JBZTRGQUlKcXdWTkxMV3ZpQnBDMTRGMmFqaGZ0Ukk3M2cvRnFBZTJvSFRzMUdVdgpQckwxanNTV293WjVCRWFraGxFQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJUWFpXdHI2enNnZUZ2Wi96MWtheTd3WUdMaGZUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFhdGtWeFY0OApqM2dEek5NSnFXcklLaGRXaDE4eWI5akNxYWhMRGhHK3VmSEkxZFhHaWtkdEc5NDBPYitER1EzdGV2aEYrTENtCjljaEhJa1BmTlVaSDJ1YUNSN3lqTnR3UUY4a0hGeEhHdHZjblp3RTN5SmMxbWFGTjVZWHdPNlJCVmVCK0svL0sKOUF0dG80V3BwNUpNbWVpTEt3YUFIYnBHN3dpU1dmMFRiZHlWYXhuS1hjWnhPZm1oc0JsWW1wcHdPWjBHSUZVdQpOb0lOdGhaNWxHWHdvSnFieGJzQ09XNG9mSGMwOEl6WVpsZGF6KzFWcmtQcDlPVTJ3RVFkdXNPZ2dUZnU3K3AvCjhyUEpFeFNaQ3pPM2ZEYTRIdXJHTXN0ZlAwZCtpY0JjTlRtSWVIOTRhRjltTk1SNHJmVUl3VDZra2VuK3U2YlEKdUhLUlpGSFpIZ0JXTlE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://10.128.0.11:8443
  name: mycluster


contexts:
- context:
    cluster: mycluster
    namespace: app-namespace
    user: developer
  name: developer

current-context: developer
kind: Config
preferences: {}


users:
- name: developer
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6IjFwT2NjcWpEMldOM1FaeXFpdk9Jbng0NjI2NldfaFJfLWpvYnRPMzFQZnMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHAtbmFtZXNwYWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRldmVsb3Blci10b2tlbi1jdnR6aiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJkZXZlbG9wZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI5NTA5ODhiMS03NDJjLTQxNzQtYWZhNC0xZDM3MzQwODUzNjgiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6YXBwLW5hbWVzcGFjZTpkZXZlbG9wZXIifQ.bRceDLA3uRaV3fU4Yr1zKB3qoz6gFFeGNofpylGvflYuN3d1ldKUsWGPxOBQWAomUG15kJ7mIJdQibz-ZqvqDHr__v7RKhWry7sYdzGa9lBIWIT2Xxb0_c7zzwoZdXeDmTyCWefpakAFCq4pXaZYU-h4UEYdMVBIzh8J72xmM71YHmfTc3eOilClq4oIpWAxORC9pNGTCE09D9cxbEUmsfmwROBhZtM5ouWUqiFunWOUp43YR0gC5G6Z9I3u0j5L7wvxbbzq9ehOnDIWPicLZrbyzU8lSWyQfls_Hh2j6jd-qT4yWpUcQ68f28qCh33JIzVNYfEi3yjTeOcfukcRuQ
    client-key-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRJeE1USXlNakEzTWpZeU5sb1hEVE14TVRJeU1UQTNNall5Tmxvd0ZURVRNQkVHQTFVRQpBeE1LYldsdWFXdDFZbVZEUVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTjRYCmE0cS9HQldHbnV5R1lLRXV4cGRRdjJ5b1lSZFlMK2pVSXhPMmEzMlY1TlZ2RlpjenhicnNoTW1kTkQ4ZzRpQ2UKVm5xUkpUQllDcDM0Tkx5Rmc0VTcwdVFKelpjVHZ4UldRQk9Od21IalV4YUQydUd1V3pOclJzY3VZRDBtUWs2NAovRFBtbG05TllLQk5rc2hHbHoybEVtT25EOU9mZFhmWHlwblgycE9Eb1FNbG55bGdlS3RQTVI1a0ZYVHp0amJuClVYU1Q2ZmJ3UEtWVlFjWE1NSVV6ZFMxYjlEa2NLdDhHck8xVStuTmpnOXRRMjdFeEsrQ2E0WFE5dEZsb2FnOHMKY05xSW56ZlFOQmlvdmQ0V1JBZTRGQUlKcXdWTkxMV3ZpQnBDMTRGMmFqaGZ0Ukk3M2cvRnFBZTJvSFRzMUdVdgpQckwxanNTV293WjVCRWFraGxFQ0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJUWFpXdHI2enNnZUZ2Wi96MWtheTd3WUdMaGZUQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFhdGtWeFY0OApqM2dEek5NSnFXcklLaGRXaDE4eWI5akNxYWhMRGhHK3VmSEkxZFhHaWtkdEc5NDBPYitER1EzdGV2aEYrTENtCjljaEhJa1BmTlVaSDJ1YUNSN3lqTnR3UUY4a0hGeEhHdHZjblp3RTN5SmMxbWFGTjVZWHdPNlJCVmVCK0svL0sKOUF0dG80V3BwNUpNbWVpTEt3YUFIYnBHN3dpU1dmMFRiZHlWYXhuS1hjWnhPZm1oc0JsWW1wcHdPWjBHSUZVdQpOb0lOdGhaNWxHWHdvSnFieGJzQ09XNG9mSGMwOEl6WVpsZGF6KzFWcmtQcDlPVTJ3RVFkdXNPZ2dUZnU3K3AvCjhyUEpFeFNaQ3pPM2ZEYTRIdXJHTXN0ZlAwZCtpY0JjTlRtSWVIOTRhRjltTk1SNHJmVUl3VDZra2VuK3U2YlEKdUhLUlpGSFpIZ0JXTlE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
```
Выполнение команд из задания
```sh
developer@vm1:~/.kube$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-4q8bl   1/1     Running   0          8m46s
developer@vm1:~/.kube$ kubectl logs hello-node-7567d9fdc9-4q8bl
developer@vm1:~/.kube$ 
developer@vm1:~/.kube$ kubectl describe pod hello-node-7567d9fdc9-4q8bl
Name:         hello-node-7567d9fdc9-4q8bl
Namespace:    app-namespace
Priority:     0
Node:         devkub/10.128.0.11
Start Time:   Tue, 28 Dec 2021 08:27:08 +0000
Labels:       app=hello-node
              pod-template-hash=7567d9fdc9
Annotations:  <none>
Status:       Running
IP:           172.17.0.11
IPs:
  IP:           172.17.0.11
Controlled By:  ReplicaSet/hello-node-7567d9fdc9
Containers:
  echoserver:
    Container ID:   docker://f57f2640acae86d20f1ec30a31bdb856b19b5dbdc4e8ed5729a064b58d59434d
    Image:          k8s.gcr.io/echoserver:1.4
    Image ID:       docker-pullable://k8s.gcr.io/echoserver@sha256:5d99aa1120524c801bc8c1a7077e8f5ec122ba16b6dda1a5d3826057f67b9bcb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 28 Dec 2021 08:27:11 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6fgwp (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-6fgwp:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  9m35s  default-scheduler  Successfully assigned app-namespace/hello-node-7567d9fdc9-4q8bl to devkub
  Normal  Pulled     9m32s  kubelet            Container image "k8s.gcr.io/echoserver:1.4" already present on machine
  Normal  Created    9m32s  kubelet            Created container echoserver
  Normal  Started    9m32s  kubelet            Started container echoserver
```
## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)
```sh
user@vm1:~$ kubectl scale --replicas=5 deployment hello-node 
deployment.apps/hello-node scaled
user@vm1:~$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   5/5     5            5           4m48s
user@vm1:~$ kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-7567d9fdc9-4sln9   1/1     Running   0          4m55s
hello-node-7567d9fdc9-wxgtb   1/1     Running   0          26s
hello-node-7567d9fdc9-z47vc   1/1     Running   0          4m55s
hello-node-7567d9fdc9-z5lhd   1/1     Running   0          26s
hello-node-7567d9fdc9-zvgmf   1/1     Running   0          26s
```
---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
