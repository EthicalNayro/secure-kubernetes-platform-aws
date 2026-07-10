# Part 1: Infrastructure Provisioning (Terraform)

This component provisions a lightweight, highly secure cloud infrastructure on AWS for a single-node Kubernetes cluster using modular Terraform configuration.

---

## 1. Module Layout
The infrastructure is designed using a clean, modular layout to ensure maintainability and reusability:

```text
part1-terraform/
├── main.tf                 # Root configuration calling the infrastructure modules
├── variables.tf            # Global input variables (e.g., Region, IP ranges)
├── outputs.tf              # Root outputs exposing infrastructure metadata
└── modules/
    ├── vpc/                # Provisions VPC, Public Subnet, IGW, and Route Tables
    ├── security_group/     # Configures strict Ingress/Egress firewall rules
    ├── iam/                # Fetches and builds the instance profile using Moveo-EC2Role
    └── ec2/                # Launches the t3.large instance with AMIL2023 & gp3 storage
```

## 2. Design Choices Explanation
Network Isolation: A dedicated VPC (10.0.0.0/16) is isolated from default resources. It utilizes a single public subnet (10.0.1.0/24) mapped to an Internet Gateway to host our control plane while serving external routing requirements easily.

Security & Ingress Restriction: * SSH (Port 22): Locked down strictly to the administrator's specific source IP (My ip) rather than being open to the world (0.0.0.0/0), heavily mitigating brute-force vectors.

Egress: Full outbound traffic is permitted to enable the node to fetch container images, package updates, and communicate with external registries seamlessly during bootstrapping.

Operating System & Performance: Leverages the latest native Amazon Linux 2023 AMI optimized for AWS ecosystems, running on a stable t3.large profile to comfortably satisfy core kubeadm scheduling and control-plane memory baselines.

Privileged Identity Integration: An aws_iam_instance_profile wrapper was built dynamically to automatically bind the pre-existing, pre-authorized Moveo-EC2Role to the EC2 instance without hardcoding active long-term credentials.
