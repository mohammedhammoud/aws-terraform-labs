output "github_actions_plan_role_arn" {
  value = aws_iam_role.github_actions_plan.arn
}

output "ecs_fargate_github_actions_apply_role_arns" {
  value = {
    for key, role in aws_iam_role.workload_github_actions_apply :
    local.workload_ci_instances[key].environment => role.arn
    if local.workload_ci_instances[key].stack_name == "ecs-fargate"
  }
}

output "ecs_ec2_github_actions_apply_role_arns" {
  value = {
    for key, role in aws_iam_role.workload_github_actions_apply :
    local.workload_ci_instances[key].environment => role.arn
    if local.workload_ci_instances[key].stack_name == "ecs-ec2"
  }
}
