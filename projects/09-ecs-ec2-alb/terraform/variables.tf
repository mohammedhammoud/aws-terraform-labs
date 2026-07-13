variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "09-ecs-ec2-alb"
}

variable "subnet_count" {
  type    = number
  default = 2
}
