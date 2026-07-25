resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${local.name_prefix}/backend"
  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}-backend-log-group"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${local.name_prefix}/frontend"
  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}-frontend-log-group"
  }
}
