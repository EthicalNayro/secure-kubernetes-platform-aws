# Part 1: AWS Infrastructure Provisioning with Terraform

This phase provisions the AWS foundation for a reproducible single-node Kubernetes lab. The configuration is modular, parameterized, and contains no account-specific IAM dependencies.

## Module layout

```text
part1-terraform-infrastructure/
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
└── modules/
    ├── vpc/
    ├── security_group/
    └── ec2/
```

## Provisioned resources

- Dedicated VPC with DNS support enabled
- Public subnet and Internet Gateway
- Public route table and subnet association
- Security Group restricted to the configured administrator CIDR
- Amazon Linux 2023 EC2 instance with an encrypted `gp3` root volume
- IMDSv2 enforcement on the EC2 instance

## Why a public subnet?

This repository is a portfolio lab that uses one EC2 node for both the Kubernetes control plane and workloads. A public subnet keeps the environment reproducible and allows the restricted NodePort demonstrations. A production platform should use private nodes, a managed ingress or load balancer, and high availability across multiple Availability Zones.

## Access rules

| Port | Purpose | Source |
| --- | --- | --- |
| 22 | SSH administration | `my_ip` only |
| 32000 | Grafana NodePort | `my_ip` only |
| 32001 | Alertmanager NodePort | `my_ip` only |

`my_ip` must be supplied as a CIDR, normally a single public address with a `/32` suffix.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Replace the example values before continuing.

terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

Sanitized output resembles:

```text
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:
ec2_instance_id = "<INSTANCE_ID>"
ec2_public_ip    = "<EC2_PUBLIC_IP>"
public_subnet_id = "<SUBNET_ID>"
vpc_id           = "<VPC_ID>"
```

## Inputs

| Variable | Description |
| --- | --- |
| `aws_region` | AWS region for the lab |
| `availability_zone` | Availability Zone for the public subnet |
| `vpc_cidr` | VPC CIDR block |
| `public_subnet_cidr` | Public subnet CIDR block |
| `my_ip` | Administrator public CIDR, normally `/32` |
| `instance_type` | EC2 instance type |
| `key_name` | Existing EC2 key-pair name used for SSH |

## Cleanup

```bash
terraform destroy
```
