output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.high_memory.alarm_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.lab.arn
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.lab.dashboard_name
}
