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

2. Cluster Node Status (kubectl get nodes)
```
NAME              STATUS   ROLES           AGE   VERSION   INTERNAL-IP    EXTERNAL-IP
ip-172-31-0-100   Ready    control-plane   5m    v1.30.0   172.31.0-100   <none>
```
