locals {
  state_key_namespace         = "aws-terraform-labs"
  name_prefix                 = "${var.project_name}-${var.environment}"
  az_count                    = length(var.availability_zones)
  backend_migration_image_tag = coalesce(var.backend_migration_image_tag, var.backend_image_tag)
  github_actions_apply_subjects = [
    "repo:${var.github_repository}:environment:${var.environment}"
  ]
  state_bucket_arn                = "arn:aws:s3:::${data.aws_caller_identity.current.account_id}-terraform-state-s3"
  state_key_prefix                = "${local.state_key_namespace}/${var.project_name}/${var.environment}/"
  state_object_arn                = "${local.state_bucket_arn}/${local.state_key_prefix}*"
  github_actions_apply_policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-terraform"

  ecr_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
