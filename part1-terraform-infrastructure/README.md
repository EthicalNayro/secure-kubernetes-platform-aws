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

```text
PS C:\Users\User\Downloads\DevOps Home Assignment> terraform apply
module.iam.data.aws_iam_role.ec2_role: Reading...
module.ec2.data.aws_ami.amazon_linux_2023: Reading...
module.iam.data.aws_iam_role.ec2_role: Read complete after 1s [id=Moveo-EC2Role]
module.ec2.data.aws_ami.amazon_linux_2023: Read complete after 1s [id=ami-00a84437cf2b97861]

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.ec2.aws_instance.k8s_node will be created
  + resource "aws_instance" "k8s_node" {
      + ami                                  = "ami-00a84437cf2b97861"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + force_destroy                        = false
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = "Moveo-EC2Role"
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.large"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_group_id                   = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + region                               = "eu-central-1"
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "k8s-node"
        }
      + tags_all                             = {
          + "Name" = "k8s-node"
        }
      + tenancy                              = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + primary_network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)

      + secondary_network_interface (known after apply)
    }

  # module.security_group.aws_security_group.k8s will be created
  + resource "aws_security_group" "k8s" {
      + arn                    = (known after apply)
      + description            = "Security group for Kubernetes node"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Allow all outbound traffic"
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "79.177.155.192/32",
                ]
              + description      = "SSH access"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "k8s-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + region                 = "eu-central-1"
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_internet_gateway.main will be created
  + resource "aws_internet_gateway" "main" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + region   = "eu-central-1"
      + tags     = {
          + "Name" = "k8s-igw"
        }
      + tags_all = {
          + "Name" = "k8s-igw"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_route_table.public will be created
  + resource "aws_route_table" "public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + region           = "eu-central-1"
      + route            = [
          + {
              + cidr_block                 = "0.0.0.0/0"
              + gateway_id                 = (known after apply)
                # (12 unchanged attributes hidden)
            },
        ]
      + tags             = {
          + "Name" = "k8s-public-route-table"
        }
      + tags_all         = {
          + "Name" = "k8s-public-route-table"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table_association.public will be created
  + resource "aws_route_table_association" "public" {
      + id             = (known after apply)
      + region         = "eu-central-1"
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_subnet.public will be created
  + resource "aws_subnet" "public" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-central-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block                                = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + region                                         = "eu-central-1"
      + tags                                           = {
          + "Name" = "k8s-public-subnet"
        }
      + tags_all                                       = {
          + "Name" = "k8s-public-subnet"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + region                               = "eu-central-1"
      + tags                                 = {
          + "Name" = "k8s-vpc"
        }
      + tags_all                             = {
          + "Name" = "k8s-vpc"
        }
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ec2_instance_id  = (known after apply)
  + ec2_public_ip    = (known after apply)
  + public_subnet_id = (known after apply)
  + vpc_id           = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

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

ec2_instance_id = "i-0745b38d03c375355"
ec2_public_ip = "3.72.35.241"
public_subnet_id = "subnet-051305dfb7a74ff95"
vpc_id = "vpc-0ede8b73b865cc1ab"
```
