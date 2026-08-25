variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet"
  type        = string
}

variable "my_ip" {
  description = "Administrator public CIDR allowed to access SSH and monitoring endpoints"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Kubernetes node"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair used for SSH access"
  type        = string
}
