locals {
  name_prefix = "${var.project_name}-${var.environment}"
  az_count    = length(var.availability_zones)
}
