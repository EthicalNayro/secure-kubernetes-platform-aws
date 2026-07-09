data "aws_ami" "amazon_linux_2023" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "al2023-ami-*-x86_64"
    ]
  }

  filter {
    name = "architecture"

    values = [
      "x86_64"
    ]
  }
}


resource "aws_instance" "k8s_node" {

  ami = data.aws_ami.amazon_linux_2023.id

  instance_type = var.instance_type

  subnet_id = var.subnet_id


  vpc_security_group_ids = [
    var.security_group_id
  ]


  iam_instance_profile = var.instance_profile_name


  associate_public_ip_address = true


  tags = {
    Name = "k8s-node"
  }
}