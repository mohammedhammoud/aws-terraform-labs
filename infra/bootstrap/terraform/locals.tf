locals {
  state_key_namespace = "aws-terraform-labs"

  github_actions_plan_subjects = [
    "repo:${var.github_repository}:pull_request",
  ]
}
