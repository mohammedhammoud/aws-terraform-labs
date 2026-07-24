resource "aws_sqs_queue" "lab_queue" {
  name                       = "${var.project_name}-lab-queue"
  visibility_timeout_seconds = var.lambda_timeout * 6
}
