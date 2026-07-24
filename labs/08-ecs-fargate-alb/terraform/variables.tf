variable "project_name" {
  type    = string
  default = "08-ecs-fargate-alb"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "fargate_cpu" {
  type    = string
  default = "256"
}

variable "fargate_memory" {
  type    = string
  default = "512"
}

variable "subnet_count" {
  type    = number
  default = 2
}

variable "desired_ecs_count" {
  type    = number
  default = 1
}
