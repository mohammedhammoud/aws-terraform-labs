output "lambda_s3_lab" {
  value = {
    bucket_name     = aws_s3_bucket.lab.bucket
    lambda_role_arn = aws_iam_role.lambda_role.arn
    policy_arn      = aws_iam_policy.s3_access.arn
    lambda_name     = aws_lambda_function.s3_processor.function_name
    lambda_arn      = aws_lambda_function.s3_processor.arn
  }
}
