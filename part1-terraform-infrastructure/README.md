# Part 1: Infrastructure Provisioning (Terraform)

This component provisions a lightweight, highly secure cloud infrastructure on AWS for a single-node Kubernetes cluster using modular Terraform configuration.

---

## 1. Module Layout
The infrastructure is designed using a clean, modular layout to ensure maintainability and reusability:

```text
part1-terraform-infrastructure/
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

## Terraform apply output

```text
module.vpc.aws_vpc.main: Creating...
module.vpc.aws_vpc.main: Creation complete after 2s [id=vpc-0ede8b73b865cc1ab]
module.vpc.aws_internet_gateway.main: Creating...
module.vpc.aws_subnet.public: Creating...
module.security_group.aws_security_group.k8s: Creating...
module.vpc.aws_internet_gateway.main: Creation complete after 1s [id=igw-01dc41941a83be6eb]
module.vpc.aws_route_table.public: Creating...
module.vpc.aws_route_table.public: Creation complete after 1s [id=rtb-09558e17e031ff7df]
module.security_group.aws_security_group.k8s: Creation complete after 3s [id=sg-032b9dd1c7847496f]
module.vpc.aws_subnet.public: Still creating... [00m10s elapsed]
module.vpc.aws_subnet.public: Creation complete after 11s [id=subnet-051305dfb7a74ff95]
module.vpc.aws_route_table_association.public: Creating...
module.ec2.aws_instance.k8s_node: Creating...
module.vpc.aws_route_table_association.public: Creation complete after 1s [id=rtbassoc-0626cff5287bc287b]
module.ec2.aws_instance.k8s_node: Still creating... [00m10s elapsed]
module.ec2.aws_instance.k8s_node: Still creating... [00m20s elapsed]
module.ec2.aws_instance.k8s_node: Creation complete after 23s [id=i-0745b38d03c375355]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

ec2_instance_id = "i-0ef95460a489ea144"
ec2_public_ip = "18.197.168.228"
public_subnet_id = "subnet-051305dfb7a74ff95"
vpc_id = "vpc-0ede8b73b865cc1ab"
```
