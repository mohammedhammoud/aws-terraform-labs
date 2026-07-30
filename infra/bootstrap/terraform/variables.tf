variable "project_name" {
  type    = string
  default = "bootstrap"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "state_bucket_name" {
  type    = string
  default = "455394301478-terraform-state-s3"
}

variable "github_repository" {
  type    = string
  default = "mohammedhammoud@5408383/aws-terraform-labs@1293580188"
}

variable "github_actions_plan_role_name" {
  type    = string
  default = "aws-terraform-labs-plan"
}

