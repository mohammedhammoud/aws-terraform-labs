data "aws_iam_policy_document" "ecs_fargate_github_actions_apply" {
  for_each = local.ecs_fargate_ci_instances

  source_policy_documents = [
    data.aws_iam_policy_document.ecs_base[each.key].json,
  ]
}

resource "aws_iam_role" "ecs_fargate_github_actions_apply" {
  for_each = local.ecs_fargate_ci_instances

  name               = each.value.apply_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_github_actions_apply_assume_role[each.key].json
}

resource "aws_iam_policy" "ecs_fargate_github_actions_apply" {
  for_each = local.ecs_fargate_ci_instances

  name   = each.value.apply_policy_name
  policy = data.aws_iam_policy_document.ecs_fargate_github_actions_apply[each.key].json
}

resource "aws_iam_role_policy_attachment" "ecs_fargate_github_actions_apply" {
  for_each = local.ecs_fargate_ci_instances

  role       = aws_iam_role.ecs_fargate_github_actions_apply[each.key].name
  policy_arn = aws_iam_policy.ecs_fargate_github_actions_apply[each.key].arn
}
