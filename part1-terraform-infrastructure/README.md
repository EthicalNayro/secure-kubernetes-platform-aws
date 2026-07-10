terraform-k8s/
│
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
│
└── modules/
    │
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security_group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── iam/
    │   ├── main.tf
    │   └── variables.tf
    │
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
