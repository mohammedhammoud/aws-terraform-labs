variable "region" {
  type    = string
  default = "us-east-1"
}

variable "subnet_count" {
  type    = number
  default = 2
}

variable "ec2_ami" {
  type    = string
  default = "ami-amazonlinux2023"
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}
