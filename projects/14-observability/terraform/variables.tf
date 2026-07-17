variable "project_name" {
  type    = string
  default = "14-observability"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ec2_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "sns_email" {
  type = string
}

variable "alarm_threshold" {
  type    = number
  default = 80
}

variable "alarm_period" {
  type    = number
  default = 60
}

variable "alarm_evaluation_periods" {
  type    = number
  default = 2
}