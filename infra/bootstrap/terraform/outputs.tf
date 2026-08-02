output "github_actions_plan_role_arn" {
  value = aws_iam_role.github_actions_plan.arn
}

output "ecs_fargate_github_actions_apply_role_arns" {
  value = {
    for key, role in aws_iam_role.ecs_fargate_github_actions_apply :
    local.ecs_fargate_ci_instances[key].environment => role.arn
  }
}

output "ecs_ec2_github_actions_apply_role_arns" {
  value = {
    for key, role in aws_iam_role.ecs_ec2_github_actions_apply :
    local.ecs_ec2_ci_instances[key].environment => role.arn
  }
}
