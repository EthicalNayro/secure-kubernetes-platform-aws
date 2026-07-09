output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}


output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}


output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = module.ec2.public_ip
}


output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}