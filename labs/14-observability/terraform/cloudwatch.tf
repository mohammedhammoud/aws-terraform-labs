resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-high-memory-alarm"
  alarm_description   = "Triggers when memory usage exceeds the configured threshold."
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "mem_used_percent"
  namespace           = "ObservabilityLab"
  statistic           = "Average"
  alarm_actions       = [aws_sns_topic.lab.arn]
  treat_missing_data  = "missing"

  threshold          = var.alarm_threshold
  period             = var.alarm_period
  evaluation_periods = var.alarm_evaluation_periods

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = {
    Name = "${var.project_name}-high-memory-alarm"
  }
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.project_name}/application"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-application-log-group"
  }
}

resource "aws_cloudwatch_log_group" "user_data" {
  name              = "/${var.project_name}/user-data"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-user-data-log-group"
  }
}


resource "aws_cloudwatch_dashboard" "lab" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Memory Utilization"
          region = var.region
          stat   = "Average"
          period = var.alarm_period

          metrics = [
            [
              "ObservabilityLab",
              "mem_used_percent",
              "InstanceId",
              aws_instance.web.id
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
          title  = "Disk Utilization"
          region = var.region
          stat   = "Average"
          period = var.alarm_period

          metrics = [
            [
              "ObservabilityLab",
              "disk_used_percent",
              "InstanceId",
              aws_instance.web.id,
              "device",
              "nvme0n1p1",
              "fstype",
              "xfs",
              "path",
              "/"
            ]
          ]
        }
      },
      {
        type   = "alarm"
        x      = 0
        y      = 6
        width  = 24
        height = 3

        properties = {
          title = "Memory Alarm"

          alarms = [
            aws_cloudwatch_metric_alarm.high_memory.arn
          ]
        }
      }
    ]
  })
}
