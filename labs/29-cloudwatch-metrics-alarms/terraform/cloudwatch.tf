resource "aws_cloudwatch_metric_alarm" "high_request" {
  alarm_name          = "${var.project_name}-high-request-alarm"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "RequestProcessed"
  namespace           = "Lab29"
  statistic           = "Sum"
  threshold           = 20
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 2
}
