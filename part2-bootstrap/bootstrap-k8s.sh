#!/usr/bin/env bash

set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root: sudo ./bootstrap-k8s.sh" >&2
  exit 1
fi

KUBERNETES_MINOR="${KUBERNETES_MINOR:-v1.30}"
CALICO_VERSION="${CALICO_VERSION:-v3.28.0}"

dnf update -y
dnf install -y containerd git vim wget

swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

cat <<'EOF' > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<'EOF' > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sed -Ei 's#sandbox_image = "registry.k8s.io/pause:[^"]+"#sandbox_image = "registry.k8s.io/pause:3.9"#' /etc/containerd/config.toml
systemctl enable --now containerd

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${KUBERNETES_MINOR}/rpm/repodata/repomd.xml.key
EOF

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet

kubeadm init --pod-network-cidr=192.168.0.0/16

install -d -m 0700 /root/.kube
install -m 0600 /etc/kubernetes/admin.conf /root/.kube/config
export KUBECONFIG=/root/.kube/config

install -d -o ec2-user -g ec2-user -m 0700 /home/ec2-user/.kube
install -o ec2-user -g ec2-user -m 0600 /etc/kubernetes/admin.conf /home/ec2-user/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

kubectl apply -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml"
kubectl wait --for=condition=Established crd/installations.operator.tigera.io --timeout=180s
kubectl apply -f "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml"

kubectl wait --for=condition=Ready nodes --all --timeout=300s
kubectl get nodes -o wide
kubectl get pods -A
