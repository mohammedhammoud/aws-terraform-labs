output "github_actions_apply_role_arn" {
  value = aws_iam_role.github_actions["apply"].arn
}

output "github_actions_plan_role_arn" {
  value = aws_iam_role.github_actions["plan"].arn
}
