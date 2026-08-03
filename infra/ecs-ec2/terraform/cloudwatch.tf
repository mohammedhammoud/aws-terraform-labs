resource "aws_cloudwatch_log_group" "ecs" {
  for_each          = toset(["backend"])
  name              = "/ecs/${local.name_prefix}/${each.value}"
  retention_in_days = 14
  tags = {
    Name = "${local.name_prefix}-${each.value}-log-group"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_memory" {
  for_each = local.ecs_services

  alarm_name        = "${local.name_prefix}-${each.key}-high-memory"
  alarm_description = "ECS ${each.key} memory utilization is above 80%."

  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"

  threshold          = 80
  period             = 60
  evaluation_periods = 5

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = each.value.name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${local.name_prefix}-${each.key}-high-memory"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  for_each = local.ecs_services

  alarm_name        = "${local.name_prefix}-${each.key}-high-cpu"
  alarm_description = "ECS ${each.key} cpu utilization is above 80%."

  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"

  threshold          = 80
  period             = 60
  evaluation_periods = 5

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = each.value.name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${local.name_prefix}-${each.key}-high-cpu"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  for_each = local.alb_target_groups

  alarm_name        = "${local.name_prefix}-${each.key}-target-5xx"
  alarm_description = "ALB target group ${each.key} returned 5XX responses."

  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"

  threshold          = 5
  period             = 60
  evaluation_periods = 2

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = each.value.arn_suffix
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${local.name_prefix}-${each.key}-target-5xx"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  for_each = local.alb_target_groups

  alarm_name        = "${local.name_prefix}-${each.key}-unhealthy-targets"
  alarm_description = "ALB target group ${each.key} has unhealthy targets."

  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  comparison_operator = "GreaterThanThreshold"

  threshold          = 0
  period             = 60
  evaluation_periods = 2

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = each.value.arn_suffix
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${local.name_prefix}-${each.key}-unhealthy-targets"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name        = "${local.name_prefix}-rds-high-cpu"
  alarm_description = "RDS CPU utilization is above 80%."

  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"

  threshold          = 80
  period             = 60
  evaluation_periods = 5

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${local.name_prefix}-rds-high-cpu"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name        = "${local.name_prefix}-rds-high-connections"
  alarm_description = "RDS database connections are above 80."

  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  statistic           = "Maximum"
  comparison_operator = "GreaterThanThreshold"

  threshold          = 80
  period             = 60
  evaluation_periods = 5

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${local.name_prefix}-rds-high-connections"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name        = "${local.name_prefix}-rds-low-storage"
  alarm_description = "RDS free storage is below 2 GiB."

  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Minimum"
  comparison_operator = "LessThanThreshold"

  threshold          = 2 * 1024 * 1024 * 1024
  period             = 300
  evaluation_periods = 2

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    Name = "${local.name_prefix}-rds-low-storage"
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "ECS CPU Utilization"
          region = var.region
          stat   = "Average"
          period = 60

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              aws_ecs_cluster.main.name,
              "ServiceName",
              aws_ecs_service.backend.name
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "ECS Memory Utilization"
          region = var.region
          stat   = "Average"
          period = 60

          metrics = [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              aws_ecs_cluster.main.name,
              "ServiceName",
              aws_ecs_service.backend.name
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "ALB Target 5XX"
          region = var.region
          stat   = "Sum"
          period = 60

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "LoadBalancer",
              aws_lb.main.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.backend.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "ALB Unhealthy Targets"
          region = var.region
          stat   = "Maximum"
          period = 60

          metrics = [
            [
              "AWS/ApplicationELB",
              "UnHealthyHostCount",
              "LoadBalancer",
              aws_lb.main.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.backend.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          title  = "ALB Target Response Time"
          region = var.region
          stat   = "Average"
          period = 60

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              aws_lb.main.arn_suffix,
              "TargetGroup",
              aws_lb_target_group.backend.arn_suffix
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 8
        height = 6

        properties = {
          title  = "RDS CPU Utilization"
          region = var.region
          stat   = "Average"
          period = 60

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              aws_db_instance.main.identifier
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 18
        width  = 8
        height = 6

        properties = {
          title  = "RDS Connections"
          region = var.region
          stat   = "Maximum"
          period = 60

          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              aws_db_instance.main.identifier
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 18
        width  = 8
        height = 6

        properties = {
          title  = "RDS Free Storage"
          region = var.region
          stat   = "Minimum"
          period = 300

          metrics = [
            [
              "AWS/RDS",
              "FreeStorageSpace",
              "DBInstanceIdentifier",
              aws_db_instance.main.identifier
            ]
          ]
        }
      },
      {
        type   = "alarm"
        x      = 0
        y      = 24
        width  = 24
        height = 6

        properties = {
          title = "CloudWatch Alarms"

          alarms = concat(
            [for alarm in values(aws_cloudwatch_metric_alarm.ecs_high_cpu) : alarm.arn],
            [for alarm in values(aws_cloudwatch_metric_alarm.ecs_high_memory) : alarm.arn],
            [for alarm in values(aws_cloudwatch_metric_alarm.alb_target_5xx) : alarm.arn],
            [for alarm in values(aws_cloudwatch_metric_alarm.alb_unhealthy_targets) : alarm.arn],
            [
              aws_cloudwatch_metric_alarm.rds_high_cpu.arn,
              aws_cloudwatch_metric_alarm.rds_high_connections.arn,
              aws_cloudwatch_metric_alarm.rds_low_storage.arn
            ]
          )
        }
      }
    ]
  })
}
