output "log_order_lambda_arn" {
  value = aws_lambda_function.log_order.arn
}

output "log_customer_lambda_arn" {
  value = aws_lambda_function.log_customer.arn
}
