variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID attached to the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key-pair name used for SSH access"
  type        = string
}
