resource "aws_sns_topic" "lab" {
  name = "${var.project_name}-lab-topic"

  tags = {
    Name = "${var.project_name}-lab-topic"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.lab.arn
  protocol  = "email"
  endpoint  = var.sns_email
}
