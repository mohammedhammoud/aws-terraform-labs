locals {
  state_key_namespace = "aws-terraform-labs"

  github_actions_plan_subjects = [
    "repo:${var.github_repository}:pull_request",
  ]

  ci_environments = toset(["dev", "stage", "prod"])

  workload_ci_stacks = {
    ecs-fargate = {
      name_prefix = "ecs-fargate"
      state_stack = "ecs-fargate"
    }
  }

  workload_ci_instances = {
    for instance in flatten([
      for stack_name, stack in local.workload_ci_stacks : [
        for environment in local.ci_environments : {
          key                         = "${stack_name}-${environment}"
          stack_name                  = stack_name
          environment                 = environment
          name_prefix                 = "${stack.name_prefix}-${environment}"
          state_key_prefix            = "${local.state_key_namespace}/${stack.state_stack}/${environment}/"
          apply_role_name             = "github-actions-${stack.name_prefix}-${environment}-terraform"
          apply_role_arn              = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-${stack.name_prefix}-${environment}-terraform"
          apply_policy_name           = "github-actions-${stack.name_prefix}-${environment}-terraform"
          apply_policy_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/github-actions-${stack.name_prefix}-${environment}-terraform"
          deploy_policy_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${stack.name_prefix}-${environment}-github-actions-deploy"
          workload_role_arn_pattern   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${stack.name_prefix}-${environment}-*"
          workload_policy_arn_pattern = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${stack.name_prefix}-${environment}-*"
          github_subject              = "repo:${var.github_repository}:environment:${environment}"
        }
      ]
    ]) : instance.key => instance
  }
}
