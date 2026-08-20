locals {
  name_prefix                    = "${var.project_name}-${var.environment}"
  az_count                       = length(var.availability_zones)
  github_actions_apply_role_name = "github-actions-${var.project_name}-${var.environment}-terraform"
}
