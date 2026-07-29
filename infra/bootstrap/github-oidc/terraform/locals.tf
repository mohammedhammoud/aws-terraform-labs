data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${data.aws_caller_identity.current.account_id}-${var.project_name}"
  github_roles = {
    apply = concat(
      ["repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"],
      [for env in var.github_environments : "repo:${var.github_repository}:environment:${env}"]
    )
    plan = ["repo:${var.github_repository}:pull_request"]
  }
}
