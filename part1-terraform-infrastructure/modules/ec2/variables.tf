variable "subnet_id" {
  description = "Subnet where EC2 will be created"
  type        = string
}


variable "security_group_id" {
  description = "Security group attached to EC2"
  type        = string
}


variable "instance_profile_name" {
  description = "IAM instance profile attached to EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}