variable "project_name" {
  type    = string
  default = "13-rds-private"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "private_subnet_count" {
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

variable "db_name" {
  type    = string
  default = "labdb"
}

variable "db_username" {
  type    = string
  default = "labuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}


variable "db_port" {
  type    = number
  default = 7001
}
