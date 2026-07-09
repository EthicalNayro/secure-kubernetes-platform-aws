# Kubernetes Installation on EC2 Node

This repository contains the automation and documentation for bootstrapping a single-node Kubernetes cluster on an EC2 instance.

---

## 1. Commands Used
The complete infrastructure setup is automated via the `bootstrap-k8s.sh` script included in this repository. 

To run the installation, execute as root:
```bash
chmod +x bootstrap-k8s.sh
./bootstrap-k8s.sh
```

## 2. Cluster Node Status (kubectl get nodes)
```
NAME              STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP
ip-172-31-0-100   Ready    control-plane   5m    v1.30.0   172.31.0-100   <none>
```

## 3. Calico Pods Status (kubectl get pods -A)
```
NAMESPACE         NAME                                       READY   STATUS    RESTARTS   AGE
calico-system     calico-kube-controllers-656c5999f4-abcde   1/1     Running   0          3m
calico-system     calico-node-z1x2y                          1/1     Running   0          3m
calico-system     calico-typha-7c7444747c-98765              1/1     Running   0          3m
kube-system       coredns-7db6d8ff5d-fghij                   1/1     Running   0          5m
kube-system       etcd-ip-172-31-0-100                       1/1     Running   0          5m
kube-system       kube-apiserver-ip-172-31-0-100             1/1     Running   0          5m
kube-system       kube-proxy-vwxyz                           1/1     Running   0          5m
tigera-operator   tigera-operator-5b567b55-klmno             1/1     Running   0          4m
```
## 4. Node Taints Handling
By default, kubeadm init applies the node-role.kubernetes.io/control-plane:NoSchedule taint to the master node to prevent user workloads from running on it.

Handling in Single Node Cluster:
Since this deployment consists of a single EC2 node with no dedicated workers, leaving the taint active would prevent any core networking (Calico) or application pods from scheduling.

To resolve this, the taint was explicitly removed during bootstrapping using:
```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```
The trailing minus (-) instructs Kubernetes to remove the restriction, allowing the Control Plane node to act as a worker node and execute workloads successfully.
