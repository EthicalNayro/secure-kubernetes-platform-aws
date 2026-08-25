# Part 2: Kubernetes Bootstrap on Amazon Linux 2023

This phase installs containerd, Kubernetes, and Calico on the EC2 node created by Terraform.

## Run the bootstrap

```bash
chmod +x bootstrap-k8s.sh
sudo ./bootstrap-k8s.sh
```

The default versions are Kubernetes `v1.30` and Calico `v3.28.0`. They can be overridden without editing the script:

```bash
sudo KUBERNETES_MINOR=v1.30 CALICO_VERSION=v3.28.0 ./bootstrap-k8s.sh
```

## What the script configures

- Required kernel modules and `sysctl` networking settings
- Swap disabled for kubelet compatibility
- containerd with the systemd cgroup driver
- kubelet, kubeadm, and kubectl from the Kubernetes RPM repository
- A single-node control plane using `kubeadm init`
- kubectl access for `root` and `ec2-user`
- Calico installed through the Tigera operator
- Explicit readiness waits instead of fixed sleep-based timing

## Single-node scheduling

`kubeadm init` taints control-plane nodes with `NoSchedule`. Because this lab uses a single EC2 instance, the script removes that taint so the node can run both platform and application workloads.

This is appropriate for a portfolio lab. A production environment should keep control-plane and worker responsibilities separated and provide high availability.

## Verification

```bash
kubectl get nodes -o wide
kubectl get pods -A
```

Expected node state:

```text
NAME               STATUS   ROLES           VERSION
<KUBERNETES_NODE>  Ready    control-plane   v1.30.x
```

Calico, CoreDNS, kube-proxy, and the control-plane components should all reach a running or ready state.
