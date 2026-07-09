variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
}

variable "my_ip" {
  description = "My public IP address for SSH access"
  type        = string
}

variable "role_name" {
  description = "Existing IAM role name"
  type        = string
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}