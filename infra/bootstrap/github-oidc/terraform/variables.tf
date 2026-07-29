variable "project_name" {
  type    = string
  default = "github-oidc"
}

variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "github_repository" {
  type    = string
  default = "mohammedhammoud@5408383/aws-terraform-labs@1293580188"
}

variable "github_branch" {
  type    = string
  default = "master"
}

variable "github_environments" {
  type    = list(string)
  default = ["dev", "stage", "prod"]

  validation {
    condition     = alltrue([for env in var.github_environments : trimspace(env) != ""])
    error_message = "github_environments must not contain empty values."
  }
}
