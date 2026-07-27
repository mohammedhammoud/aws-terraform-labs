data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${data.aws_caller_identity.current.account_id}-${var.project_name}"
  github_roles = {
    apply = "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
    plan  = "repo:${var.github_repository}:pull_request"
  }
}
