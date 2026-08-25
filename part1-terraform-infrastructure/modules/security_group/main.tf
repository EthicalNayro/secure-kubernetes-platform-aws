resource "aws_security_group" "k8s" {
  name        = "secure-k8s-sg"
  description = "Restricted access for the Kubernetes portfolio lab"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access from administrator CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Grafana NodePort from administrator CIDR"
    from_port   = 32000
    to_port     = 32000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Alertmanager NodePort from administrator CIDR"
    from_port   = 32001
    to_port     = 32001
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow outbound package, registry, and control-plane traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secure-k8s-sg"
  }
}
