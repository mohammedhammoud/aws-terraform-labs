resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-main-topic"

  tags = {
    Name = "${local.name_prefix}-main-topic"
  }
}

resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}
