resource "aws_cloudwatch_log_group" "ecs_backend" {
  name              = "/ecs/${local.name_prefix}-backend"
  retention_in_days = 14
}

