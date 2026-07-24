data "archive_file" "process_message" {
  type        = "zip"
  source_file = "${path.module}/../app/process-message/index.js"
  output_path = "${path.module}/process_message.zip"
}

resource "aws_lambda_function" "process_message" {
  function_name    = "${var.project_name}-process-message"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  timeout          = var.lambda_timeout
  filename         = data.archive_file.process_message.output_path
  source_code_hash = data.archive_file.process_message.output_base64sha256
}

resource "aws_lambda_event_source_mapping" "process_message" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.lab_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.process_message.arn

  depends_on = [
    aws_iam_role_policy_attachment.lambda_sqs,
  ]
}
