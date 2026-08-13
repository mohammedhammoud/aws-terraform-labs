data "archive_file" "app" {
  type        = "zip"
  source_dir  = "${path.module}/../app/dist"
  output_path = "${path.module}/app.zip"
}

resource "aws_lambda_function" "app" {
  function_name = "${var.project_name}-app"

  role    = aws_iam_role.lambda_execution_role.arn
  handler = "index.handler"
  runtime = "nodejs20.x"

  filename         = data.archive_file.app.output_path
  source_code_hash = data.archive_file.app.output_base64sha256

  environment {
    variables = {}
  }
}

resource "aws_lambda_function_url" "app" {
  function_name      = aws_lambda_function.app.function_name
  authorization_type = "NONE"
}
