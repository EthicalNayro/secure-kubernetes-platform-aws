# Kubernetes Installation on EC2 Node

This repository contains the automation and documentation for bootstrapping a single-node Kubernetes cluster on an EC2 instance.

## 1. Commands Used

The complete infrastructure setup is automated via the `bootstrap-k8s.sh` script included in this repository.

To run the installation, execute as root:

```bash
chmod +x bootstrap-k8s.sh
sudo ./bootstrap-k8s.sh
```

## 2. Cluster Node Status (kubectl get nodes)
```
NAME                                          STATUS   ROLES           AGE     VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION                  CONTAINER-RUNTIME
ip-10-0-1-237.eu-central-1.compute.internal   Ready    control-plane   9m13s   v1.30.14   10.0.1.237    <none>        Amazon Linux 2023.12.20260706   6.1.176-220.360.amzn2023.x86_64   containerd://2.2.5+unknown
```

## 3. Calico Pods Status (kubectl get pods -A)
```
NAMESPACE          NAME                                                                  READY   STATUS    RESTARTS        AGE
calico-apiserver   calico-apiserver-78d54b99b4-29489                                     1/1     Running   0               2m48s
calico-apiserver   calico-apiserver-78d54b99b4-l79fd                                     1/1     Running   0               2m48s
calico-system      calico-kube-controllers-6847d4c58f-g8mkx                              1/1     Running   0               3m22s
calico-system      calico-node-qgwpm                                                     1/1     Running   0               3m22s
calico-system      calico-typha-648689f9cd-rwzg9                                         1/1     Running   0               3m23s
calico-system      csi-node-driver-j4tb7                                                 2/2     Running   0               3m22s
kube-system        coredns-55cb58b774-m57cl                                              1/1     Running   0               9m30s
kube-system        coredns-55cb58b774-zm4xd                                              1/1     Running   0               9m30s
kube-system        etcd-ip-10-0-1-237.eu-central-1.compute.internal                      1/1     Running   4 (5m56s ago)   7m49s
kube-system        kube-apiserver-ip-10-0-1-237.eu-central-1.compute.internal            1/1     Running   4 (6m ago)      9m47s
kube-system        kube-controller-manager-ip-10-0-1-237.eu-central-1.compute.internal   1/1     Running   4 (6m20s ago)   7m49s
kube-system        kube-proxy-xkwmz                                                      1/1     Running   2 (5m51s ago)   9m30s
kube-system        kube-scheduler-ip-10-0-1-237.eu-central-1.compute.internal            1/1     Running   3 (5m56s ago)   10m
tigera-operator    tigera-operator-76ff79f7fd-rxcld                                      1/1     Running   0               3m29s
```
## 4. Node Taints Handling
By default, kubeadm init applies the node-role.kubernetes.io/control-plane:NoSchedule taint to the master node to prevent user workloads from running on it.

Handling in Single Node Cluster: Since this deployment consists of a single EC2 node with no dedicated workers, leaving the taint active would prevent any core networking (Calico) or application pods from scheduling.

To resolve this, the taint was explicitly removed during bootstrapping using:
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
### Removing the taint allows the scheduler to place workloads on the Control Plane node, effectively allowing it to serve both as a control-plane and workload node.
