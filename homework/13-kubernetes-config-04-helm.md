# Домашнее задание к занятию "13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"
В работе часто приходится применять системы автоматической генерации конфигураций. Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

## Задание 1: подготовить helm чарт для приложения
Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:
* каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
* в переменных чарта измените образ приложения для изменения версии.

[Helm chart](https://github.com/nchepurnenko/devops-netology/tree/main/homework/13.4/app)

## Задание 2: запустить 2 версии в разных неймспейсах
Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:
* одну версию в namespace=app1;
```bash
:::~/13/4$ helm install app01 app
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
NAME: app01
LAST DEPLOYED: Thu Feb 17 13:26:37 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
:::~/13/4$ k get po -n netology
NAME                   READY   STATUS    RESTARTS   AGE
app1-d86d7c9bb-x2pgt   1/1     Running   0          15m
```
* вторую версию в том же неймспейсе;
```bash
:::~/13/4$ helm install --set tag=1.1.1 app01 app
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
# С тем же именем не дает, пробую поменять имя
:::~/13/4$ helm install --set tag=1.1.1 app02 app
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists. Unable to continue with install: Namespace "netology" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "app02": current value is "app01"
# Так тоже не работает, можно сделать update, но рядом установить не получится
```
* третью версию в namespace=app2.
```bash
:::~/13/4$ helm install --set namespace=netology2,tag=1.1.2 app02 app
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/user/.kube/config
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/user/.kube/config
NAME: app02
LAST DEPLOYED: Thu Feb 17 13:50:44 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
:::~/13/4$ k get po -n netology2
NAME                   READY   STATUS    RESTARTS   AGE
app1-d86d7c9bb-nhl7d   1/1     Running   0          2m11s
```
