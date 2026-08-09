resource "aws_key_pair" "ec2" {
  key_name   = "${var.project_name}-key"
  public_key = var.public_key
}
