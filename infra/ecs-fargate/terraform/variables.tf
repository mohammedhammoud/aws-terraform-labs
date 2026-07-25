variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}

variable "project_name" {
  type    = string
  default = "todo-platform-fargate"
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


