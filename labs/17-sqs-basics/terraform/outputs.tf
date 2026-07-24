output "process_message_lambda_arn" {
  value = aws_lambda_function.process_message.arn
}

output "process_message_lambda_name" {
  value = aws_lambda_function.process_message.function_name
}

output "queue_arn" {
  value = aws_sqs_queue.lab_queue.arn
}

output "queue_url" {
  value = aws_sqs_queue.lab_queue.url
}
