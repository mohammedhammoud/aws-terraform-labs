data "archive_file" "log_order" {
  type        = "zip"
  source_file = "${path.module}/../app/log-order/index.js"
  output_path = "${path.module}/log_order.zip"
}

data "archive_file" "log_customer" {
  type        = "zip"
  source_file = "${path.module}/../app/log-customer/index.js"
  output_path = "${path.module}/log_customer.zip"
}

resource "aws_lambda_function" "log_order" {
  function_name    = "${var.project_name}-log-order"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.log_order.output_path
  source_code_hash = data.archive_file.log_order.output_base64sha256
}

resource "aws_lambda_function" "log_customer" {
  function_name    = "${var.project_name}-log-customer"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.log_customer.output_path
  source_code_hash = data.archive_file.log_customer.output_base64sha256
}
