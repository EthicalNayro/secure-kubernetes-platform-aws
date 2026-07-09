data "aws_iam_role" "ec2_role" {
  name = var.role_name
}


resource "aws_iam_instance_profile" "ec2" {
  name = "${var.role_name}-profile"
  role = data.aws_iam_role.ec2_role.name
}