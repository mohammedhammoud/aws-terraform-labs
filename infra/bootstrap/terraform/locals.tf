locals {
  state_key_namespace = "aws-terraform-labs"

  github_actions_plan_subjects = [
    "repo:${var.github_repository}:pull_request",
  ]

  ci_environments = toset(["dev", "stage", "prod"])

  ecs_fargate_ci_instances = {
    for environment in local.ci_environments : "ecs-fargate-${environment}" => {
      stack_name                  = "ecs-fargate"
      environment                 = environment
      name_prefix                 = "ecs-fargate-${environment}"
      state_key_prefix            = "${local.state_key_namespace}/ecs-fargate/${environment}/"
      apply_role_name             = "github-actions-ecs-fargate-${environment}-terraform"
      apply_role_arn              = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-ecs-fargate-${environment}-terraform"
      apply_policy_name           = "github-actions-ecs-fargate-${environment}-terraform"
      apply_policy_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/github-actions-ecs-fargate-${environment}-terraform"
      deploy_policy_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-fargate-${environment}-github-actions-deploy"
      workload_role_arn_pattern   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-fargate-${environment}-*"
      workload_policy_arn_pattern = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-fargate-${environment}-*"
      github_subject              = "repo:${var.github_repository}:environment:${environment}"
    }
  }

  ecs_ec2_ci_instances = {
    for environment in local.ci_environments : "ecs-ec2-${environment}" => {
      stack_name                  = "ecs-ec2"
      environment                 = environment
      name_prefix                 = "ecs-ec2-${environment}"
      state_key_prefix            = "${local.state_key_namespace}/ecs-ec2/${environment}/"
      apply_role_name             = "github-actions-ecs-ec2-${environment}-terraform"
      apply_role_arn              = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-ecs-ec2-${environment}-terraform"
      apply_policy_name           = "github-actions-ecs-ec2-${environment}-terraform"
      apply_policy_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/github-actions-ecs-ec2-${environment}-terraform"
      deploy_policy_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-ec2-${environment}-github-actions-deploy"
      workload_role_arn_pattern   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-ec2-${environment}-*"
      workload_policy_arn_pattern = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-ec2-${environment}-*"
      ec2_instance_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-ec2-${environment}-ec2"
      instance_profile_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/ecs-ec2-${environment}-ec2-profile"
      github_subject              = "repo:${var.github_repository}:environment:${environment}"
    }
  }

  ecs_fargate_e2e_ci_instances = {
    for environment in local.ci_environments : "ecs-fargate-e2e-${environment}" => {
      stack_name                  = "ecs-fargate-e2e"
      environment                 = environment
      name_prefix                 = "ecs-fargate-e2e-${environment}"
      state_key_prefix            = "${local.state_key_namespace}/ecs-fargate-e2e/${environment}/"
      apply_role_name             = "github-actions-ecs-fargate-e2e-${environment}-terraform"
      apply_role_arn              = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-actions-ecs-fargate-e2e-${environment}-terraform"
      apply_policy_name           = "github-actions-ecs-fargate-e2e-${environment}-terraform"
      apply_policy_arn            = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/github-actions-ecs-fargate-e2e-${environment}-terraform"
      deploy_policy_arn           = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-fargate-e2e-${environment}-github-actions-deploy"
      workload_role_arn_pattern   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs-fargate-e2e-${environment}-*"
      workload_policy_arn_pattern = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ecs-fargate-e2e-${environment}-*"
      github_subject              = "repo:${var.github_repository}:environment:${environment}"
    }
  }

  workload_ci_instances = merge(
    local.ecs_fargate_ci_instances,
    local.ecs_fargate_e2e_ci_instances,
    local.ecs_ec2_ci_instances,
  )
}
