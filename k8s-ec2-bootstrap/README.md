# Kubernetes Installation on EC2 Node

This repository contains the automation and documentation for bootstrapping a single-node Kubernetes cluster on an EC2 instance.

---

## 1. Commands Used
The complete infrastructure setup is automated via the `bootstrap-k8s.sh` script included in this repository. 

To run the installation, execute as root:
```bash
chmod +x bootstrap-k8s.sh
./bootstrap-k8s.sh

2. Cluster Node Status (kubectl get nodes)
