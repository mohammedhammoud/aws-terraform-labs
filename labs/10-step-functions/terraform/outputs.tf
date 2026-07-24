output "state_machine_arn" {
  value = aws_sfn_state_machine.lab.arn
}

output "state_machine_name" {
  value = aws_sfn_state_machine.lab.name
}

output "validate_lambda_arn" {
  value = aws_lambda_function.validate.arn
}

output "process_lambda_arn" {
  value = aws_lambda_function.process.arn
}
