variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ec2_ami" {
  type    = string
  default = "ami-amazonlinux2023"
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}
