data "archive_file" "validate" {
  type        = "zip"
  source_file = "${path.module}/../app/validate.js"
  output_path = "${path.module}/validate.zip"
}

data "archive_file" "process" {
  type        = "zip"
  source_file = "${path.module}/../app/process.js"
  output_path = "${path.module}/process.zip"
}

resource "aws_lambda_function" "validate" {
  function_name    = "${var.project_name}-validate"
  role             = aws_iam_role.lambda.arn
  handler          = "validate.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.validate.output_path
  source_code_hash = data.archive_file.validate.output_base64sha256
}

resource "aws_lambda_function" "process" {
  function_name    = "${var.project_name}-process"
  role             = aws_iam_role.lambda.arn
  handler          = "process.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.process.output_path
  source_code_hash = data.archive_file.process.output_base64sha256
}