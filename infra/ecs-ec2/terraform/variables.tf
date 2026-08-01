variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}

variable "project_name" {
  type    = string
  default = "ecs-ec2"
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

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones must be provided."
  }

  validation {
    condition = alltrue([
      for az in var.availability_zones :
      startswith(az, var.region)
    ])

    error_message = "Each availability zone must belong to the selected region."
  }

  validation {
    condition     = length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "Availability zones must be unique."
  }
}

variable "frontend_cpu" {
  type    = number
  default = 256
}

variable "frontend_memory" {
  type    = number
  default = 512
}

variable "frontend_port" {
  type    = number
  default = 80
}

variable "frontend_image_tag" {
  type = string
}

variable "backend_cpu" {
  type    = number
  default = 512
}

variable "backend_memory" {
  type    = number
  default = 1024
}

variable "backend_port" {
  type    = number
  default = 3001
}

variable "backend_image_tag" {
  type = string
}

variable "backend_migration_image_tag" {
  type    = string
  default = null
}

variable "frontend_desired_count" {
  type    = number
  default = 1
}

variable "backend_desired_count" {
  type    = number
  default = 1
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

variable "ec2_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "autoscaling_min_size" {
  type    = number
  default = 1

}
variable "autoscaling_desired_capacity" {
  type    = number
  default = 1
}

variable "autoscaling_max_size" {
  type    = number
  default = 2
}
