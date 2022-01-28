# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
```
плагин был установлен при первоналчальном развертывании
```
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

- установил hello-node
```
kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4

```
- создал политику
```
root@node1:~# cat net.yml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-traffic-to-hello-world
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: hello-node
  ingress:
  - {}
  policyTypes:
  - Ingress
```
- применил политику:
```
root@node1:~# kubectl apply -f net.yml
root@node1:~# kubectl get networkpolicies
NAME                           POD-SELECTOR     AGE
allow-traffic-to-hello-world   app=hello-node   12m
```


## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.
```
root@node1:/usr/local/bin# calicoctl --allow-version-mismatch get nodes --output wide
NAME    ASN       IPV4            IPV6
node1   (64512)   10.2.35.4/24
node2   (64512)   10.2.35.33/24
node3   (64512)   10.2.35.31/24
  
root@node1:/usr/local/bin# calicoctl --allow-version-mismatch get ippool --output wide
NAME           CIDR             NAT    IPIPMODE   VXLANMODE   DISABLED   DISABLEBGPEXPORT   SELECTOR
default-pool   10.233.64.0/18   true   Always     Never       false      false              all()
  
root@node1:/usr/local/bin# calicoctl --allow-version-mismatch get profile --output wide
NAME                                                 LABELS
projectcalico-default-allow
kns.default                                          pcns.kubernetes.io/metadata.name=default,pcns.projectcalico.org/name=default
kns.kube-node-lease                                  pcns.kubernetes.io/metadata.name=kube-node-lease,pcns.projectcalico.org/name=kube-node-lease
kns.kube-public                                      pcns.kubernetes.io/metadata.name=kube-public,pcns.projectcalico.org/name=kube-public
kns.kube-system                                      pcns.kubernetes.io/metadata.name=kube-system,pcns.projectcalico.org/name=kube-system
ksa.default.default                                  pcsa.projectcalico.org/name=default
ksa.kube-node-lease.default                          pcsa.projectcalico.org/name=default
ksa.kube-public.default                              pcsa.projectcalico.org/name=default
ksa.kube-system.attachdetach-controller              pcsa.projectcalico.org/name=attachdetach-controller
ksa.kube-system.bootstrap-signer                     pcsa.projectcalico.org/name=bootstrap-signer
ksa.kube-system.calico-kube-controllers              pcsa.projectcalico.org/name=calico-kube-controllers
ksa.kube-system.calico-node                          pcsa.projectcalico.org/name=calico-node
ksa.kube-system.certificate-controller               pcsa.projectcalico.org/name=certificate-controller
ksa.kube-system.clusterrole-aggregation-controller   pcsa.projectcalico.org/name=clusterrole-aggregation-controller
ksa.kube-system.coredns                              pcsa.addonmanager.kubernetes.io/mode=Reconcile,pcsa.projectcalico.org/name=coredns
ksa.kube-system.cronjob-controller                   pcsa.projectcalico.org/name=cronjob-controller
ksa.kube-system.daemon-set-controller                pcsa.projectcalico.org/name=daemon-set-controller
ksa.kube-system.default                              pcsa.projectcalico.org/name=default
ksa.kube-system.deployment-controller                pcsa.projectcalico.org/name=deployment-controller
ksa.kube-system.disruption-controller                pcsa.projectcalico.org/name=disruption-controller
ksa.kube-system.dns-autoscaler                       pcsa.addonmanager.kubernetes.io/mode=Reconcile,pcsa.projectcalico.org/name=dns-autoscaler
ksa.kube-system.endpoint-controller                  pcsa.projectcalico.org/name=endpoint-controller
ksa.kube-system.endpointslice-controller             pcsa.projectcalico.org/name=endpointslice-controller
ksa.kube-system.endpointslicemirroring-controller    pcsa.projectcalico.org/name=endpointslicemirroring-controller
ksa.kube-system.ephemeral-volume-controller          pcsa.projectcalico.org/name=ephemeral-volume-controller
ksa.kube-system.expand-controller                    pcsa.projectcalico.org/name=expand-controller
ksa.kube-system.generic-garbage-collector            pcsa.projectcalico.org/name=generic-garbage-collector
ksa.kube-system.horizontal-pod-autoscaler            pcsa.projectcalico.org/name=horizontal-pod-autoscaler
ksa.kube-system.job-controller                       pcsa.projectcalico.org/name=job-controller
ksa.kube-system.kube-proxy                           pcsa.projectcalico.org/name=kube-proxy
ksa.kube-system.namespace-controller                 pcsa.projectcalico.org/name=namespace-controller
ksa.kube-system.node-controller                      pcsa.projectcalico.org/name=node-controller
ksa.kube-system.nodelocaldns                         pcsa.addonmanager.kubernetes.io/mode=Reconcile,pcsa.projectcalico.org/name=nodelocaldns
ksa.kube-system.persistent-volume-binder             pcsa.projectcalico.org/name=persistent-volume-binder
ksa.kube-system.pod-garbage-collector                pcsa.projectcalico.org/name=pod-garbage-collector
ksa.kube-system.pv-protection-controller             pcsa.projectcalico.org/name=pv-protection-controller
ksa.kube-system.pvc-protection-controller            pcsa.projectcalico.org/name=pvc-protection-controller
ksa.kube-system.replicaset-controller                pcsa.projectcalico.org/name=replicaset-controller
ksa.kube-system.replication-controller               pcsa.projectcalico.org/name=replication-controller
ksa.kube-system.resourcequota-controller             pcsa.projectcalico.org/name=resourcequota-controller
ksa.kube-system.root-ca-cert-publisher               pcsa.projectcalico.org/name=root-ca-cert-publisher
ksa.kube-system.service-account-controller           pcsa.projectcalico.org/name=service-account-controller
ksa.kube-system.service-controller                   pcsa.projectcalico.org/name=service-controller
ksa.kube-system.statefulset-controller               pcsa.projectcalico.org/name=statefulset-controller
ksa.kube-system.token-cleaner                        pcsa.projectcalico.org/name=token-cleaner
ksa.kube-system.ttl-after-finished-controller        pcsa.projectcalico.org/name=ttl-after-finished-controller
ksa.kube-system.ttl-controller                       pcsa.projectcalico.org/name=ttl-controller
```
