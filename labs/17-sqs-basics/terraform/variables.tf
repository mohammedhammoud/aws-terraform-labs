variable "project_name" {
  type    = string
  default = "17-sqs-basics"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_timeout" {
  type    = number
  default = 10
}
