variable "project_name" {
  type    = string
  default = "30-vpc-flow-logs"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
