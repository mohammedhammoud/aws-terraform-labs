variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}

variable "project_name" {
  type    = string
  default = "ecs-fargate-e2e"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "backend_cpu" {
  type    = number
  default = 512
}

variable "backend_memory" {
  type    = number
  default = 1024
}

variable "backend_migration_cpu" {
  type    = number
  default = 256
}

variable "backend_migration_memory" {
  type    = number
  default = 512
}

variable "backend_port" {
  type    = number
  default = 3001
}

variable "backend_image_tag" {
  type = string
}

variable "backend_desired_count" {
  type    = number
  default = 2
}

variable "db_name" {
  type    = string
  default = "tododb"
}

variable "db_username" {
  type    = string
  default = "todouser"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "sns_email" {
  type      = string
  sensitive = true
}

variable "github_repository" {
  type    = string
  default = "mohammedhammoud@5408383/aws-terraform-labs@1293580188"
}
