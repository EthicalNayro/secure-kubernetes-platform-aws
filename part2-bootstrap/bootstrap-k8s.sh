```bash
#!/usr/bin/env bash

set -euxo pipefail

# --- Step 1: Install Required Prerequisites ---

# Update system packages and install basic tools (curl skipped due to curl-minimal conflict)
dnf update -y
dnf install -y wget git vim

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Load kernel modules
cat <<'EOF' > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Configure sysctl settings required by Kubernetes
cat <<'EOF' > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# Install and configure Containerd
dnf install -y containerd

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# Use systemd as cgroup driver (recommended for Kubernetes)
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable --now containerd


# --- Step 2: Bootstrap Single Node Kubernetes Cluster ---

# Configure Kubernetes repository
cat <<'EOF' > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF

# Install Kubernetes components
dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

# Initialize Kubernetes control-plane node
kubeadm init --pod-network-cidr=192.168.0.0/16

# Configure kubectl for ec2-user
mkdir -p /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

# Configure kubectl for root (ensures script steps complete successfully)
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

export KUBECONFIG=/root/.kube/config

# Allow workloads to run on the single control-plane node (Remove Taint)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-


# --- Step 3: Install Calico using Helm ---

# Install Helm CLI
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Deploy Calico CNI
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update

helm install calico projectcalico/tigera-operator \
  --namespace tigera-operator \
  --create-namespace

# Verify installation
kubectl wait \
  --for=condition=Ready pods \
  --all \
  -n calico-system \
  --timeout=300s || true

kubectl get nodes -o wide
kubectl get pods -A
```
