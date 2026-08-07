output "test_role_arn" {
  value = aws_iam_role.test.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.test.bucket
}
