data "aws_caller_identity" "current" {}

data "aws_iam_role" "github_actions_apply" {
  name = "${data.aws_caller_identity.current.account_id}-github-oidc-github-actions-apply"
}

data "aws_iam_role" "github_actions_plan" {
  name = "${data.aws_caller_identity.current.account_id}-github-oidc-github-actions-plan"
}
