locals {
  name_prefix                 = "${var.project_name}-${var.environment}"
  apply_role_name             = "github-actions-${var.project_name}-${var.environment}-terraform"
  az_count                    = length(var.availability_zones)
  backend_migration_image_tag = coalesce(var.backend_migration_image_tag, var.backend_image_tag)
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
  ecs_services = {
    backend = aws_ecs_service.backend
  }
  alb_target_groups = {
    backend = aws_lb_target_group.backend
  }
}
