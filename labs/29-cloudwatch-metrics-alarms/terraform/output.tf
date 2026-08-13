output "lambda_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}

output "lambda_function_url" {
  value = aws_lambda_function_url.app.function_url
}

output "lambda_arn" {
  value = aws_lambda_function.app.arn
}
