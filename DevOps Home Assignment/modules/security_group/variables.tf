variable "vpc_id" {
  description = "VPC ID where security group will be created"
  type        = string
}

variable "my_ip" {
  description = "Allowed IP for SSH access"
  type        = string
}