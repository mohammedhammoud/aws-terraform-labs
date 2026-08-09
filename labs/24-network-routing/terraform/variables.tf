variable "project_name" {
  type    = string
  default = "24-network-routing"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "my_ip" {
  type = string
}

variable "public_key" {
  type = string
}
