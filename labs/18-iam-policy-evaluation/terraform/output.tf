output "role_arn" {
  value = aws_iam_role.s3_access.arn
}

output "bucket_name" {
  value = aws_s3_bucket.lab.bucket
}
