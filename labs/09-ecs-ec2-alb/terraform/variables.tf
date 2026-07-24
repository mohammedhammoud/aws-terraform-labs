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

variable "desired_task_count" {
  type    = number
  default = 2
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_ami" {
  type    = string
  default = "ami-amazonlinux2023"
}

variable "autoscaling_min_size" {
  type    = number
  default = 2

}
variable "autoscaling_desired_capacity" {
  type    = number
  default = 2
}

variable "autoscaling_max_size" {
  type    = number
  default = 4
}
